# HRMS - Docker Compose Deployment Guide

This guide will help you deploy the HRMS application using Docker Compose, which runs both the API backend and React frontend together.

## 🚀 Quick Start

### Prerequisites
- Docker Desktop installed and running
- Docker Compose (included with Docker Desktop)
- At least 2GB of free RAM

### Start the Application

1. **Navigate to the HRMS directory:**
   ```bash
   cd HRMS
   ```

2. **Build and start all services:**
   ```bash
   docker-compose up --build
   ```

   Or run in detached mode (background):
   ```bash
   docker-compose up -d --build
   ```

3. **Access the application:**
   - **Frontend (Web UI)**: http://localhost:3000
   - **Backend API**: http://localhost:8000
   - **API Documentation**: http://localhost:8000/docs

### Stop the Application

```bash
docker-compose down
```

To stop and remove all volumes:
```bash
docker-compose down -v
```

## 📋 Available Commands

### View running containers
```bash
docker-compose ps
```

### View logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f web
docker-compose logs -f api
```

### Restart services
```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart web
docker-compose restart api
```

### Rebuild specific service
```bash
docker-compose up -d --build web
docker-compose up -d --build api
```

### Execute commands in containers
```bash
# Access API container shell
docker-compose exec api sh

# Access Web container shell
docker-compose exec web sh
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│          User's Browser                 │
│      http://localhost:3000              │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│     Frontend Container (Nginx)          │
│         Port: 80 → 3000                 │
│   - Serves React Application            │
│   - Proxies API requests                │
└─────────────┬───────────────────────────┘
              │
              │ /api/* requests
              ▼
┌─────────────────────────────────────────┐
│     Backend API Container               │
│         Port: 8000                      │
│   - FastAPI Application                 │
│   - REST API Endpoints                  │
│   - Mock Database                       │
└─────────────────────────────────────────┘
```

## 🔧 Configuration

### Environment Variables

You can customize the deployment by creating a `.env` file in the HRMS directory:

```env
# API Configuration
API_PORT=8000

# Frontend Configuration
WEB_PORT=3000
REACT_APP_API_URL=http://localhost:8000
```

Then update docker-compose.yml to use these variables:
```yaml
services:
  api:
    ports:
      - "${API_PORT:-8000}:8000"
  web:
    ports:
      - "${WEB_PORT:-3000}:80"
```

## 🐛 Troubleshooting

### Port Already in Use

If you see "port is already allocated" error:

**Option 1: Stop conflicting services**
```bash
# Windows
netstat -ano | findstr :3000
netstat -ano | findstr :8000

# Linux/Mac
lsof -i :3000
lsof -i :8000
```

**Option 2: Change ports in docker-compose.yml**
```yaml
services:
  web:
    ports:
      - "3001:80"  # Changed from 3000
  api:
    ports:
      - "8001:8000"  # Changed from 8000
```

### Container Won't Start

Check logs:
```bash
docker-compose logs api
docker-compose logs web
```

### API Not Accessible from Frontend

1. Ensure both containers are in the same network:
   ```bash
   docker network inspect hrms-network
   ```

2. Check API health:
   ```bash
   docker-compose exec api curl http://localhost:8000/health
   ```

### Frontend Shows Connection Error

1. Check if API is healthy:
   ```bash
   docker-compose ps
   ```

2. Verify nginx proxy configuration:
   ```bash
   docker-compose exec web cat /etc/nginx/conf.d/default.conf
   ```

### Rebuild from Scratch

If you encounter persistent issues:
```bash
# Stop and remove everything
docker-compose down -v

# Remove images
docker rmi hrms-api hrms-web

# Rebuild and start
docker-compose up --build
```

## 📊 Monitoring

### Check Container Health
```bash
docker-compose ps
```

### View Resource Usage
```bash
docker stats
```

### Access Container Logs in Real-time
```bash
docker-compose logs -f --tail=100
```

## 🔄 Updates and Maintenance

### Update Application Code

After making code changes:
```bash
# Rebuild and restart
docker-compose up -d --build

# Or rebuild specific service
docker-compose up -d --build web
```

### Clean Up Old Images
```bash
docker image prune -a
```

### Backup (if using volumes in future)
```bash
docker-compose exec api tar czf /tmp/backup.tar.gz /app/data
docker cp hrms-api:/tmp/backup.tar.gz ./backup.tar.gz
```

## 🚀 Production Deployment

For production deployment, consider:

1. **Use specific image versions** instead of `latest`
2. **Set resource limits**:
   ```yaml
   services:
     api:
       deploy:
         resources:
           limits:
             cpus: '1'
             memory: 512M
   ```

3. **Use proper secrets management**
4. **Set up SSL/TLS** with Let's Encrypt
5. **Configure proper logging and monitoring**
6. **Use environment-specific configurations**

## 📚 Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [React Documentation](https://react.dev/)
- [Nginx Documentation](https://nginx.org/en/docs/)

## 💡 Tips

- Use `docker-compose up` (without `-d`) during development to see logs in real-time
- Use `docker-compose down && docker-compose up --build` for a fresh start
- Access Swagger UI at http://localhost:8000/docs to test API endpoints
- Frontend automatically proxies `/api/*` requests to the backend container

---

**Need Help?** Check the logs first: `docker-compose logs -f`
