#!/bin/bash

# SSL Setup Script for Django + Nginx + Let's Encrypt

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Get domain from user
read -p "Enter your domain name (e.g., example.com): " DOMAIN
read -p "Enter your email for Let's Encrypt: " EMAIL

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
  print_error "Domain and email are required!"
  exit 1
fi

print_step "Setting up SSL for domain: $DOMAIN"

# Update .env.prod with domain
print_status "Updating .env.prod with domain..."
if [ -f ".env.prod" ]; then
  # Update ALLOWED_HOSTS to include the domain
  sed -i "s/ALLOWED_HOSTS=.*/ALLOWED_HOSTS=$DOMAIN,www.$DOMAIN,localhost/" .env.prod
else
  print_error ".env.prod not found! Please create it first."
  exit 1
fi

# Update nginx configuration
print_status "Updating nginx configuration..."
sed -i "s/yourdomain\.com/$DOMAIN/g" nginx/nginx.conf

# Create initial directories
print_status "Creating SSL directories..."
mkdir -p ./certbot/conf
mkdir -p ./certbot/www

# Step 1: Start services without SSL first
print_step "1. Starting services without SSL..."

# Create temporary nginx config for initial setup
cat >nginx/nginx.temp.conf <<EOF
upstream sbm_backend {
    server web:8000;
}

server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    location / {
        proxy_pass http://sbm_backend;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
    }

    location /static/ {
        alias /usr/src/sbm_backend/staticfiles/;
    }

    location /media/ {
        alias /usr/src/sbm_backend/media/;
    }
}
EOF

# Backup original nginx config and use temp
mv nginx/nginx.conf nginx/nginx.conf.backup
mv nginx/nginx.temp.conf nginx/nginx.conf

# Start services
print_status "Building and starting containers..."
sudo docker-compose -f docker-compose.prod.yml down || true
sudo docker-compose -f docker-compose.prod.yml up --build -d

# Wait for services
print_status "Waiting for services to start..."
sleep 30

# Check if domain is accessible
print_status "Checking if domain is accessible..."
for i in {1..5}; do
  if curl -f -s "http://$DOMAIN" >/dev/null; then
    print_status "✅ Domain is accessible via HTTP"
    break
  else
    print_warning "Attempt $i/5: Domain not accessible yet, waiting..."
    sleep 10
  fi
done

# Step 2: Get SSL certificate
print_step "2. Obtaining SSL certificate..."

print_status "Requesting SSL certificate from Let's Encrypt..."
sudo docker-compose -f docker-compose.prod.yml run --rm --no-deps certbot \
  certbot certonly --webroot \
  -w /var/www/certbot \
  --email $EMAIL \
  --agree-tos \
  --no-eff-email \
  --force-renewal \
  -d $DOMAIN -d www.$DOMAIN

if [ $? -eq 0 ]; then
  print_status "✅ SSL certificate obtained successfully!"
else
  print_error "Failed to obtain SSL certificate"
  exit 1
fi

# Step 3: Update to HTTPS configuration
print_step "3. Updating to HTTPS configuration..."

# Restore the full nginx config with SSL
mv nginx/nginx.conf.backup nginx/nginx.conf

# Reload nginx with SSL configuration
print_status "Reloading nginx with SSL configuration..."
sudo docker-compose -f docker-compose.prod.yml exec nginx nginx -s reload

# Step 4: Test HTTPS
print_step "4. Testing HTTPS configuration..."
sleep 10

# Test HTTPS
if curl -f -s "https://$DOMAIN" >/dev/null; then
  print_status "✅ HTTPS is working!"
else
  print_warning "HTTPS test failed, but certificate might still be valid"
fi

# Test HTTP redirect
if curl -s -o /dev/null -w "%{http_code}" "http://$DOMAIN" | grep -q "301"; then
  print_status "✅ HTTP to HTTPS redirect is working!"
else
  print_warning "HTTP to HTTPS redirect might not be working properly"
fi

# Final status
print_step "🎉 SSL Setup Complete!"
echo ""
print_status "Your Django app is now available at:"
print_status "  📱 https://$DOMAIN"
print_status "  📱 https://www.$DOMAIN"
echo ""
print_status "SSL certificate will auto-renew every 12 hours via certbot container"
print_status "Certificate expires in 90 days and will be auto-renewed"
echo ""
print_status "To check SSL status: docker-compose -f docker-compose.prod.yml logs certbot"
print_status "To check nginx logs: docker-compose -f docker-compose.prod.yml logs nginx"
print_status "To check app logs: docker-compose -f docker-compose.prod.yml logs web"
