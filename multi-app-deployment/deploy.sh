#!/bin/bash

# Multi-App Deployment Script
# Deploys HRMS (App1) and App2 on a single server

set -e

echo "============================================"
echo "🚀 Multi-App Deployment"
echo "HRMS (App1) + App2 (Node.js)"
echo "============================================"
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Creating from template..."
    cp .env.template .env
    echo "✅ .env file created"
    echo ""
    echo "⚠️  IMPORTANT: Please edit .env file with your actual values!"
    echo "   nano .env"
    echo ""
    read -p "Press Enter after editing .env file to continue..."
fi

# Load environment variables
source .env

APP1_DOMAIN=${APP1_DOMAIN:-dinesh-app1.zamait.in}
APP2_DOMAIN=${APP2_DOMAIN:-dinesh-app2.zamait.in}
SSL_ENABLED=${SSL_ENABLED:-false}

echo "📋 Deployment Configuration:"
echo "   Environment: $ENVIRONMENT"
echo "   App1 (HRMS): $APP1_DOMAIN"
echo "   App2 (Node): $APP2_DOMAIN"
echo "   SSL Enabled: $SSL_ENABLED"
echo ""

# Check if Docker is installed
echo "🔍 Step 1/6: Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi
echo "✅ Docker: $(docker --version)"

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi
if docker compose version &> /dev/null; then
    echo "✅ Docker Compose: $(docker compose version)"
else
    echo "✅ Docker Compose: $(docker-compose --version)"
fi
echo ""

# Verify application directories exist
echo "📂 Step 2/6: Verifying application directories..."
if [ ! -d "../HRMS" ]; then
    echo "❌ HRMS directory not found at ../HRMS"
    exit 1
fi
if [ ! -d "../app2" ]; then
    echo "❌ app2 directory not found at ../app2"
    exit 1
fi
echo "✅ Application directories found"
echo ""

# Stop existing containers
echo "🛑 Step 3/6: Stopping existing containers..."
if docker compose version &> /dev/null; then
    docker compose down -v 2>/dev/null || true
else
    docker-compose down -v 2>/dev/null || true
fi
echo "✅ Existing containers stopped"
echo ""

# Build and start containers
echo "🔨 Step 4/6: Building Docker images..."
echo "   This may take 10-15 minutes for first build..."
# Use docker compose (v2) or docker-compose (v1)
if docker compose version &> /dev/null; then
    echo "   Using Docker Compose V2..."
    docker compose build
else
    echo "   Using Docker Compose V1..."
    docker-compose build
fi
echo "✅ Images built successfully"
echo ""

echo "🚀 Step 5/6: Starting containers..."
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi
echo "✅ Containers started"
echo ""

# Wait for services to be healthy
echo "⏳ Step 6/6: Waiting for services to be healthy..."
sleep 20

# Check container status
echo ""
echo "📊 Container Status:"
if docker compose version &> /dev/null; then
    docker compose ps
else
    docker-compose ps
fi
echo ""

# Get server IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || curl -s ifconfig.me 2>/dev/null || echo "YOUR-SERVER-IP")

echo ""
echo "============================================"
echo "✅ DEPLOYMENT SUCCESSFUL!"
echo "============================================"
echo ""

if [ "$SSL_ENABLED" = "true" ]; then
    echo "🌐 Applications are accessible at:"
    echo ""
    echo "  📱 HRMS (App1):  https://$APP1_DOMAIN"
    echo "     - API Docs:    https://$APP1_DOMAIN/docs"
    echo "     - Health:      https://$APP1_DOMAIN/health"
    echo ""
    echo "  📱 App2 (Node):  https://$APP2_DOMAIN"
    echo "     - Health:      https://$APP2_DOMAIN/api/health"
    echo "     - Message:     https://$APP2_DOMAIN/api/message"
else
    echo "⚠️  SSL is not enabled. Applications are accessible at:"
    echo ""
    echo "  For testing (update DNS or use /etc/hosts):"
    echo "  📱 HRMS (App1):  http://$APP1_DOMAIN (or http://$PUBLIC_IP)"
    echo "  📱 App2 (Node):  http://$APP2_DOMAIN (or http://$PUBLIC_IP)"
    echo ""
    echo "🔒 To enable SSL (HTTPS):"
    echo "   1. Ensure DNS A records point to: $PUBLIC_IP"
    echo "   2. Run: ./setup-ssl.sh"
fi

echo ""
echo "🗄️  Database:"
echo "   - PostgreSQL (HRMS internal only)"
echo "   - Volume: hrms-postgres-data"
echo ""
echo "📝 Useful Commands:"
echo "   View logs (all):     docker-compose logs -f"
echo "   View logs (app1):    docker-compose logs -f hrms-api hrms-web"
echo "   View logs (app2):    docker-compose logs -f app2"
echo "   View logs (nginx):   docker-compose logs -f nginx"
echo "   Stop all:            docker-compose down"
echo "   Restart all:         docker-compose restart"
echo "   Check status:        docker-compose ps"
echo ""
echo "🔧 Application Management:"
echo "   Restart HRMS:        docker-compose restart hrms-api hrms-web"
echo "   Restart App2:        docker-compose restart app2"
echo "   Restart Nginx:       docker-compose restart nginx"
echo "   Rebuild & Restart:   docker-compose up -d --build"
echo ""
echo "🎉 Happy coding!"
echo "============================================"
