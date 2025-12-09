#!/bin/bash

# Simplified Multi-App Deployment Script
# Works around Docker Compose v5 build issues

set -e

echo "============================================"
echo "🚀 Multi-App Deployment (Simplified)"
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
    exit 1
fi

# Load environment variables
source .env

echo "📋 Deployment Configuration:"
echo "   Environment: ${ENVIRONMENT:-production}"
echo "   App1 (HRMS): ${APP1_DOMAIN:-dinesh-app1.zamait.in}"
echo "   App2 (Node): ${APP2_DOMAIN:-dinesh-app2.zamait.in}"
echo ""

# Stop existing containers
echo "🛑 Step 1/5: Stopping existing containers..."
docker compose down -v 2>/dev/null || docker-compose down -v 2>/dev/null || true
echo "✅ Stopped"
echo ""

# Build HRMS app
echo "🔨 Step 2/5: Building HRMS container..."
echo "   This will take 5-10 minutes..."
cd ../HRMS
docker build -t hrms-app:latest -f Dockerfile.combined \
  --build-arg REACT_APP_API_URL=https://${APP1_DOMAIN:-dinesh-app1.zamait.in} \
  --build-arg REACT_APP_ENVIRONMENT=${ENVIRONMENT:-production} \
  .
cd ../multi-app-deployment
echo "✅ HRMS built"
echo ""

# Build App2
echo "🔨 Step 3/5: Building App2 container..."
echo "   This will take 2-3 minutes..."
cd ../app2
docker build -t app2:latest .
cd ../multi-app-deployment
echo "✅ App2 built"
echo ""

# Start containers
echo "🚀 Step 4/5: Starting containers..."
docker compose up -d 2>/dev/null || docker-compose up -d
echo "✅ Containers started"
echo ""

# Wait and check status
echo "⏳ Step 5/5: Waiting for services..."
sleep 20

echo ""
echo "📊 Container Status:"
docker compose ps 2>/dev/null || docker-compose ps
echo ""

# Get server IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || curl -s ifconfig.me 2>/dev/null || echo "YOUR-SERVER-IP")

echo ""
echo "============================================"
echo "✅ Deployment Complete!"
echo "============================================"
echo ""
echo "📍 Access your applications:"
echo ""
echo "🌐 HRMS Application:"
echo "   URL: http://${APP1_DOMAIN:-dinesh-app1.zamait.in}"
echo "   (or http://$PUBLIC_IP for testing)"
echo "   API Docs: http://${APP1_DOMAIN:-dinesh-app1.zamait.in}/docs"
echo ""
echo "🌐 App2 Application:"
echo "   URL: http://${APP2_DOMAIN:-dinesh-app2.zamait.in}"
echo "   Health: http://${APP2_DOMAIN:-dinesh-app2.zamait.in}/api/health"
echo ""
echo "🔐 Next Steps:"
echo "   1. Verify DNS is pointing to: $PUBLIC_IP"
echo "   2. Test applications via domain names"
echo "   3. Run './setup-ssl.sh' to enable HTTPS"
echo ""
echo "📋 Useful commands:"
echo "   docker compose logs -f              # View logs"
echo "   docker compose ps                   # Check status"
echo "   docker compose restart hrms-app     # Restart HRMS"
echo "   docker compose restart app2         # Restart App2"
echo ""
echo "============================================"
