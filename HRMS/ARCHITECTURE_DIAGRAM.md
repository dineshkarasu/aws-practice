# 🏗️ Environment Architecture Diagram

## System Architecture with Multi-Environment Support

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          DEPLOYMENT LAYER                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐                │
│  │.env.dev  │  │.env.test │  │.env.     │  │.env.prod │                │
│  │          │  │          │  │staging   │  │          │                │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘                │
│       │             │             │             │                       │
│       └─────────────┴─────────────┴─────────────┘                       │
│                           │                                              │
│                           ▼                                              │
│              ┌─────────────────────────┐                                 │
│              │  deploy-env.sh/.ps1     │                                 │
│              │  (Environment Selector) │                                 │
│              └─────────────────────────┘                                 │
│                           │                                              │
└───────────────────────────┼──────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       DOCKER COMPOSE LAYER                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  docker-compose --env-file .env.[ENVIRONMENT] up                         │
│                                                                           │
│  ┌────────────────────────────────────────────────────────────────┐     │
│  │  Environment Variables Injection:                              │     │
│  │  • ENVIRONMENT=${ENVIRONMENT}                                  │     │
│  │  • DATABASE_URL=${DATABASE_URL}                                │     │
│  │  • REACT_APP_API_URL=${REACT_APP_API_URL}                     │     │
│  │  • REACT_APP_ENVIRONMENT=${ENVIRONMENT}                        │     │
│  │  • LOG_LEVEL=${LOG_LEVEL}                                      │     │
│  └────────────────────────────────────────────────────────────────┘     │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
                            │
            ┌───────────────┴───────────────┐
            │                               │
            ▼                               ▼
┌──────────────────────┐         ┌──────────────────────┐
│   WEB CONTAINER      │         │   API CONTAINER      │
├──────────────────────┤         ├──────────────────────┤
│                      │         │                      │
│  React App           │         │  FastAPI App         │
│  ┌────────────────┐  │         │  ┌────────────────┐  │
│  │ BUILD TIME:    │  │         │  │ RUNTIME:       │  │
│  │ • REACT_APP_   │  │         │  │ • ENVIRONMENT  │  │
│  │   ENVIRONMENT  │  │         │  │ • DATABASE_URL │  │
│  │ • REACT_APP_   │  │         │  │ • LOG_LEVEL    │  │
│  │   API_URL      │  │         │  └────────────────┘  │
│  └────────────────┘  │         │                      │
│         │            │         │         │            │
│         ▼            │         │         ▼            │
│  ┌────────────────┐  │         │  ┌────────────────┐  │
│  │ App.js         │  │         │  │ main.py        │  │
│  │ • console.log  │  │         │  │ • print logs   │  │
│  │   environment  │  │         │  │ • environment  │  │
│  │ • Display in   │  │         │  │   in health    │  │
│  │   footer       │  │         │  └────────────────┘  │
│  └────────────────┘  │         │                      │
│         │            │         │  ┌────────────────┐  │
│         ▼            │         │  │ database.py    │  │
│  ┌────────────────┐  │         │  │ • print DB     │  │
│  │ api.js         │  │         │  │   connection   │  │
│  │ • Interceptors │  │         │  │   logs         │  │
│  │ • Log API      │  │         │  └────────────────┘  │
│  │   requests     │  │         │         │            │
│  └────────────────┘  │         │         ▼            │
│                      │         │  ┌────────────────┐  │
└──────────────────────┘         │  │ PostgreSQL     │  │
            │                    │  │ Connection     │  │
            │                    │  └────────────────┘  │
            │                    └──────────┬───────────┘
            │                               │
            └───────────────┬───────────────┘
                            │
                            ▼
                  ┌──────────────────┐
                  │  DATABASE        │
                  ├──────────────────┤
                  │  dev:     db     │
                  │  test:    RDS    │
                  │  staging: RDS    │
                  │  prod:    RDS    │
                  └──────────────────┘
```

## Logging Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     STARTUP SEQUENCE                             │
└─────────────────────────────────────────────────────────────────┘

1. DEPLOYMENT
   ├─ User runs: .\deploy-env.ps1 dev
   ├─ Script loads: .env.dev
   └─ Docker Compose starts containers with environment variables

2. API CONTAINER STARTUP
   ├─ main.py lifespan event:
   │  └─ "🚀 Starting HRMS API in DEV environment"
   │  └─ "🌍 Environment: DEV"
   ├─ database.py initialization:
   │  └─ "📊 Connecting to DEV database"
   │  └─ "🔗 Database URL: postgresql://postgres@****"
   └─ init_db():
      └─ "✅ Database tables created successfully in DEV environment"

3. WEB CONTAINER STARTUP
   ├─ React app builds with environment variables
   └─ Nginx serves built files

4. BROWSER LOADS APPLICATION
   ├─ App.js useEffect runs:
   │  └─ console.log("🌐 HRMS Web running in DEV environment")
   │  └─ console.log("📡 API Base URL: http://localhost")
   │  └─ console.log("🔧 Environment: dev")
   └─ Footer displays: "Environment: DEV | API: http://localhost"

5. USER INTERACTS
   ├─ User clicks on "Employees"
   ├─ API request triggered
   ├─ api.js interceptor logs:
   │  └─ console.log("📡 [DEV] API Request: GET /api/v1/employees/")
   └─ Response interceptor logs:
      └─ console.log("✅ [DEV] API Response: /api/v1/employees/")

6. HEALTH CHECK
   └─ curl http://localhost/health
      └─ Returns: {"status": "healthy", "service": "HRMS API", "environment": "dev"}
```

## Environment Variable Flow

```
.env.dev File                  Docker Compose              Containers
┌──────────────┐              ┌──────────────┐           ┌──────────────┐
│ ENVIRONMENT= │              │ environment: │           │ process.env. │
│ dev          │─────────────▶│ ${ENVIRONMENT│──────────▶│ ENVIRONMENT  │
│              │              │ :-dev}       │           │ = "dev"      │
│              │              │              │           │              │
│ DATABASE_URL=│              │ environment: │           │ os.getenv(   │
│ postgresql://│─────────────▶│ ${DATABASE_  │──────────▶│ "DATABASE_   │
│ ...          │              │ URL}         │           │ URL")        │
│              │              │              │           │              │
│ REACT_APP_   │              │ args:        │           │ REACT_APP_   │
│ ENVIRONMENT= │─────────────▶│ - REACT_APP_ │──────────▶│ ENVIRONMENT  │
│ dev          │              │   ENVIRONMENT│  (BUILD)  │ = "dev"      │
│              │              │              │           │              │
│ LOG_LEVEL=   │              │ environment: │           │ os.getenv(   │
│ DEBUG        │─────────────▶│ ${LOG_LEVEL  │──────────▶│ "LOG_LEVEL") │
│              │              │ :-DEBUG}     │           │              │
└──────────────┘              └──────────────┘           └──────────────┘
```

## Environment Badge Colors

```
┌──────────────────────────────────────────────────────────┐
│              FRONTEND FOOTER DISPLAY                      │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  DEV Environment:                                         │
│  ╔═══════════════════════════════════════╗               │
│  ║ Environment: 🟢 DEV | API: http://... ║               │
│  ╚═══════════════════════════════════════╝               │
│                                                           │
│  TEST Environment:                                        │
│  ╔═══════════════════════════════════════╗               │
│  ║ Environment: 🔵 TEST | API: https://..║               │
│  ╚═══════════════════════════════════════╝               │
│                                                           │
│  STAGING Environment:                                     │
│  ╔═══════════════════════════════════════╗               │
│  ║ Environment: 🟠 STAGING | API: https:║               │
│  ╚═══════════════════════════════════════╝               │
│                                                           │
│  PROD Environment:                                        │
│  ╔═══════════════════════════════════════╗               │
│  ║ Environment: 🔴 PROD | API: https://..║               │
│  ╚═══════════════════════════════════════╝               │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

## Complete Request Flow with Environment Logging

```
User Action → Frontend → API → Database
    │            │        │        │
    ▼            ▼        ▼        ▼
   Click ──▶ React ──▶ FastAPI ─▶ PostgreSQL
              │          │
              │          │
   Console:   │          │     API Console:
   ┌──────────┴────┐     │     ┌─────────────────┐
   │ 📡 [DEV] API  │     │     │ Processing      │
   │ Request:      │     │     │ request in DEV  │
   │ GET /api/v1/  │     │     │ environment     │
   │ employees/    │     │     └─────────────────┘
   └───────────────┘     │
                         │
   ┌───────────────┐     │
   │ ✅ [DEV] API  │◀────┘
   │ Response:     │
   │ Status 200    │
   └───────────────┘
```

## Security & Configuration Flow

```
┌─────────────────────────────────────────────────────────┐
│                  SECURITY LAYERS                         │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  .gitignore                                              │
│  ┌────────────────────────────────────────┐             │
│  │ .env*  (All environment files)         │             │
│  │ *.pem  (SSL certificates)              │             │
│  │ *.key  (Private keys)                  │             │
│  └────────────────────────────────────────┘             │
│                                                          │
│  Environment Files (NOT in git)                          │
│  ┌────────────────────────────────────────┐             │
│  │ .env.dev      → Local DB               │             │
│  │ .env.test     → Test RDS               │             │
│  │ .env.staging  → Staging RDS            │             │
│  │ .env.prod     → Production RDS         │             │
│  └────────────────────────────────────────┘             │
│                                                          │
│  Template (IN git)                                       │
│  ┌────────────────────────────────────────┐             │
│  │ .env.template → Examples/Docs          │             │
│  └────────────────────────────────────────┘             │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

This architecture ensures:
✅ Clear environment separation
✅ Comprehensive logging at all levels
✅ Easy environment switching
✅ Security through .gitignore
✅ Visual feedback for users
✅ Audit trail for debugging
