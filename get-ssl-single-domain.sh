#!/bin/bash

# Get SSL certificate for single domain only (without www)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

DOMAIN="nowtiger.dpdns.org"
EMAIL="swapnil.narwade3@gmail.com"

print_status "🔒 Getting SSL certificate for $DOMAIN only (without www)"

# Create certbot directories
mkdir -p ./certbot/conf
mkdir -p ./certbot/www

# Get certificate for main domain only
print_status "Requesting SSL certificate from Let's Encrypt..."
docker run --rm \
  -v "$(pwd)/certbot/conf:/etc/letsencrypt" \
  -v "$(pwd)/certbot/www:/var/www/certbot" \
  certbot/certbot certonly --webroot \
  -w /var/www/certbot \
  --email $EMAIL \
  --agree-tos \
  --no-eff-email \
  --force-renewal \
  -d $DOMAIN

if [ $? -eq 0 ]; then
  print_status "✅ SSL certificate obtained successfully!"

  # Update nginx config to remove www references
  print_status "Updating nginx configuration for single domain..."

  # Update nginx-local/nginx.conf to only use main domain
  cat >nginx-local/nginx.conf <<EOF
upstream sbm_backend {
    server web:8000;
}

server {
    listen 80;
    server_name $DOMAIN;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN;
    
    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    client_max_body_size 100M;

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
        expires 1M;
        access_log off;
        add_header Cache-Control "public, immutable";
    }

    location /media/ {
        alias /usr/src/sbm_backend/media/;
        expires 1M;
        access_log off;
        add_header Cache-Control "public, immutable";
    }
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
}
EOF

  print_status "✅ Nginx configuration updated"

  # Deploy with HTTPS
  print_status "Deploying with HTTPS..."
  docker-compose -f docker-compose.temp.yml down || true
  docker-compose -f docker-compose.prod.yml -f docker-compose.prod.local.yml up --build -d

  sleep 20
  print_status "✅ HTTPS deployment complete"

  # Test
  print_status "Testing HTTPS..."
  if curl -f -s "https://$DOMAIN" >/dev/null; then
    print_status "✅ HTTPS working!"
    print_status "🎉 Your app is available at: https://$DOMAIN"
  else
    print_warning "⚠️ HTTPS test failed, but certificate exists"
  fi

else
  print_error "❌ Failed to get SSL certificate"
  exit 1
fi
