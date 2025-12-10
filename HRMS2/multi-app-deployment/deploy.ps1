# Multi-App Deployment Script for Windows PowerShell
# Deploys HRMS (App1) and App2 on a single server

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🚀 Multi-App Deployment" -ForegroundColor Cyan
Write-Host "HRMS (App1) + App2 (Node.js)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Host "⚠️  .env file not found. Creating from template..." -ForegroundColor Yellow
    Copy-Item .env.template .env
    Write-Host "✅ .env file created" -ForegroundColor Green
    Write-Host ""
    Write-Host "⚠️  IMPORTANT: Please edit .env file with your actual values!" -ForegroundColor Yellow
    Write-Host "   notepad .env" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter after editing .env file to continue"
}

# Load environment variables
Get-Content .env | ForEach-Object {
    if ($_ -match '^([^#][^=]+)=(.*)$') {
        [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
    }
}

$APP1_DOMAIN = if ($env:APP1_DOMAIN) { $env:APP1_DOMAIN } else { "dinesh-app1.zamait.in" }
$APP2_DOMAIN = if ($env:APP2_DOMAIN) { $env:APP2_DOMAIN } else { "dinesh-app2.zamait.in" }
$SSL_ENABLED = if ($env:SSL_ENABLED) { $env:SSL_ENABLED } else { "false" }
$ENVIRONMENT = if ($env:ENVIRONMENT) { $env:ENVIRONMENT } else { "production" }

Write-Host "📋 Deployment Configuration:" -ForegroundColor Blue
Write-Host "   Environment: $ENVIRONMENT"
Write-Host "   App1 (HRMS): $APP1_DOMAIN"
Write-Host "   App2 (Node): $APP2_DOMAIN"
Write-Host "   SSL Enabled: $SSL_ENABLED"
Write-Host ""

# Check if Docker is installed
Write-Host "🔍 Step 1/6: Checking Docker installation..." -ForegroundColor Cyan
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not installed. Please install Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Check if Docker Compose is installed
try {
    $composeVersion = docker-compose --version
    Write-Host "✅ Docker Compose: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose is not installed." -ForegroundColor Red
    exit 1
}
Write-Host ""

# Verify application directories exist
Write-Host "📂 Step 2/6: Verifying application directories..." -ForegroundColor Cyan
if (-not (Test-Path "..\HRMS")) {
    Write-Host "❌ HRMS directory not found at ..\HRMS" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path "..\app2")) {
    Write-Host "❌ app2 directory not found at ..\app2" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Application directories found" -ForegroundColor Green
Write-Host ""

# Stop existing containers
Write-Host "🛑 Step 3/6: Stopping existing containers..." -ForegroundColor Cyan
docker-compose down -v 2>$null
Write-Host "✅ Existing containers stopped" -ForegroundColor Green
Write-Host ""

# Build and start containers
Write-Host "🔨 Step 4/6: Building Docker images..." -ForegroundColor Cyan
docker-compose build --no-cache
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to build images" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Images built successfully" -ForegroundColor Green
Write-Host ""

Write-Host "🚀 Step 5/6: Starting containers..." -ForegroundColor Cyan
docker-compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to start containers" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Containers started" -ForegroundColor Green
Write-Host ""

# Wait for services to be healthy
Write-Host "⏳ Step 6/6: Waiting for services to be healthy..." -ForegroundColor Cyan
Start-Sleep -Seconds 20

# Check container status
Write-Host ""
Write-Host "📊 Container Status:" -ForegroundColor Blue
docker-compose ps
Write-Host ""

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "✅ DEPLOYMENT SUCCESSFUL!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

if ($SSL_ENABLED -eq "true") {
    Write-Host "🌐 Applications are accessible at:" -ForegroundColor Blue
    Write-Host ""
    Write-Host "  📱 HRMS (App1):  https://$APP1_DOMAIN"
    Write-Host "     - API Docs:    https://$APP1_DOMAIN/docs"
    Write-Host "     - Health:      https://$APP1_DOMAIN/health"
    Write-Host ""
    Write-Host "  📱 App2 (Node):  https://$APP2_DOMAIN"
    Write-Host "     - Health:      https://$APP2_DOMAIN/api/health"
    Write-Host "     - Message:     https://$APP2_DOMAIN/api/message"
} else {
    Write-Host "⚠️  SSL is not enabled. Applications are accessible at:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  For testing (update DNS or hosts file):"
    Write-Host "  📱 HRMS (App1):  http://$APP1_DOMAIN"
    Write-Host "  📱 App2 (Node):  http://$APP2_DOMAIN"
    Write-Host ""
    Write-Host "🔒 To enable SSL (HTTPS) on Linux server:" -ForegroundColor Yellow
    Write-Host "   1. Ensure DNS A records point to your server IP"
    Write-Host "   2. Run: ./setup-ssl.sh"
}

Write-Host ""
Write-Host "🗄️  Database:" -ForegroundColor Blue
Write-Host "   - PostgreSQL (HRMS internal only)"
Write-Host "   - Volume: hrms-postgres-data"
Write-Host ""
Write-Host "📝 Useful Commands:" -ForegroundColor Blue
Write-Host "   View logs (all):     docker-compose logs -f"
Write-Host "   View logs (app1):    docker-compose logs -f hrms-api hrms-web"
Write-Host "   View logs (app2):    docker-compose logs -f app2"
Write-Host "   View logs (nginx):   docker-compose logs -f nginx"
Write-Host "   Stop all:            docker-compose down"
Write-Host "   Restart all:         docker-compose restart"
Write-Host "   Check status:        docker-compose ps"
Write-Host ""
Write-Host "🎉 Happy coding!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
