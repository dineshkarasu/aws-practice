#!/bin/bash

# SSL Certificate Setup Script for HRMS
# Sets up Let's Encrypt SSL certificate for hrms.zamait.in

set -e

DOMAIN="hrms.zamait.in"
EMAIL="admin@zamait.in"  # Change this to your email

echo "============================================"
echo "🔒 SSL Certificate Setup for HRMS"
echo "Domain: $DOMAIN"
echo "============================================"
echo ""

# Check if running on EC2
if [ ! -f "/etc/ec2_version" ] && [ ! -d "/sys/hypervisor/uuid" ]; then
    echo "⚠️  Warning: This doesn't appear to be an EC2 instance"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "📦 Step 1/6: Installing Certbot..."
if ! command -v certbot &> /dev/null; then
    sudo yum install certbot -y
    echo "✅ Certbot installed"
else
    echo "✅ Certbot already installed"
fi

echo ""
echo "🛑 Step 2/6: Stopping application temporarily..."
cd ~/aws-training/devops/hackathon/HRMS
docker-compose down

echo ""
echo "📁 Step 3/6: Creating certificate directories..."
mkdir -p certbot/conf
mkdir -p certbot/www
mkdir -p ssl

echo ""
echo "🔐 Step 4/6: Obtaining SSL certificate from Let's Encrypt..."
echo "Using DNS challenge (no port 80 required)..."
echo ""
echo "⚠️  IMPORTANT: You will need to add a DNS TXT record to validate domain ownership"
echo ""

sudo certbot certonly \
    --manual \
    --preferred-challenges dns \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    --domains "$DOMAIN"

if [ $? -ne 0 ]; then
    echo "❌ Failed to obtain SSL certificate"
    echo "Make sure you added the DNS TXT record as instructed above"
    exit 1
fi

echo ""
echo "📋 Step 5/6: Copying certificates to project directory..."
sudo cp -r /etc/letsencrypt/* ./certbot/conf/
sudo chown -R $(whoami):$(whoami) ./certbot/conf

echo ""
echo "🚀 Step 6/6: Starting application with SSL..."
docker-compose up -d --build

echo ""
echo "⏳ Waiting for services to start..."
sleep 15

echo ""
echo "============================================"
echo "✅ SSL CERTIFICATE SETUP COMPLETE!"
echo "============================================"
echo ""
echo "🌐 Your application is now accessible at:"
echo ""
echo "  HTTPS: https://$DOMAIN/"
echo "  API:   https://$DOMAIN/docs"
echo "  Health: https://$DOMAIN/health"
echo ""
echo "📜 Certificate Details:"
sudo certbot certificates
echo ""
echo "🔄 Certificate Auto-Renewal:"
echo "Certificates expire in 90 days. To set up auto-renewal:"
echo ""
echo "  sudo crontab -e"
echo ""
echo "Add this line:"
echo "  0 3 * * * certbot renew --quiet --post-hook 'cd ~/aws-training/devops/hackathon/HRMS && docker-compose restart web'"
echo ""
echo "============================================"
