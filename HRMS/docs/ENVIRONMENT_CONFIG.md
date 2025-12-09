# Environment Configuration Guide

## Overview

This application uses environment variables to manage configuration and sensitive information. **NEVER commit the `.env` file to git.**

## Setup

### 1. Create Environment File

Copy the example file and customize it:

```bash
cp .env.example .env
```

### 2. Update Credentials

Edit `.env` with your actual values:

```bash
# Database Configuration
POSTGRES_USER=your_db_user
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=your_database_name

# API Configuration
PORT=8000
PYTHONUNBUFFERED=1

# Frontend Configuration
REACT_APP_API_URL=https://your-domain.com
```

### 3. Verify .gitignore

Ensure `.gitignore` includes:
```
.env
.env.local
.env.*.local
```

## Environment Variables Reference

### Database (PostgreSQL)

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `POSTGRES_USER` | Database username | `postgres` | Yes |
| `POSTGRES_PASSWORD` | Database password | `postgres` | Yes |
| `POSTGRES_DB` | Database name | `testdb` | Yes |

### Backend API (FastAPI)

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `PORT` | API server port | `8000` | No |
| `PYTHONUNBUFFERED` | Python output buffering | `1` | No |
| `DATABASE_URL` | Full database connection string | Auto-generated | No |

### Frontend (React)

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `REACT_APP_API_URL` | API base URL | `https://hrms.zamait.in` | Yes (Production) |

## Docker Compose Integration

Docker Compose automatically loads `.env` file from the project root. Variables are substituted using `${VARIABLE_NAME}` syntax with fallback defaults.

Example:
```yaml
environment:
  - POSTGRES_USER=${POSTGRES_USER:-postgres}
```

This means: Use `POSTGRES_USER` from `.env`, or default to `postgres` if not set.

## Production Deployment (EC2)

### Method 1: Create .env file on server

```bash
# SSH to EC2
ssh -i your-key.pem ec2-user@your-server

# Navigate to project
cd ~/aws-training/devops/hackathon/HRMS

# Create .env file
cat > .env << 'EOF'
POSTGRES_USER=prod_user
POSTGRES_PASSWORD=SecureP@ssw0rd123!
POSTGRES_DB=hrms_production
PORT=8000
REACT_APP_API_URL=https://hrms.zamait.in
EOF

# Set proper permissions
chmod 600 .env

# Restart containers
docker-compose up -d
```

### Method 2: Export environment variables

```bash
export POSTGRES_USER=prod_user
export POSTGRES_PASSWORD=SecureP@ssw0rd123!
export POSTGRES_DB=hrms_production

docker-compose up -d
```

### Method 3: Pass via command line

```bash
POSTGRES_USER=prod_user POSTGRES_PASSWORD=SecureP@ssw0rd123! docker-compose up -d
```

## Security Best Practices

### ✅ DO:

1. **Use strong passwords** (minimum 16 characters, mixed case, numbers, symbols)
2. **Keep .env in .gitignore** (already configured)
3. **Use different credentials** for dev/staging/production
4. **Rotate passwords** regularly
5. **Use secrets management** in production (AWS Secrets Manager, HashiCorp Vault)
6. **Set file permissions**: `chmod 600 .env`
7. **Share credentials securely** (encrypted channels, password managers)

### ❌ DON'T:

1. **Never commit .env** to git
2. **Never share .env** via email/Slack/chat
3. **Never use default passwords** in production
4. **Never hardcode credentials** in source code
5. **Never log sensitive values**
6. **Never use same password** across environments

## Local Development

For local development, you can use the defaults:

```bash
# Use .env.example as-is for local development
cp .env.example .env

# Start containers
docker-compose up -d
```

Default credentials (development only):
- User: `postgres`
- Password: `postgres`
- Database: `testdb`

## Troubleshooting

### Environment variables not loaded

1. **Check .env file exists**: `ls -la .env`
2. **Check file location**: Must be in same directory as `docker-compose.yml`
3. **Restart containers**: `docker-compose down && docker-compose up -d`
4. **Verify variables**: `docker-compose config` (shows resolved values)

### Connection errors

```bash
# Check DATABASE_URL is correct
docker exec hrms-api env | grep DATABASE_URL

# Test database connection
docker exec hrms-db psql -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT version();"
```

### Reset to defaults

```bash
# Remove .env to use defaults
rm .env

# Restart
docker-compose down && docker-compose up -d
```

## Advanced: Multiple Environments

### Development
```bash
.env.development
```

### Staging
```bash
.env.staging
```

### Production
```bash
.env.production
```

Load specific environment:
```bash
docker-compose --env-file .env.production up -d
```

## CI/CD Integration

For GitHub Actions / GitLab CI:

```yaml
# Set as secrets in repository settings
# Access via ${{ secrets.POSTGRES_PASSWORD }}

env:
  POSTGRES_USER: ${{ secrets.DB_USER }}
  POSTGRES_PASSWORD: ${{ secrets.DB_PASSWORD }}
  POSTGRES_DB: ${{ secrets.DB_NAME }}
```

## Support

If you encounter issues with environment configuration:
1. Check `.env.example` for required variables
2. Verify `.gitignore` excludes `.env`
3. Review `docker-compose.yml` for variable substitutions
4. Check application logs: `docker-compose logs`

---

**Remember**: Security is everyone's responsibility. Treat credentials with care! 🔐
