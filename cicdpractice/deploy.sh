#!/bin/bash

# Deployment script for CICD Practice Application
# This script pulls the latest code from GitHub and rebuilds/runs the container

set -e  # Exit on any error

echo "====================================="
echo "Starting deployment process..."
echo "====================================="

# Configuration
APP_NAME="cicd-pipeline"
APP_DIR="/home/ec2-user/cicdpractice"
GITHUB_REPO="your-username/your-repo-name"  # Update this with your repo
BRANCH="master"

# Navigate to application directory
cd $APP_DIR

echo "Pulling latest code from GitHub..."
git pull origin $BRANCH

echo "Stopping and removing old container..."
docker stop $APP_NAME 2>/dev/null || true
docker rm $APP_NAME 2>/dev/null || true

echo "Removing old Docker image..."
docker rmi $APP_NAME:latest 2>/dev/null || true

echo "Building new Docker image..."
docker build -t $APP_NAME:latest .

echo "Starting new container..."
docker run -d \
  --restart unless-stopped \
  --name $APP_NAME \
  -p 127.0.0.1:8080:80 \
  $APP_NAME:latest

echo "====================================="
echo "Deployment completed successfully!"
echo "====================================="

# Show container status
docker ps | grep $APP_NAME

# Show recent logs
echo ""
echo "Recent container logs:"
docker logs --tail 20 $APP_NAME
