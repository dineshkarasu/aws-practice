#!/bin/bash

# EC2 Initial Setup and Multi-App Deployment Script
# This script sets up Docker on EC2 and deploys both applications
# Run this on a fresh EC2 instance

set -e

echo "============================================"
echo "🚀 EC2 Multi-App Deployment Setup"
echo "HRMS (dinesh-app1.zamait.in) + App2 (dinesh-app2.zamait.in)"
echo "============================================"
echo ""

# Check if running on EC2 or Linux
if [ ! -f /etc/os-release ]; then
    echo "⚠️  Warning: This script is designed for Amazon Linux 2/Ubuntu"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "❌ Cannot detect operating system"
    exit 1
fi

echo "📋 Detected OS: $OS"
echo ""

# Update system
echo "📦 Step 1/8: Updating system packages..."
if [ "$OS" = "amzn" ] || [ "$OS" = "rhel" ] || [ "$OS" = "centos" ]; then
    sudo yum update -y
elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    sudo apt-get update -y
    sudo apt-get upgrade -y
else
    echo "⚠️  Unsupported OS: $OS"
    exit 1
fi
echo "✅ System updated"
echo ""

# Install Docker
echo "🐳 Step 2/8: Installing Docker..."
if ! command -v docker &> /dev/null; then
    if [ "$OS" = "amzn" ] || [ "$OS" = "rhel" ] || [ "$OS" = "centos" ]; then
        sudo yum install docker -y
        sudo systemctl start docker
        sudo systemctl enable docker
    elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        sudo apt-get install -y docker.io
        sudo systemctl start docker
        sudo systemctl enable docker
    fi
    echo "✅ Docker installed: $(docker --version)"
else
    echo "✅ Docker already installed: $(docker --version)"
fi
echo ""

# Install Docker Compose
echo "🔧 Step 3/8: Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    DOCKER_COMPOSE_VERSION="v2.24.0"
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    echo "✅ Docker Compose installed: $(docker-compose --version)"
else
    if docker compose version &> /dev/null; then
        echo "✅ Docker Compose already installed: $(docker compose version)"
    else
        echo "✅ Docker Compose already installed: $(docker-compose --version)"
    fi
fi
echo ""

# Install Git
echo "📥 Step 4/8: Installing Git..."
if ! command -v git &> /dev/null; then
    if [ "$OS" = "amzn" ] || [ "$OS" = "rhel" ] || [ "$OS" = "centos" ]; then
        sudo yum install git -y
    elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        sudo apt-get install -y git
    fi
    echo "✅ Git installed: $(git --version)"
else
    echo "✅ Git already installed: $(git --version)"
fi
echo ""

# Add user to docker group
echo "👤 Step 5/8: Configuring user permissions..."
if [ "$OS" = "amzn" ]; then
    sudo usermod -aG docker ec2-user
    echo "✅ ec2-user added to docker group"
elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    sudo usermod -aG docker $USER
    echo "✅ $USER added to docker group"
else
    sudo usermod -aG docker $USER
    echo "✅ $USER added to docker group"
fi
echo ""
echo "⚠️  IMPORTANT: You may need to log out and log back in for group changes to take effect"
echo "   Or run: newgrp docker"
echo ""

# Check if .env file exists
echo "🔍 Step 6/8: Checking configuration..."
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Creating from template..."
    cp .env.template .env
    echo "✅ .env file created"
    echo ""
    echo "⚠️  IMPORTANT: Please edit .env file with your actual values!"
    echo "   nano .env"
    echo ""
    echo "Required settings:"
    echo "  - HRMS_POSTGRES_PASSWORD: Set a secure password"
    echo "  - APP1_DOMAIN: dinesh-app1.zamait.in"
    echo "  - APP2_DOMAIN: dinesh-app2.zamait.in"
    echo "  - LETSENCRYPT_EMAIL: Your email for SSL certificates"
    echo ""
    read -p "Press Enter after editing .env file to continue..."
else
    echo "✅ .env file found"
fi
echo ""

# Load environment variables
source .env

# Verify Docker is running
echo "🔍 Step 7/8: Verifying Docker is running..."
if ! docker ps &> /dev/null; then
    echo "⚠️  Docker is not running. Starting Docker..."
    sudo systemctl start docker
    sleep 3
fi
echo "✅ Docker is running"
echo ""

# Pull base images to speed up build
echo "📥 Step 8/8: Pre-pulling base Docker images..."
docker pull postgres:15-alpine || true
docker pull python:3.11-slim || true
docker pull node:18-alpine || true
docker pull nginx:alpine || true
echo "✅ Base images pulled"
echo ""

echo "============================================"
echo "✅ EC2 SETUP COMPLETE!"
echo "============================================"
echo ""
echo "📝 Next Steps:"
echo ""
echo "1. Configure DNS (BEFORE running deploy.sh):"
echo "   - Create A records pointing to this EC2 instance's public IP:"
echo "     dinesh-app1.zamait.in → $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || echo 'YOUR_EC2_IP')"
echo "     dinesh-app2.zamait.in → $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || echo 'YOUR_EC2_IP')"
echo ""
echo "2. Open security group ports in AWS Console:"
echo "   - Port 80 (HTTP) - for ACME challenge and redirect"
echo "   - Port 443 (HTTPS) - for secure application access"
echo ""
echo "3. Deploy applications (WITHOUT SSL first):"
echo "   ./deploy.sh"
echo ""
echo "4. After deployment, test HTTP access:"
echo "   http://dinesh-app1.zamait.in"
echo "   http://dinesh-app2.zamait.in"
echo ""
echo "5. Set up SSL certificates:"
echo "   ./setup-ssl.sh"
echo ""
echo "6. Access your applications:"
echo "   https://dinesh-app1.zamait.in (HRMS)"
echo "   https://dinesh-app2.zamait.in (App2)"
echo ""
echo "============================================"
