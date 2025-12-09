# HRMS Environment-Aware Deployment Script for Windows PowerShell
# Usage: .\deploy-env.ps1 [dev|test|staging|prod]

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('dev','test','staging','prod')]
    [string]$Environment
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🚀 HRMS Environment-Aware Deployment" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "✅ Environment: $($Environment.ToUpper())" -ForegroundColor Green
Write-Host ""

$envFile = ".env.$Environment"

# Check if environment file exists
if (-not (Test-Path $envFile)) {
    Write-Host "❌ Error: Environment file '$envFile' not found" -ForegroundColor Red
    Write-Host "Please create $envFile with appropriate configuration" -ForegroundColor Yellow
    exit 1
}

Write-Host "📋 Environment file: $envFile" -ForegroundColor Blue
Write-Host ""

# Production warning
if ($Environment -eq "prod") {
    Write-Host "⚠️  WARNING: You are about to deploy to PRODUCTION!" -ForegroundColor Yellow
    Write-Host ""
    $confirm = Read-Host "Are you sure you want to continue? (yes/no)"
    if ($confirm -ne "yes") {
        Write-Host "Deployment cancelled." -ForegroundColor Yellow
        exit 0
    }
}

# Stop existing containers
Write-Host "🛑 Step 1/4: Stopping existing containers..." -ForegroundColor Cyan
docker-compose --env-file $envFile down -v 2>$null
Write-Host "✅ Containers stopped" -ForegroundColor Green
Write-Host ""

# Build and start containers
Write-Host "🔨 Step 2/4: Building and starting containers..." -ForegroundColor Cyan
docker-compose --env-file $envFile up -d --build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Deployment failed during build" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Containers built and started" -ForegroundColor Green
Write-Host ""

# Wait for services to be healthy
Write-Host "⏳ Step 3/4: Waiting for services to be healthy..." -ForegroundColor Cyan
Start-Sleep -Seconds 15

# Check container status
Write-Host "📊 Step 4/4: Checking container status..." -ForegroundColor Cyan
docker-compose --env-file $envFile ps
Write-Host ""

# Get environment-specific URLs
switch ($Environment) {
    "dev" {
        $frontendUrl = "http://localhost"
        $apiDocsUrl = "http://localhost/docs"
    }
    "test" {
        $frontendUrl = "https://test.hrms.zamait.in"
        $apiDocsUrl = "https://test-api.hrms.zamait.in/docs"
    }
    "staging" {
        $frontendUrl = "https://staging.hrms.zamait.in"
        $apiDocsUrl = "https://staging-api.hrms.zamait.in/docs"
    }
    "prod" {
        $frontendUrl = "https://hrms.zamait.in"
        $apiDocsUrl = "https://api.hrms.zamait.in/docs"
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "✅ DEPLOYMENT SUCCESSFUL!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌍 Environment: $($Environment.ToUpper())" -ForegroundColor Yellow
Write-Host ""
Write-Host "📍 Access URLs:" -ForegroundColor Blue
Write-Host "  Frontend:    $frontendUrl"
Write-Host "  API Docs:    $apiDocsUrl"
Write-Host "  Health:      $frontendUrl/health"
Write-Host ""
Write-Host "📝 Useful Commands:" -ForegroundColor Blue
Write-Host "  View logs:        docker-compose --env-file $envFile logs -f"
Write-Host "  Stop app:         docker-compose --env-file $envFile down"
Write-Host "  Restart app:      docker-compose --env-file $envFile restart"
Write-Host "  Check status:     docker-compose --env-file $envFile ps"
Write-Host ""

if ($Environment -eq "dev") {
    Write-Host "🔧 Development Commands:" -ForegroundColor Blue
    Write-Host "  Seed data:        docker exec -it hrms-api python seed_data.py"
    Write-Host "  Access DB:        docker exec -it hrms-db psql -U postgres -d testdb"
    Write-Host ""
}

Write-Host "🎉 Happy coding!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
