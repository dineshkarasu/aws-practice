# 🧪 Testing the Environment Configuration

This guide helps you verify that the environment-specific configuration is working correctly.

## 🚀 Quick Test (Development)

### Step 1: Deploy to Development
```powershell
# Windows
.\deploy-env.ps1 dev

# Linux/Mac
./deploy-env.sh dev
```

### Step 2: Verify Backend Logs
```bash
docker logs hrms-api
```

**Expected output:**
```
🚀 Starting HRMS API in DEV environment
🌍 Environment: DEV
📊 Connecting to DEV database
🔗 Database URL: postgresql://postgres@****
✅ Database tables created successfully in DEV environment
```

### Step 3: Check Health Endpoint
```bash
curl http://localhost/health
```

**Expected response:**
```json
{
  "status": "healthy",
  "service": "HRMS API",
  "environment": "dev"
}
```

### Step 4: Check Frontend Console
1. Open http://localhost in your browser
2. Press **F12** to open DevTools
3. Go to **Console** tab

**Expected console logs:**
```
🌐 HRMS Web running in DEV environment
📡 API Base URL: http://localhost
🔧 Environment: dev
```

### Step 5: Test API Calls
1. In the browser, navigate to different pages (Employees, Departments, Leaves)
2. Check the Console tab for API request logs

**Expected logs for each API call:**
```
📡 [DEV] API Request: GET /api/v1/employees/
✅ [DEV] API Response: /api/v1/employees/
```

### Step 6: Check UI Footer
1. Scroll to the bottom of the page
2. Check the footer

**Expected footer text:**
```
Environment: DEV | API: http://localhost
```
- The "DEV" badge should be **green**

## 🧪 Testing Different Environments

### Test Environment
```powershell
.\deploy-env.ps1 test
```

**Verify:**
- Backend logs show: `🚀 Starting HRMS API in TEST environment`
- Health endpoint returns: `"environment": "test"`
- Console shows: `🌐 HRMS Web running in TEST environment`
- API logs show: `📡 [TEST] API Request: ...`
- Footer badge is **blue**

### Staging Environment
```powershell
.\deploy-env.ps1 staging
```

**Verify:**
- Backend logs show: `🚀 Starting HRMS API in STAGING environment`
- Health endpoint returns: `"environment": "staging"`
- Console shows: `🌐 HRMS Web running in STAGING environment`
- API logs show: `📡 [STAGING] API Request: ...`
- Footer badge is **orange**

### Production Environment
```powershell
.\deploy-env.ps1 prod
```

**Verify:**
- Script asks for confirmation: `Are you sure you want to continue? (yes/no)`
- Backend logs show: `🚀 Starting HRMS API in PROD environment`
- Health endpoint returns: `"environment": "prod"`
- Console shows: `🌐 HRMS Web running in PROD environment`
- API logs show: `📡 [PROD] API Request: ...`
- Footer badge is **red**

## 🔍 Detailed Verification Commands

### Check Environment Variable in API Container
```bash
docker exec -it hrms-api env | grep ENVIRONMENT
```
**Expected:** `ENVIRONMENT=dev` (or test/staging/prod)

### Check All Environment Variables
```bash
docker exec -it hrms-api env
```

### View Real-time Logs
```bash
docker-compose --env-file .env.dev logs -f
```

### Check Database Connection
```bash
docker exec -it hrms-api python -c "import os; print(f'DB: {os.getenv(\"DATABASE_URL\")}')"
```

### Inspect Container
```bash
docker inspect hrms-api | grep -A 10 "Env"
```

## ✅ Success Criteria

Your implementation is working correctly if:

- [ ] Backend logs show correct environment on startup
- [ ] Database connection logs show correct environment
- [ ] Health endpoint returns correct environment in JSON
- [ ] Frontend console logs show correct environment
- [ ] All API requests are logged with environment tag
- [ ] Footer displays correct environment with proper color
- [ ] Different .env files load different configurations
- [ ] Environment badge colors match (green/blue/orange/red)
- [ ] Production deployment requires confirmation
- [ ] Manual deployment with `--env-file` works

## 🐛 Troubleshooting

### Environment Not Showing
```bash
# Rebuild containers
docker-compose --env-file .env.dev up -d --build

# Check if environment variable is set
docker exec -it hrms-api printenv ENVIRONMENT
```

### Frontend Shows Wrong Environment
```bash
# Rebuild web container specifically
docker-compose --env-file .env.dev up -d --build web

# Clear browser cache and hard reload (Ctrl+Shift+R)
```

### Database Connection Issues
```bash
# Check database logs
docker logs hrms-db

# Verify DATABASE_URL
docker exec -it hrms-api printenv DATABASE_URL
```

### Logs Not Appearing
```bash
# Check if containers are running
docker ps

# View all logs
docker-compose logs

# View specific service logs
docker-compose logs api
docker-compose logs web
```

## 📊 Test Results Template

| Test | Expected | Result | Status |
|------|----------|--------|--------|
| Backend startup log shows environment | ✅ | ✅ | PASS |
| Database connection log shows environment | ✅ | ✅ | PASS |
| Health endpoint returns environment | ✅ | ✅ | PASS |
| Frontend console shows environment | ✅ | ✅ | PASS |
| API requests logged with environment | ✅ | ✅ | PASS |
| Footer displays environment badge | ✅ | ✅ | PASS |
| Badge color matches environment | ✅ | ✅ | PASS |
| Production requires confirmation | ✅ | ✅ | PASS |

## 🎉 Next Steps

Once all tests pass:
1. Commit your changes to git
2. Update your CI/CD pipeline to use environment-specific deployments
3. Configure AWS RDS endpoints for test/staging/prod
4. Set up proper SSL certificates for non-dev environments
5. Configure monitoring and logging services

## 📞 Support

If tests fail:
1. Check the troubleshooting section above
2. Review `ENVIRONMENT_DEPLOYMENT_GUIDE.md`
3. Check Docker logs for error messages
4. Verify .env files are properly formatted
