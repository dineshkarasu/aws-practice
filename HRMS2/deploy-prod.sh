#!/bin/bash

# HRMS Production Deployment Script for EC2
# Run this after ec2-setup.sh and uploading files

set -e

echo "========================================"
echo "  HRMS Production Deployment"
echo "========================================"
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "[1/5] Creating .env file..."
    cp .env.example .env
    
    echo ""
    echo "⚠️  IMPORTANT: Please configure your .env file with production settings"
    echo ""
    echo "Required changes:"
    echo "1. Set POSTGRES_PASSWORD to a secure password"
    echo "2. Update REACT_APP_API_URL with your EC2 IP or domain"
    echo "3. Set ENVIRONMENT=prod"
    echo ""
    echo "Edit the file now? (y/n)"
    read -r response
    
    if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
        nano .env
    else
        echo "Please edit .env manually before proceeding:"
        echo "  nano .env"
        exit 1
    fi
else
    echo "[1/5] .env file exists"
fi

echo ""
echo "[2/5] Making scripts executable..."
chmod +x start.sh stop.sh
echo "✓ Scripts are executable"

echo ""
echo "[3/5] Building and starting containers..."
echo "This may take 5-10 minutes..."
docker-compose up -d --build

echo ""
echo "[4/5] Waiting for services to be healthy..."
sleep 30

echo ""
echo "[5/5] Checking service health..."
max_attempts=20
attempt=0
healthy=false

while [ $attempt -lt $max_attempts ] && [ "$healthy" = false ]; do
    if curl -f -s http://localhost/health > /dev/null 2>&1; then
        healthy=true
    else
        attempt=$((attempt + 1))
        sleep 3
        echo -n "."
    fi
done

echo ""

if [ "$healthy" = true ]; then
    echo "✓ All services are healthy!"
else
    echo "⚠️  Health check timed out. Services may still be starting."
    echo "Check logs with: docker-compose logs -f"
fi

echo ""
echo "========================================"
echo "  Deployment Complete!"
echo "========================================"
echo ""

# Get EC2 public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "YOUR_EC2_IP")

echo "Access your application at:"
echo "  • Frontend:     http://$PUBLIC_IP"
echo "  • API Docs:     http://$PUBLIC_IP/docs"
echo "  • Health Check: http://$PUBLIC_IP/health"
echo ""
echo "Optional: Seed initial data with:"
echo "  docker-compose exec api python seed_data.py"
echo ""
echo "View logs with:"
echo "  docker-compose logs -f"
echo ""
