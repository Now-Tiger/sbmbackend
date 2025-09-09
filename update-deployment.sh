#!/bin/bash

# Update Deployment Script - Pull latest code and restart services
# This script pulls latest changes and restarts without modifying tracked files

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

print_status "🔄 Updating deployment with latest code..."

# Check if local config files exist
if [ ! -f ".env.prod.local" ]; then
  print_warning "Local config not found. Run deploy-production.sh first."
  exit 1
fi

# Pull latest changes
print_status "1. Pulling latest code from Git..."
git pull origin main --no-ff

# Rebuild and restart containers
print_status "2. Rebuilding and restarting containers..."
docker-compose -f docker-compose.prod.yml -f docker-compose.prod.local.yml down
docker-compose -f docker-compose.prod.yml -f docker-compose.prod.local.yml up --build -d

# Wait for services
print_status "3. Waiting for services to start..."
sleep 30

# Check if everything is running
if docker-compose -f docker-compose.prod.yml -f docker-compose.prod.local.yml ps | grep -q "Up"; then
  print_status "✅ Deployment updated successfully!"
else
  print_warning "⚠️  Some services may not be running properly"
  docker-compose -f docker-compose.prod.yml -f docker-compose.prod.local.yml ps
fi

print_status "🎉 Update complete!"
