# HRMS Docker Deployment Guide

## Overview

This guide explains how to run the HRMS application using Docker Compose without requiring DNS records. The application will be accessible via `http://localhost`.

## Architecture

```
┌─────────────────────────────────────────────────┐
│              Nginx (Port 80)                    │
│         http://localhost                        │
└───────────────┬─────────────────────────────────┘
                │
    ┌───────────┴──────────────┐
    │                          │
┌───▼────────┐         ┌──────▼──────┐
│   React    │         │   FastAPI   │
│  Frontend  │         │   Backend   │
│  (Port 80) │         │  (Port 8000)│
└────────────┘         └──────┬──────┘
                              │
                       ┌──────▼──────┐
                       │ PostgreSQL  │
                       │ (Port 5432) │
                       └─────────────┘
```

## Prerequisites

- Docker Desktop installed and running
- Docker Compose (included with Docker Desktop)
- Ports 80, 8000, and 5432 available on your machine

## Quick Start

### 1. Build and Start All Services

```bash
# Navigate to the HRMS directory
cd /path/to/HRMS

# Make scripts executable
chmod +x start.sh stop.sh

# Start all services
./start.sh

# OR manually
docker-compose up -d --build
```

### 2. Check Service Status

```bash
# View running containers
docker-compose ps

# View logs from all services
docker-compose logs -f

# View logs from specific service
docker-compose logs -f api
docker-compose logs -f web
docker-compose logs -f nginx
```

### 3. Seed Initial Data (Optional)

```bash
# Run the seed script to populate initial data
docker-compose exec api python seed_data.py
```

### 4. Access the Application

- **Frontend**: http://localhost
- **API Documentation**: http://localhost/docs
- **API Health Check**: http://localhost/health
- **Direct API Access**: http://localhost:8000 (if needed)

## Service Details

### Nginx (Reverse Proxy)
- **Port**: 80
- **Routes**:
  - `/` → React Frontend
  - `/api/*` → FastAPI Backend
  - `/docs` → API Documentation
  - `/redoc` → API ReDoc
  - `/health` → Health Check

### FastAPI Backend
- **Internal Port**: 8000
- **Exposed Port**: 8000 (for direct access)
- **Database**: Connects to PostgreSQL container
- **Environment**: Development mode

### React Frontend
- **Internal Port**: 80
- **Served by**: Nginx
- **API Calls**: Proxied through Nginx to backend

### PostgreSQL Database
- **Port**: 5432
- **Database**: hrmsdb
- **User**: postgres
- **Password**: postgres
- **Persistent Storage**: Docker volume `postgres_data`

## Common Commands

### Start Services

```bash
# Start in background
docker-compose up -d

# Start with logs visible
docker-compose up

# Rebuild and start
docker-compose up -d --build
```

### Stop Services

```bash
# Stop all services
docker-compose stop

# Stop and remove containers
docker-compose down

# Stop and remove containers + volumes (deletes database data!)
docker-compose down -v
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f api
docker-compose logs -f web
docker-compose logs -f db
docker-compose logs -f nginx

# Last 100 lines
docker-compose logs --tail=100 -f
```

### Access Container Shell

```bash
# API container
docker-compose exec api sh

# Database container
docker-compose exec db psql -U postgres -d hrmsdb

# Web container
docker-compose exec web sh

# Nginx container
docker-compose exec nginx sh
```

### Database Operations

```bash
# Access PostgreSQL CLI
docker-compose exec db psql -U postgres -d hrmsdb

# Backup database
docker-compose exec db pg_dump -U postgres hrmsdb > backup.sql

# Restore database
docker-compose exec -T db psql -U postgres -d hrmsdb < backup.sql
```

### Restart Individual Service

```bash
docker-compose restart api
docker-compose restart web
docker-compose restart nginx
docker-compose restart db
```

### View Service Status

```bash
# All services
docker-compose ps

# Service health
curl http://localhost/health

# Or check from inside API container
docker-compose exec api python -c "import urllib.request; print(urllib.request.urlopen('http://localhost:8000/health').read())"
```

## Troubleshooting

### Port Already in Use

If port 80 is already in use:

1. Edit `docker-compose.yml`
2. Change nginx ports from `"80:80"` to `"8080:80"`
3. Access via http://localhost:8080

### Database Connection Issues

```bash
# Check database is healthy
docker-compose ps db

# View database logs
docker-compose logs db

# Restart database
docker-compose restart db
```

### API Not Responding

```bash
# Check API logs
docker-compose logs api

# Check if API is healthy
curl http://localhost/health

# Restart API
docker-compose restart api
```

### Frontend Not Loading

```bash
# Check web logs
docker-compose logs web

# Check nginx logs
docker-compose logs nginx

# Restart services
docker-compose restart web nginx
```

### Clear Everything and Start Fresh

```bash
# Stop and remove everything
docker-compose down -v

# Remove all images
docker-compose down --rmi all

# Rebuild from scratch
docker-compose up -d --build
```

## Environment Variables

Create a `.env` file in the root directory to customize settings:

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=hrmsdb
DATABASE_URL=postgresql://postgres:postgres@db:5432/hrmsdb
ENVIRONMENT=dev
PORT=8000
REACT_APP_API_URL=http://localhost
REACT_APP_ENVIRONMENT=dev
```

## Network Architecture

All services communicate through the `hrms-network` bridge network:

- **Frontend** → calls `/api/*` → **Nginx** → proxies to **Backend**
- **Backend** → connects to **Database** using `db:5432`
- **External users** → access everything through **Nginx** on port 80

## Production Deployment

For production deployment with a domain:

1. Update `nginx.conf` and change `server_name` from `localhost` to your domain
2. Set `ENVIRONMENT=prod` in docker-compose.yml
3. Update CORS origins in `hrms-api/main.py`
4. Add SSL certificates to nginx configuration
5. Use secure passwords for PostgreSQL

## Logs Location

Nginx logs are stored in `./nginx-logs/` directory:
- Access log: `nginx-logs/access.log`
- Error log: `nginx-logs/error.log`

## Data Persistence

Database data is persisted in a Docker volume named `postgres_data`. This ensures your data survives container restarts.

To view volumes:
```bash
docker volume ls
docker volume inspect hrms_postgres_data
```

## Support

For issues or questions, check the logs first:
```bash
docker-compose logs -f
```

Then investigate specific services as needed.
