#!/bin/bash

# HRMS Environment-Aware Deployment Script
# Usage: ./deploy-env.sh [dev|test|staging|prod]

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "============================================"
echo "🚀 HRMS Environment-Aware Deployment"
echo "============================================"
echo ""

# Check if environment argument is provided
if [ -z "$1" ]; then
    echo -e "${RED}❌ Error: Environment not specified${NC}"
    echo ""
    echo "Usage: ./deploy-env.sh [dev|test|staging|prod]"
    echo ""
    echo "Examples:"
    echo "  ./deploy-env.sh dev      # Deploy to development"
    echo "  ./deploy-env.sh test     # Deploy to testing"
    echo "  ./deploy-env.sh staging  # Deploy to staging"
    echo "  ./deploy-env.sh prod     # Deploy to production"
    echo ""
    exit 1
fi

ENVIRONMENT=$1

# Validate environment
case $ENVIRONMENT in
    dev|test|staging|prod)
        echo -e "${GREEN}✅ Valid environment: $ENVIRONMENT${NC}"
        ;;
    *)
        echo -e "${RED}❌ Error: Invalid environment '$ENVIRONMENT'${NC}"
        echo "Valid environments: dev, test, staging, prod"
        exit 1
        ;;
esac

ENV_FILE=".env.$ENVIRONMENT"

# Check if environment file exists
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}❌ Error: Environment file '$ENV_FILE' not found${NC}"
    echo "Please create $ENV_FILE with appropriate configuration"
    exit 1
fi

echo -e "${BLUE}📋 Environment file: $ENV_FILE${NC}"
echo ""

# Production warning
if [ "$ENVIRONMENT" == "prod" ]; then
    echo -e "${YELLOW}⚠️  WARNING: You are about to deploy to PRODUCTION!${NC}"
    echo ""
    read -p "Are you sure you want to continue? (yes/no) " -r
    echo
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "Deployment cancelled."
        exit 1
    fi
fi

# Stop existing containers
echo "🛑 Step 1/4: Stopping existing containers..."
docker-compose --env-file "$ENV_FILE" down -v 2>/dev/null || true
echo -e "${GREEN}✅ Containers stopped${NC}"
echo ""

# Build and start containers
echo "🔨 Step 2/4: Building and starting containers..."
docker-compose --env-file "$ENV_FILE" up -d --build

# Check if build was successful
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Deployment failed during build${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Containers built and started${NC}"
echo ""

# Wait for services to be healthy
echo "⏳ Step 3/4: Waiting for services to be healthy..."
sleep 15

# Check container status
echo "📊 Step 4/4: Checking container status..."
docker-compose --env-file "$ENV_FILE" ps
echo ""

# Get environment-specific URLs
case $ENVIRONMENT in
    dev)
        FRONTEND_URL="http://localhost"
        API_DOCS_URL="http://localhost/docs"
        ;;
    test)
        FRONTEND_URL="https://test.hrms.zamait.in"
        API_DOCS_URL="https://test-api.hrms.zamait.in/docs"
        ;;
    staging)
        FRONTEND_URL="https://staging.hrms.zamait.in"
        API_DOCS_URL="https://staging-api.hrms.zamait.in/docs"
        ;;
    prod)
        FRONTEND_URL="https://hrms.zamait.in"
        API_DOCS_URL="https://api.hrms.zamait.in/docs"
        ;;
esac

echo ""
echo "============================================"
echo -e "${GREEN}✅ DEPLOYMENT SUCCESSFUL!${NC}"
echo "============================================"
echo ""
echo -e "${BLUE}🌍 Environment: ${YELLOW}$(echo $ENVIRONMENT | tr '[:lower:]' '[:upper:]')${NC}"
echo ""
echo "📍 Access URLs:"
echo "  Frontend:    $FRONTEND_URL"
echo "  API Docs:    $API_DOCS_URL"
echo "  Health:      $FRONTEND_URL/health"
echo ""
echo "📝 Useful Commands:"
echo "  View logs:        docker-compose --env-file $ENV_FILE logs -f"
echo "  Stop app:         docker-compose --env-file $ENV_FILE down"
echo "  Restart app:      docker-compose --env-file $ENV_FILE restart"
echo "  Check status:     docker-compose --env-file $ENV_FILE ps"
echo ""

if [ "$ENVIRONMENT" == "dev" ]; then
    echo "🔧 Development Commands:"
    echo "  Seed data:        docker exec -it hrms-api python seed_data.py"
    echo "  Access DB:        docker exec -it hrms-db psql -U postgres -d testdb"
    echo ""
fi

echo "🎉 Happy coding!"
echo "============================================"
