#!/bin/bash

# Fix Port 80 conflicts

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "🔧 Fixing Port 80 Conflicts..."

# Function to stop system web servers
stop_system_webservers() {
  print_status "1. Checking and stopping system web servers..."

  # Stop Apache2 if running
  if sudo systemctl is-active --quiet apache2 2>/dev/null; then
    print_warning "Stopping Apache2..."
    sudo systemctl stop apache2
    sudo systemctl disable apache2
    print_status "✅ Apache2 stopped and disabled"
  fi

  # Stop system Nginx if running
  if sudo systemctl is-active --quiet nginx 2>/dev/null; then
    print_warning "Stopping system Nginx..."
    sudo systemctl stop nginx
    sudo systemctl disable nginx
    print_status "✅ System Nginx stopped and disabled"
  fi
}

# Function to clean up old Docker containers
cleanup_docker_containers() {
  print_status "2. Cleaning up conflicting Docker containers..."

  # Stop all containers using port 80
  CONTAINERS_80=$(docker ps --format "{{.Names}}" --filter "publish=80" 2>/dev/null || true)
  if [ ! -z "$CONTAINERS_80" ]; then
    print_warning "Stopping containers using port 80: $CONTAINERS_80"
    echo "$CONTAINERS_80" | xargs -r docker stop
    print_status "✅ Stopped containers using port 80"
  fi

  # Stop all containers using port 443
  CONTAINERS_443=$(docker ps --format "{{.Names}}" --filter "publish=443" 2>/dev/null || true)
  if [ ! -z "$CONTAINERS_443" ]; then
    print_warning "Stopping containers using port 443: $CONTAINERS_443"
    echo "$CONTAINERS_443" | xargs -r docker stop
    print_status "✅ Stopped containers using port 443"
  fi

  # Clean up any old containers from previous deployments
  docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
  docker-compose -f docker-compose.prod.local.yml down 2>/dev/null || true
  docker-compose -f docker-compose.temp.yml down 2>/dev/null || true

  print_status "✅ Docker cleanup complete"
}

# Function to check if ports are free
check_ports() {
  print_status "3. Verifying ports are free..."

  if sudo lsof -i :80 >/dev/null 2>&1; then
    print_error "Port 80 is still in use:"
    sudo lsof -i :80
    return 1
  fi

  if sudo lsof -i :443 >/dev/null 2>&1; then
    print_error "Port 443 is still in use:"
    sudo lsof -i :443
    return 1
  fi

  print_status "✅ Ports 80 and 443 are now free"
}

# Function to restart Docker service
restart_docker() {
  print_status "4. Restarting Docker service..."
  sudo systemctl restart docker
  sleep 5
  print_status "✅ Docker service restarted"
}

# Main execution
main() {
  stop_system_webservers
  cleanup_docker_containers
  restart_docker

  if check_ports; then
    print_status "🎉 Port conflicts resolved!"
    print_status "You can now run your deployment script."
  else
    print_error "❌ Port conflicts still exist. Manual intervention needed."
    print_status "Run './diagnose-port-80.sh' to see what's still using the ports."
  fi
}

# Run main function
main "$@"
