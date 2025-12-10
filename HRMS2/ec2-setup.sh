#!/bin/bash

# HRMS EC2 Automated Setup Script
# Run this script on a fresh EC2 Ubuntu instance

set -e  # Exit on error

echo "========================================"
echo "  HRMS EC2 Deployment Setup"
echo "========================================"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "❌ Please do not run as root. Run as ubuntu user."
    exit 1
fi

echo "[1/6] Updating system packages..."
sudo apt update && sudo apt upgrade -y
echo "✓ System updated"
echo ""

echo "[2/6] Installing prerequisites..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common git unzip
echo "✓ Prerequisites installed"
echo ""

echo "[3/6] Installing Docker..."
# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add user to docker group
sudo usermod -aG docker $USER

echo "✓ Docker installed"
echo ""

echo "[4/6] Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "✓ Docker Compose installed"
echo ""

echo "[5/6] Configuring firewall..."
sudo ufw --force enable
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
echo "✓ Firewall configured"
echo ""

echo "[6/6] Verifying installations..."
docker --version
docker-compose --version
echo "✓ Verification complete"
echo ""

echo "========================================"
echo "  Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Logout and login again (or run: newgrp docker)"
echo "2. Upload your HRMS application files"
echo "3. Navigate to HRMS directory"
echo "4. Run: ./start.sh"
echo ""
echo "Or follow the detailed guide in AWS-EC2-DEPLOYMENT.md"
