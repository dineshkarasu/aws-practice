# HRMS Environment Configuration Guide

This document explains the environment configuration system for the HRMS application.

## Overview

The HRMS application uses environment-specific configuration files to support multiple deployment environments (dev, test, staging, prod).

## File Structure

```
HRMS/
├── .env.template          # Template with all available configuration options
├── .env.dev               # Development environment (sample - not committed)
├── .env.test              # Test environment (create from template)
├── .env.staging           # Staging environment (create from template)
├── .env.prod              # Production environment (create from template)
├── .env.active            # Auto-generated active configuration
├── set-environment.sh     # Helper script to set environment variables
└── .gitignore             # Ensures .env files are not committed
```

## Quick Start

### 1. Create Environment File

```bash
# Copy template to your desired environment
cp .env.template .env.dev

# Edit the file
nano .env.dev

# Set ENVIRONMENT variable
ENVIRONMENT=dev
```

### 2. Configure Environment

Edit your `.env.dev` (or `.env.test`, `.env.staging`, `.env.prod`) file:

```bash
# Set the environment
ENVIRONMENT=dev  # Options: dev, test, staging, prod

# Database credentials
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password

# URLs are automatically selected based on ENVIRONMENT
```

### 3. Activate Environment

```bash
# Run the environment setup script
./set-environment.sh

# Or manually link your environment file
ln -sf .env.dev .env
```

### 4. Start Application

```bash
# Using docker-compose
docker-compose up -d

# Or with explicit env file
docker-compose --env-file .env.active up -d
```

## Environment Variables

### Core Configuration

| Variable | Description | Example |
|----------|-------------|---------|
| `ENVIRONMENT` | Current environment | `dev`, `test`, `staging`, `prod` |
| `POSTGRES_USER` | Database username | `postgres` |
| `POSTGRES_PASSWORD` | Database password | `your_secure_password` |
| `POSTGRES_DB` | Database name | `testdb` |
| `DATABASE_URL` | Full database connection string | `postgresql://user:pass@host:5432/db` |

### Environment-Specific Variables

#### Database Hosts
- `DB_HOST_DEV`: Local/Docker database host
- `DB_HOST_TEST`: Test RDS endpoint
- `DB_HOST_STAGING`: Staging RDS endpoint
- `DB_HOST_PROD`: Production RDS endpoint

#### API URLs
- `API_URL_DEV`: http://localhost:8000
- `API_URL_TEST`: https://test-api.hrms.zamait.in
- `API_URL_STAGING`: https://staging-api.hrms.zamait.in
- `API_URL_PROD`: https://api.hrms.zamait.in

#### Frontend URLs
- `REACT_APP_API_URL_DEV`: http://localhost
- `REACT_APP_API_URL_TEST`: https://test.hrms.zamait.in
- `REACT_APP_API_URL_STAGING`: https://staging.hrms.zamait.in
- `REACT_APP_API_URL_PROD`: https://hrms.zamait.in

#### Logging
- `LOG_LEVEL_DEV`: DEBUG
- `LOG_LEVEL_TEST`: INFO
- `LOG_LEVEL_STAGING`: WARNING
- `LOG_LEVEL_PROD`: ERROR

## Environment Setup Script

The `set-environment.sh` script automatically:
1. ✅ Validates `.env` file exists
2. ✅ Checks `ENVIRONMENT` variable is set
3. ✅ Selects environment-specific variables
4. ✅ Constructs `DATABASE_URL` with correct host
5. ✅ Generates `.env.active` for docker-compose
6. ✅ Displays current configuration

### Usage

```bash
# Make script executable
chmod +x set-environment.sh

# Run the script
./set-environment.sh
```

### Output

```
🚀 Setting up environment: dev
✅ Environment configured successfully!

📝 Configuration:
  - Environment: dev
  - Database Host: db
  - API URL: http://localhost
  - Log Level: DEBUG
  - Database URL: postgresql://postgres:****@db:5432/testdb

💾 Active configuration saved to .env.active
🐳 Run: docker-compose --env-file .env.active up -d
```

## Best Practices

### 1. Never Commit Sensitive Data
```bash
# .env files are in .gitignore
# Only .env.template is committed
```

### 2. Use Strong Passwords in Production
```bash
POSTGRES_PASSWORD=$(openssl rand -base64 32)
```

### 3. Environment-Specific Naming
```bash
# Development
.env.dev → localhost, debug logging

# Test
.env.test → test RDS, info logging

# Staging
.env.staging → staging RDS, warning logging

# Production
.env.prod → prod RDS, error logging, strong passwords
```

### 4. Validate Before Deployment
```bash
# Check configuration
./set-environment.sh

# Test connection
docker-compose --env-file .env.active config
```

### 5. Use AWS Secrets Manager in Production
```bash
# Store sensitive values in Secrets Manager
aws secretsmanager create-secret \
  --name hrms/prod/database \
  --secret-string '{"password":"xxx"}'

# Reference in ECS task definition
"secrets": [{
  "name": "POSTGRES_PASSWORD",
  "valueFrom": "arn:aws:secretsmanager:..."
}]
```

## Switching Environments

### Local Development
```bash
cp .env.template .env.dev
# Edit .env.dev with ENVIRONMENT=dev
ln -sf .env.dev .env
docker-compose up -d
```

### Testing
```bash
cp .env.template .env.test
# Edit .env.test with ENVIRONMENT=test, RDS endpoints
ln -sf .env.test .env
docker-compose up -d
```

### Staging/Production
```bash
# On EC2/ECS
cp .env.template .env.prod
nano .env.prod  # Set ENVIRONMENT=prod, production values
./set-environment.sh
docker-compose --env-file .env.active up -d
```

## Troubleshooting

### Problem: DATABASE_URL not working
```bash
# Check if DATABASE_URL is correctly constructed
echo $DATABASE_URL

# Verify host is reachable
ping $DB_HOST

# Test connection
docker exec -it hrms-api python -c "import os; print(os.getenv('DATABASE_URL'))"
```

### Problem: Wrong environment variables
```bash
# Regenerate .env.active
./set-environment.sh

# Check active configuration
cat .env.active

# Restart containers
docker-compose down
docker-compose --env-file .env.active up -d
```

### Problem: Environment not switching
```bash
# Ensure .env file is updated
cat .env | grep ENVIRONMENT

# Rerun setup script
./set-environment.sh

# Force rebuild
docker-compose build --no-cache
```

## Security Checklist

- ✅ All `.env*` files (except `.env.template`) are in `.gitignore`
- ✅ Production passwords are strong and unique
- ✅ AWS credentials are not in `.env` files (use IAM roles)
- ✅ Database endpoints are not public
- ✅ SSL/TLS enabled for all external connections
- ✅ Secrets Manager used for production credentials

## Additional Resources

- [Docker Compose Environment Variables](https://docs.docker.com/compose/environment-variables/)
- [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/)
- [12-Factor App Config](https://12factor.net/config)

---

**Last Updated**: November 2025  
**Version**: 1.0.0
