#!/bin/bash
# HRMS Environment Configuration Helper
# This script sets environment-specific variables based on ENVIRONMENT value

set -e

# Load .env file
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "Please copy .env.template to .env and configure your environment."
    exit 1
fi

# Source the .env file
source .env

# Check if ENVIRONMENT is set
if [ -z "$ENVIRONMENT" ]; then
    echo "❌ Error: ENVIRONMENT variable is not set in .env file"
    echo "Set ENVIRONMENT to one of: dev, test, staging, prod"
    exit 1
fi

echo "🚀 Setting up environment: $ENVIRONMENT"

# Set Database Host based on environment
case $ENVIRONMENT in
    dev)
        export DB_HOST=$DB_HOST_DEV
        export REACT_APP_API_URL=$REACT_APP_API_URL_DEV
        export LOG_LEVEL=$LOG_LEVEL_DEV
        ;;
    test)
        export DB_HOST=$DB_HOST_TEST
        export REACT_APP_API_URL=$REACT_APP_API_URL_TEST
        export LOG_LEVEL=$LOG_LEVEL_TEST
        ;;
    staging)
        export DB_HOST=$DB_HOST_STAGING
        export REACT_APP_API_URL=$REACT_APP_API_URL_STAGING
        export LOG_LEVEL=$LOG_LEVEL_STAGING
        ;;
    prod)
        export DB_HOST=$DB_HOST_PROD
        export REACT_APP_API_URL=$REACT_APP_API_URL_PROD
        export LOG_LEVEL=$LOG_LEVEL_PROD
        ;;
    *)
        echo "❌ Error: Invalid ENVIRONMENT value: $ENVIRONMENT"
        echo "Valid values are: dev, test, staging, prod"
        exit 1
        ;;
esac

# Construct DATABASE_URL with environment-specific host
export DATABASE_URL="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${DB_HOST}:5432/${POSTGRES_DB}"

echo "✅ Environment configured successfully!"
echo ""
echo "📝 Configuration:"
echo "  - Environment: $ENVIRONMENT"
echo "  - Database Host: $DB_HOST"
echo "  - API URL: $REACT_APP_API_URL"
echo "  - Log Level: $LOG_LEVEL"
echo "  - Database URL: postgresql://${POSTGRES_USER}:****@${DB_HOST}:5432/${POSTGRES_DB}"
echo ""

# Export all variables to a file for docker-compose
cat > .env.active <<EOF
# Auto-generated environment configuration for $ENVIRONMENT
# Generated on: $(date)
ENVIRONMENT=$ENVIRONMENT
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_DB=$POSTGRES_DB
DB_HOST=$DB_HOST
DATABASE_URL=$DATABASE_URL
PORT=$PORT
PYTHONUNBUFFERED=$PYTHONUNBUFFERED
REACT_APP_API_URL=$REACT_APP_API_URL
LOG_LEVEL=$LOG_LEVEL
AWS_REGION=$AWS_REGION
AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID
ECR_REGISTRY=$ECR_REGISTRY
EOF

echo "💾 Active configuration saved to .env.active"
echo "🐳 Run: docker-compose --env-file .env.active up -d"
