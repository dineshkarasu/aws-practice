#!/bin/bash

# HRMS Application Deployment Script for EC2
# This script sets up and deploys the HRMS application on an EC2 instance

set -e  # Exit on any error

echo "=========================================="
echo "HRMS Application Deployment on EC2"
echo "=========================================="
echo ""

# Update system packages
echo "Step 1: Updating system packages..."
sudo yum update -y

# Install Docker
echo "Step 2: Installing Docker..."
sudo yum install docker -y

# Start Docker service
echo "Step 3: Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Add ec2-user to docker group
echo "Step 4: Adding user to docker group..."
sudo usermod -aG docker ec2-user

# Install Docker Compose
echo "Step 5: Installing Docker Compose..."
DOCKER_COMPOSE_VERSION="v2.24.0"
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Verify installations
echo "Step 6: Verifying installations..."
docker --version
docker-compose --version

# Install Git if not already installed
echo "Step 7: Installing Git..."
sudo yum install git -y

echo ""
echo "=========================================="
echo "✅ System setup completed successfully!"
echo "=========================================="
echo ""
echo "⚠️  IMPORTANT: Please log out and log back in for docker group changes to take effect:"
echo "   exit"
echo "   ssh -i your-key.pem ec2-user@<your-ec2-ip>"
echo ""
echo "Next Steps After Re-login:"
echo "1. Clone your repository: git clone <your-repo-url>"
echo "2. Navigate to HRMS directory: cd <repo-name>/HRMS"
echo "3. Copy and configure environment: cp .env.template .env"
echo "4. Edit .env file: nano .env"
echo "5. Run deployment: docker-compose up -d --build"
echo ""
echo "Or use the automated deploy script:"
echo "   ./deploy.sh"
echo ""
