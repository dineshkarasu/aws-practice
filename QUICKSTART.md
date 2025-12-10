# 🚀 HRMS Quick Start Guide

## Prerequisites

- Docker and Docker Compose installed
- Ports 80, 8000, and 5432 available
- Linux/macOS or WSL on Windows

## First Time Setup

```bash
# Navigate to HRMS directory
cd /path/to/HRMS

# Make scripts executable
chmod +x start.sh stop.sh

# (Optional) Copy and customize environment variables
cp .env.example .env
```

## Start the Application

```bash
./start.sh
```

**OR manually:**

```bash
docker-compose up -d --build
```

## Access Points

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend** | http://localhost | React web application |
| **API Docs** | http://localhost/docs | Swagger API documentation |
| **API ReDoc** | http://localhost/redoc | Alternative API docs |
| **Health Check** | http://localhost/health | Service health status |
| **Direct API** | http://localhost:8000 | Direct backend access (if needed) |

## Common Commands

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f api      # Backend logs
docker-compose logs -f web      # Frontend logs
docker-compose logs -f nginx    # Nginx logs
docker-compose logs -f db       # Database logs
```

### Seed Initial Data
```bash
docker-compose exec api python seed_data.py
```

### Stop Application
```bash
./stop.sh

# OR manually
docker-compose down
```

### Restart Services
```bash
# All services
docker-compose restart

# Single service
docker-compose restart api
docker-compose restart web
docker-compose restart nginx
```

### Check Status
```bash
docker-compose ps
```

### Database Access
```bash
# Access PostgreSQL CLI
docker-compose exec db psql -U postgres -d hrmsdb

# Common SQL commands:
\dt              # List tables
\d employees     # Describe employees table
SELECT * FROM employees LIMIT 5;
```

### Clean Everything
```bash
# Stop and remove containers (keeps database data)
docker-compose down

# Remove everything including database data
docker-compose down -v
```

### Rebuild Services
```bash
# Rebuild all services
docker-compose up -d --build

# Rebuild single service
docker-compose up -d --build api
```

## Troubleshooting

### Port 80 Already in Use

Edit `docker-compose.yml`, change nginx ports:
```yaml
ports:
  - "8080:80"  # Change 80 to 8080
```
Access at: http://localhost:8080

### View Service Health
```bash
# Check health status
docker-compose ps

# Test API health
curl http://localhost/health
```

### Services Not Starting

1. Check logs: `docker-compose logs -f`
2. Ensure Docker is running
3. Check ports are available
4. Try clean rebuild: `docker-compose down -v && docker-compose up -d --build`

## Architecture

```
┌──────────────────────────────────────┐
│     Nginx Reverse Proxy (Port 80)   │
│         http://localhost             │
└────────────┬─────────────────────────┘
             │
    ┌────────┴────────┐
    │                 │
┌───▼──────┐    ┌────▼─────┐
│  React   │    │ FastAPI  │
│ Frontend │    │ Backend  │
│ (web:80) │    │ (api:8000)│
└──────────┘    └────┬─────┘
                     │
              ┌──────▼───────┐
              │  PostgreSQL  │
              │  (db:5432)   │
              └──────────────┘
```

## Default Credentials

### Database
- **Host**: localhost:5432 (external) or db:5432 (internal)
- **Database**: hrmsdb
- **Username**: postgres
- **Password**: postgres

## File Structure

```
HRMS/
├── docker-compose.yml      # Service orchestration
├── nginx.conf              # Nginx routing configuration
├── .env.example            # Environment template
├── start.sh                # Start script
├── stop.sh                 # Stop script
├── README.md               # Main documentation
├── QUICKSTART.md           # This file
├── README-DOCKER.md        # Detailed Docker guide
├── hrms-api/               # FastAPI backend
│   ├── Dockerfile
│   ├── main.py
│   ├── database.py
│   ├── models/
│   └── routers/
└── hrms-web/               # React frontend
    ├── Dockerfile
    ├── src/
    └── public/
```

## Need Help?

1. Check logs: `docker-compose logs -f`
2. View status: `docker-compose ps`
3. Read full documentation: `README-DOCKER.md`
