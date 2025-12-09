# HRMS Multi-Environment Configuration Guide

This guide explains how to deploy the HRMS application to different environments (dev, test, staging, prod).

## 🌍 Available Environments

| Environment | Purpose | Database | API URL |
|------------|---------|----------|---------|
| **dev** | Local development | Local PostgreSQL (Docker) | http://localhost |
| **test** | Automated testing | Test RDS instance | https://test-api.hrms.zamait.in |
| **staging** | Pre-production testing | Staging RDS instance | https://staging-api.hrms.zamait.in |
| **prod** | Production | Production RDS instance | https://api.hrms.zamait.in |

## 📁 Environment Files

Each environment has its own `.env` file:
- `.env.dev` - Development configuration
- `.env.test` - Testing configuration
- `.env.staging` - Staging configuration
- `.env.prod` - Production configuration

## 🚀 Quick Start

### Windows (PowerShell)
```powershell
# Deploy to development
.\deploy-env.ps1 dev

# Deploy to testing
.\deploy-env.ps1 test

# Deploy to staging
.\deploy-env.ps1 staging

# Deploy to production (requires confirmation)
.\deploy-env.ps1 prod
```

### Linux/Mac (Bash)
```bash
# Make script executable
chmod +x deploy-env.sh

# Deploy to development
./deploy-env.sh dev

# Deploy to testing
./deploy-env.sh test

# Deploy to staging
./deploy-env.sh staging

# Deploy to production (requires confirmation)
./deploy-env.sh prod
```

## 📊 Environment Logging

### Backend API Logs
When the API starts, you'll see:
```
🚀 Starting HRMS API in DEV environment
🌍 Environment: DEV
📊 Connecting to DEV database
🔗 Database URL: postgresql://postgres@****
✅ Database tables created successfully in DEV environment
```

### Frontend Web Logs (Browser Console)
When the web app loads, check the browser console:
```
🌐 HRMS Web running in DEV environment
📡 API Base URL: http://localhost
🔧 Environment: dev
```

### API Request Logs
Every API request is logged:
```
📡 [DEV] API Request: GET /api/v1/employees/
✅ [DEV] API Response: /api/v1/employees/
```

## 🔧 Manual Deployment

If you want to manually deploy with a specific environment file:

```bash
# Stop containers
docker-compose --env-file .env.dev down

# Build and start with specific environment
docker-compose --env-file .env.dev up -d --build

# Check logs
docker-compose --env-file .env.dev logs -f
```

## 🔍 Verifying Environment

### Check API Health Endpoint
```bash
curl http://localhost/health
```

Response:
```json
{
  "status": "healthy",
  "service": "HRMS API",
  "environment": "dev"
}
```

### Check Frontend
1. Open the application in your browser
2. Open browser DevTools (F12)
3. Check the Console tab for environment logs
4. Check the footer for environment badge

## 📝 Environment Configuration

Each `.env` file contains:

```bash
# Environment identifier
ENVIRONMENT=dev

# Database configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_password
POSTGRES_DB=database_name
DATABASE_URL=postgresql://user:pass@host:5432/db

# Frontend configuration
REACT_APP_API_URL=http://localhost
REACT_APP_ENVIRONMENT=dev

# Logging level
LOG_LEVEL=DEBUG  # DEBUG for dev, INFO for test, WARNING for staging, ERROR for prod
```

## 🎨 Environment Indicators

The frontend displays environment badges with color coding:
- 🟢 **DEV** - Green
- 🔵 **TEST** - Blue
- 🟠 **STAGING** - Orange
- 🔴 **PROD** - Red

## 🛠️ Useful Commands

### View logs for specific environment
```bash
docker-compose --env-file .env.dev logs -f
```

### Stop specific environment
```bash
docker-compose --env-file .env.dev down
```

### Restart specific environment
```bash
docker-compose --env-file .env.dev restart
```

### Check container status
```bash
docker-compose --env-file .env.dev ps
```

### Access database (development only)
```bash
docker exec -it hrms-db psql -U postgres -d testdb
```

### Seed development data
```bash
docker exec -it hrms-api python seed_data.py
```

## ⚠️ Production Deployment Notes

1. **Database**: Production uses AWS RDS, not local PostgreSQL
2. **SSL**: Ensure SSL certificates are configured for HTTPS
3. **Secrets**: Never commit production passwords to git
4. **Confirmation**: Script requires "yes" confirmation for prod deployment
5. **Monitoring**: Check CloudWatch logs after deployment

## 🔒 Security Best Practices

1. **Never commit `.env` files** - They contain sensitive data
2. **Use strong passwords** for production databases
3. **Rotate credentials** regularly
4. **Use AWS Secrets Manager** for production secrets
5. **Enable database encryption** for prod/staging

## 📚 Additional Resources

- [Docker Compose Guide](./docs/DOCKER_COMPOSE_GUIDE.md)
- [EC2 Deployment Guide](./docs/EC2_DEPLOYMENT_GUIDE.md)
- [Environment Setup](./docs/ENVIRONMENT_SETUP.md)

## 🆘 Troubleshooting

### Environment not showing correctly
1. Check if correct `.env` file is loaded
2. Verify environment variables in containers:
   ```bash
   docker exec -it hrms-api env | grep ENVIRONMENT
   ```

### Database connection issues
1. Verify DATABASE_URL in `.env` file
2. Check database logs:
   ```bash
   docker-compose logs db
   ```

### Frontend showing wrong environment
1. Rebuild with correct build args:
   ```bash
   docker-compose --env-file .env.dev up -d --build web
   ```
2. Clear browser cache and reload

## 📞 Support

For issues or questions:
- Check the logs first: `docker-compose logs -f`
- Review environment configuration in `.env` files
- Verify database connectivity
- Check AWS RDS security groups (for test/staging/prod)
