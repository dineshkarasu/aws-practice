#!/bin/bash

# HRMS Application Deployment Script for EC2
# Deploys PostgreSQL + FastAPI + React with Nginx reverse proxy

set -e  # Exit on error

echo "============================================"
echo "🚀 HRMS Production Deployment"
echo "PostgreSQL + FastAPI + React + Nginx"
echo "============================================"
echo ""

# Check if running as ec2-user
if [ "$USER" != "ec2-user" ] && [ "$USER" != "root" ]; then
    echo "⚠️  Warning: This script is designed for EC2. Current user: $USER"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Update system
echo "📦 Step 1/7: Updating system packages..."
sudo yum update -y

# Install Docker
echo "🐳 Step 2/7: Installing Docker..."
if ! command -v docker &> /dev/null; then
    sudo yum install docker -y
    sudo systemctl start docker
    sudo systemctl enable docker
    echo "✅ Docker installed"
else
    echo "✅ Docker already installed"
fi

# Install Docker Compose
echo "🔧 Step 3/7: Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_VERSION="v2.24.0"
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed"
else
    echo "✅ Docker Compose already installed"
fi

# Install Git
echo "📥 Step 4/7: Installing Git..."
if ! command -v git &> /dev/null; then
    sudo yum install git -y
    echo "✅ Git installed"
else
    echo "✅ Git already installed"
fi

# Add user to docker group
echo "👤 Step 5/7: Configuring user permissions..."
sudo usermod -aG docker ec2-user || sudo usermod -aG docker $USER

# Verify installations
echo "🔍 Step 6/7: Verifying installations..."
echo "  Docker: $(docker --version)"
echo "  Docker Compose: $(docker-compose --version)"
echo "  Git: $(git --version)"

# Check if already in HRMS directory
if [ -f "docker-compose.yml" ] && [ -f "main.py" ]; then
    echo "✅ Already in HRMS directory"
else
    echo "📂 Navigating to deployment directory..."
    if [ ! -d "aws-training" ]; then
        echo "⚠️  Repository not found. Please run:"
        echo "   git clone https://github.com/bmohammad1/aws-training.git"
        echo "   cd aws-training/devops/hackathon/HRMS"
        echo "   ./deploy.sh"
        exit 1
    fi
    cd aws-training/devops/hackathon/HRMS
fi

echo ""
echo "🚀 Step 7/7: Starting HRMS Application..."
echo ""

# Check if .env file exists, create from template if not
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Creating from template..."
    if [ -f ".env.template" ]; then
        cp .env.template .env
        echo "✅ .env file created from template"
        echo "⚠️  IMPORTANT: Please edit .env file with your actual values before production use!"
    else
        echo "❌ Error: .env.template not found"
        exit 1
    fi
fi

# Start application
docker-compose down -v 2>/dev/null || true
docker-compose up -d --build

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

# Check status
echo ""
echo "📊 Container Status:"
docker-compose ps

echo ""
echo "============================================"
echo "✅ DEPLOYMENT SUCCESSFUL!"
echo "============================================"
echo ""
echo "📍 Access URLs:"
echo ""

# Get EC2 public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "YOUR-EC2-IP")

echo "  Frontend:    http://${PUBLIC_IP}/"
echo "  API Docs:    http://${PUBLIC_IP}/docs"
echo "  API ReDoc:   http://${PUBLIC_IP}/redoc"
echo "  Health:      http://${PUBLIC_IP}/health"
echo ""
echo "🗄️  Database: PostgreSQL (internal only)"
echo "   - User: postgres"
echo "   - Database: testdb"
echo "   - Volume: hrms-postgres-data"
echo ""
echo "📝 Useful Commands:"
echo "   View logs:        docker-compose logs -f"
echo "   Stop app:         docker-compose down"
echo "   Restart app:      docker-compose restart"
echo "   Seed data:        docker exec -it hrms-api python seed_data.py"
echo "   Access DB:        docker exec -it hrms-db psql -U postgres -d testdb"
echo ""
echo "⚠️  IMPORTANT: If this is first setup, log out and back in:"
echo "   exit"
echo "   ssh -i your-key.pem ec2-user@${PUBLIC_IP}"
echo ""
echo "🎉 Happy coding!"
echo "============================================"
