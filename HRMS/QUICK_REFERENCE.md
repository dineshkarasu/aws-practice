# 🚀 HRMS Environment Quick Reference

## Deployment Commands

```powershell
# Windows PowerShell
.\deploy-env.ps1 dev       # Development
.\deploy-env.ps1 test      # Testing
.\deploy-env.ps1 staging   # Staging
.\deploy-env.ps1 prod      # Production
```

```bash
# Linux/Mac Bash
./deploy-env.sh dev        # Development
./deploy-env.sh test       # Testing
./deploy-env.sh staging    # Staging
./deploy-env.sh prod       # Production
```

## Environment Files
- `.env.dev` - Development (local DB)
- `.env.test` - Testing (test RDS)
- `.env.staging` - Staging (staging RDS)
- `.env.prod` - Production (prod RDS)

## What Gets Logged

### Backend API Console
```
🚀 Starting HRMS API in [ENV] environment
📊 Connecting to [ENV] database
✅ Database initialized in [ENV] environment
```

### Frontend Browser Console
```
🌐 HRMS Web running in [ENV] environment
📡 API Base URL: [URL]
📡 [ENV] API Request: GET /api/v1/employees/
✅ [ENV] API Response: /api/v1/employees/
```

### Health Check API Response
```json
{
  "status": "healthy",
  "service": "HRMS API",
  "environment": "dev"
}
```

## Environment Badges (Frontend Footer)
- 🟢 DEV (Green)
- 🔵 TEST (Blue)  
- 🟠 STAGING (Orange)
- 🔴 PROD (Red)

## Useful Commands

```bash
# View logs
docker-compose --env-file .env.[ENV] logs -f

# Stop application
docker-compose --env-file .env.[ENV] down

# Restart application
docker-compose --env-file .env.[ENV] restart

# Check status
docker-compose --env-file .env.[ENV] ps

# Verify environment variable
docker exec -it hrms-api env | grep ENVIRONMENT
```

## Environment URLs

| Environment | Frontend | API Docs |
|------------|----------|----------|
| dev | http://localhost | http://localhost/docs |
| test | https://test.hrms.zamait.in | https://test-api.hrms.zamait.in/docs |
| staging | https://staging.hrms.zamait.in | https://staging-api.hrms.zamait.in/docs |
| prod | https://hrms.zamait.in | https://api.hrms.zamait.in/docs |

## Log Levels by Environment
- **dev**: DEBUG
- **test**: INFO
- **staging**: WARNING
- **prod**: ERROR
