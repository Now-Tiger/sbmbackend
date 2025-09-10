#!/bin/bash

# Production Deployment Script - No File Modification
# This script creates local overrides without modifying Git-tracked files

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Function to check Docker permissions
check_docker() {
  print_status "Checking Docker permissions..."
  if ! docker ps >/dev/null 2>&1; then
    print_error "Docker permission error! Run these commands:"
    echo "sudo usermod -aG docker \$USER"
    echo "sudo chown root:docker /var/run/docker.sock"
    echo "newgrp docker"
    exit 1
  fi
  print_status "✅ Docker permissions OK"
}

# Get user input
get_config() {
  echo "=== Production Deployment Configuration ==="
  read -p "Enter your domain name (e.g., nowtiger.dpdns.org): " DOMAIN
  read -p "Enter your email for SSL certificate: " EMAIL
  read -p "Enter your EC2 public IP: " EC2_IP

  if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ] || [ -z "$EC2_IP" ]; then
    print_error "All fields are required!"
    exit 1
  fi

  print_status "Domain: $DOMAIN"
  print_status "Email: $EMAIL"
  print_status "EC2 IP: $EC2_IP"
}

# Create local production environment file (not tracked)
create_local_env() {
  print_step "1. Creating local production environment..."

  # Create .env.prod.local (add this to .gitignore)
  cat >.env.prod.local <<EOF
# Local production overrides - DO NOT COMMIT THIS FILE
# Add .env.prod.local to your .gitignore

# Domain configuration
ALLOWED_HOSTS=$DOMAIN,www.$DOMAIN,$EC2_IP,localhost

# Your other production settings go here
# DEBUG=False
# SECRET_KEY=your-production-secret-key
# Add any other environment-specific variables
EOF

  print_status "✅ Created .env.prod.local"
  print_warning "Add '.env.prod.local' to your .gitignore file"
}

# Create local nginx configuration (not tracked)
create_local_nginx() {
  print_step "2. Creating local nginx configuration..."

  # Create nginx configuration override
  mkdir -p nginx-local

  cat >nginx-local/nginx.conf <<EOF
upstream sbm_backend {
    server web:8000;
}

# Redirect HTTP → HTTPS
server {
    listen 80;
    server_name $DOMAIN;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$DOMAIN\$request_uri;
    }
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;

    client_max_body_size 100M;

    location / {
        proxy_pass http://sbm_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
    }

    location /static/ {
        alias /usr/src/sbm_backend/staticfiles/;
        expires 1M;
    }

    location /media/ {
        alias /usr/src/sbm_backend/media/;
        expires 1M;
    }

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
}
EOF

  # Create nginx Dockerfile for local
  cat >nginx-local/Dockerfile <<EOF
FROM nginx:1.25-alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/
EOF

  print_status "✅ Created nginx-local/ directory"
  print_warning "Add 'nginx-local/' to your .gitignore file"
}

# Create production docker-compose override
create_docker_override() {
  print_step "3. Creating docker-compose override..."

  cat >docker-compose.prod.local.yml <<EOF
version: "3.8"

services:
  web:
    env_file:
      - ./.env.prod
      - ./.env.prod.local  # Local overrides
    
  nginx:
    build: ./nginx-local  # Use local nginx config
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - static_volume:/usr/src/sbm_backend/staticfiles
      - media_volume:/usr/src/sbm_backend/media
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    depends_on:
      - web
    restart: unless-stopped
    command: "/bin/sh -c 'while :; do sleep 6h & wait \$\$!; nginx -s reload; done & nginx -g \"daemon off;\"'"

  certbot:
    image: certbot/certbot
    volumes:
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait \$\$!; done;'"

volumes:
  static_volume:
  media_volume:
EOF

  print_status "✅ Created docker-compose.prod.local.yml"
  print_warning "Add 'docker-compose.prod.local.yml' to your .gitignore file"
}

# Update .gitignore
update_gitignore() {
  print_step "4. Updating .gitignore..."

  # Check if .gitignore exists
  if [ ! -f ".gitignore" ]; then
    touch .gitignore
  fi

  # Add our local files to .gitignore if not already there
  grep -qxF ".env.prod.local" .gitignore || echo ".env.prod.local" >>.gitignore
  grep -qxF "docker-compose.prod.local.yml" .gitignore || echo "docker-compose.prod.local.yml" >>.gitignore
  grep -qxF "nginx-local/" .gitignore || echo "nginx-local/" >>.gitignore
  grep -qxF "certbot/" .gitignore || echo "certbot/" >>.gitignore

  print_status "✅ Updated .gitignore"
}

# Deploy without SSL first
deploy_http() {
  print_step "5. Deploying with HTTP first..."

  # Create temporary nginx config for HTTP only
  mkdir -p nginx-temp
  cat >nginx-temp/nginx.conf <<EOF
upstream sbm_backend {
    server web:8000;
}

server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    client_max_body_size 100M;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    location / {
        proxy_pass http://sbm_backend;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    location /static/ {
        alias /usr/src/sbm_backend/staticfiles/;
    }

    location /media/ {
        alias /usr/src/sbm_backend/media/;
    }
}
EOF

  cat >nginx-temp/Dockerfile <<EOF
FROM nginx:1.25-alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/
EOF

  # Create temp docker-compose
  cat >docker-compose.temp.yml <<EOF
version: "3.8"

services:
  web:
    build: 
      context: ./sbm_backend
      dockerfile: Dockerfile.prod
    command: sh -c "uv run python manage.py migrate && uv run python manage.py collectstatic --noinput && uv run gunicorn sbm_backend.wsgi:application -c gunicorn.conf.py"
    volumes:
      - static_volume:/usr/src/sbm_backend/staticfiles
      - media_volume:/usr/src/sbm_backend/media
    expose:
      - 8000
    env_file:
      - ./.env.prod
      - ./.env.prod.local
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: postgres:15.5-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=postgresuser
      - POSTGRES_PASSWORD=postgrespassword
      - POSTGRES_DB=sbmdb
    restart: unless-stopped

  nginx:
    build: ./nginx-temp
    ports:
      - "80:80"
    volumes:
      - static_volume:/usr/src/sbm_backend/staticfiles
      - media_volume:/usr/src/sbm_backend/media
      - ./certbot/www:/var/www/certbot
    depends_on:
      - web
    restart: unless-stopped

volumes:
  postgres_data:
  static_volume:
  media_volume:
EOF

  # Deploy
  docker-compose -f docker-compose.temp.yml down || true
  docker-compose -f docker-compose.temp.yml up --build -d

  # Wait for services
  sleep 30

  print_status "✅ HTTP deployment complete"
}

# Get SSL certificate
get_ssl_cert() {
  print_step "6. Obtaining SSL certificate..."

  # Create certbot directories
  mkdir -p ./certbot/conf
  mkdir -p ./certbot/www

  # Get certificate
  docker run --rm -v "./certbot/conf:/etc/letsencrypt" -v "./certbot/www:/var/www/certbot" \
    certbot/certbot certonly --webroot -w /var/www/certbot \
    --email $EMAIL --agree-tos --no-eff-email \
    -d $DOMAIN -d www.$DOMAIN

  if [ $? -eq 0 ]; then
    print_status "✅ SSL certificate obtained!"
  else
    print_error "Failed to get SSL certificate"
    exit 1
  fi
}

# Deploy with SSL
deploy_https() {
  print_step "7. Deploying with HTTPS..."

  # Stop temp deployment
  docker-compose -f docker-compose.temp.yml down

  # Use the production deployment with SSL
  docker-compose -f docker-compose.prod.yml -f docker-compose.prod.local.yml up --build -d

  sleep 20

  print_status "✅ HTTPS deployment complete"
}

# Test deployment
test_deployment() {
  print_step "8. Testing deployment..."

  # Test HTTP redirect
  if curl -s -o /dev/null -w "%{http_code}" "http://$DOMAIN" | grep -q "30[12]"; then
    print_status "✅ HTTP redirect working"
  else
    print_warning "⚠️  HTTP redirect may not be working"
  fi

  # Test HTTPS
  if curl -f -s "https://$DOMAIN" >/dev/null; then
    print_status "✅ HTTPS working"
  else
    print_warning "⚠️  HTTPS may not be working"
  fi
}

# Cleanup temp files
cleanup() {
  print_step "9. Cleaning up temporary files..."
  rm -rf nginx-temp/
  rm -f docker-compose.temp.yml
  print_status "✅ Cleanup complete"
}

# Main execution
main() {
  print_step "🚀 Production Deployment (Git-Friendly)"

  check_docker
  get_config
  create_local_env
  create_local_nginx
  create_docker_override
  update_gitignore
  deploy_http

  # Check if domain is accessible
  print_status "Checking domain accessibility..."
  for i in {1..5}; do
    if curl -f -s "http://$DOMAIN" >/dev/null; then
      print_status "✅ Domain accessible"
      break
    else
      print_warning "Attempt $i/5: Domain not accessible"
      if [ $i -eq 5 ]; then
        print_error "Domain not accessible. Check DNS and security groups."
        exit 1
      fi
      sleep 15
    fi
  done

  get_ssl_cert
  deploy_https
  test_deployment
  cleanup

  print_step "🎉 Deployment Complete!"
  echo ""
  print_status "Your app is now available at:"
  print_status "  🔒 https://$DOMAIN"
  print_status "  🔒 https://www.$DOMAIN"
  echo ""
  print_status "Files created (added to .gitignore):"
  print_status "  📄 .env.prod.local"
  print_status "  📄 docker-compose.prod.local.yml"
  print_status "  📁 nginx-local/"
  print_status "  📁 certbot/"
  echo ""
  print_status "Commands to manage deployment:"
  print_status "  View logs: docker-compose -f docker-compose.prod.yml -f docker-compose.prod.local.yml logs"
  print_status "  Stop:      docker-compose -f docker-compose.prod.yml -f docker-compose.prod.local.yml down"
  print_status "  Restart:   docker-compose -f docker-compose.prod.yml -f docker-compose.prod.local.yml restart"
}

# Run main
main "$@"
