#!/bin/bash

# SSL Certificate Setup Script for Multi-App Deployment
# Sets up Let's Encrypt SSL certificates for both domains

set -e

echo "============================================"
echo "🔒 SSL Certificate Setup for Multi-App Deployment"
echo "============================================"
echo ""

# Load environment variables
if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found"
    echo "Please copy .env.template to .env and configure your domains"
    exit 1
fi

source .env

DOMAIN1=${APP1_DOMAIN:-dinesh-app1.zamait.in}
DOMAIN2=${APP2_DOMAIN:-dinesh-app2.zamait.in}
EMAIL=${LETSENCRYPT_EMAIL:-admin@zamait.in}

echo "📋 Configuration:"
echo "   Domain 1 (HRMS): $DOMAIN1"
echo "   Domain 2 (App2): $DOMAIN2"
echo "   Email: $EMAIL"
echo ""

# Check if running on a server with public IP
echo "⚠️  Important Prerequisites:"
echo "   1. DNS A records must point to this server's public IP"
echo "   2. Ports 80 and 443 must be open"
echo "   3. Nginx must be stopped temporarily"
echo ""
read -p "Have you completed the prerequisites? (yes/no) " -n 3 -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Please complete the prerequisites and run this script again."
    exit 1
fi

# Install Certbot if not installed
echo "📦 Step 1/5: Checking Certbot installation..."
if ! command -v certbot &> /dev/null; then
    echo "Installing Certbot..."
    if [ -f /etc/redhat-release ]; then
        # Amazon Linux / CentOS / RHEL
        sudo yum install certbot -y
    elif [ -f /etc/debian_version ]; then
        # Ubuntu / Debian
        sudo apt-get update
        sudo apt-get install certbot -y
    else
        echo "❌ Unsupported OS. Please install certbot manually."
        exit 1
    fi
    echo "✅ Certbot installed"
else
    echo "✅ Certbot already installed"
fi
echo ""

# Create certificate directories
echo "📁 Step 2/5: Creating certificate directories..."
mkdir -p certbot/conf
mkdir -p certbot/www
echo "✅ Directories created"
echo ""

# Stop nginx container if running
echo "🛑 Step 3/5: Stopping Nginx container temporarily..."
docker-compose stop nginx 2>/dev/null || true
echo "✅ Nginx stopped"
echo ""

# Obtain SSL certificate for Domain 1 (HRMS)
echo "🔐 Step 4/5: Obtaining SSL certificate for $DOMAIN1..."
sudo certbot certonly \
    --standalone \
    --preferred-challenges http \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    --domains "$DOMAIN1" \
    --keep-until-expiring

if [ $? -ne 0 ]; then
    echo "❌ Failed to obtain SSL certificate for $DOMAIN1"
    exit 1
fi
echo "✅ Certificate obtained for $DOMAIN1"
echo ""

# Obtain SSL certificate for Domain 2 (App2)
echo "🔐 Step 4/5: Obtaining SSL certificate for $DOMAIN2..."
sudo certbot certonly \
    --standalone \
    --preferred-challenges http \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    --domains "$DOMAIN2" \
    --keep-until-expiring

if [ $? -ne 0 ]; then
    echo "❌ Failed to obtain SSL certificate for $DOMAIN2"
    exit 1
fi
echo "✅ Certificate obtained for $DOMAIN2"
echo ""

# Copy certificates to project directory
echo "📋 Step 5/5: Copying certificates to project directory..."
sudo cp -rL /etc/letsencrypt/* ./certbot/conf/
sudo chown -R $(whoami):$(whoami) ./certbot/conf
echo "✅ Certificates copied"
echo ""

# Update .env file
echo "📝 Updating .env file..."
sed -i 's/SSL_ENABLED=false/SSL_ENABLED=true/' .env
echo "✅ SSL enabled in .env"
echo ""

# Start services with SSL
echo "🚀 Starting services with SSL..."
docker-compose up -d
echo ""

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 15
echo ""

echo "============================================"
echo "✅ SSL CERTIFICATES SETUP COMPLETE!"
echo "============================================"
echo ""
echo "🌐 Your applications are now accessible at:"
echo ""
echo "  HRMS App:  https://$DOMAIN1"
echo "  App2:      https://$DOMAIN2"
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
echo "  0 3 * * * certbot renew --quiet --deploy-hook 'cd $(pwd) && docker-compose restart nginx'"
echo ""
echo "============================================"
