# 2-Container Architecture - Overview

## 🎯 Simplified Deployment Architecture

This setup uses **only 3 containers total** for deploying both applications:

1. **nginx-proxy** - Reverse proxy for routing based on domain
2. **hrms-app** - Complete HRMS application (all-in-one container)
3. **app2** - Node.js full-stack application

---

## 🏗️ Architecture Diagram

```
                          ┌─────────────────┐
                          │   EC2 Instance  │
                          │   Public IP     │
                          └────────┬────────┘
                                   │
                          ┌────────▼────────┐
                          │  nginx-proxy    │
                          │   Port 80/443   │
                          │  (DNS routing)  │
                          └────┬────────┬───┘
                               │        │
              ┌────────────────┘        └──────────────┐
              │                                        │
     ┌────────▼─────────┐                    ┌────────▼────────┐
     │  hrms-app        │                    │  app2           │
     │  Container       │                    │  Container      │
     │  Port 80         │                    │  Port 4000      │
     └──────────────────┘                    └─────────────────┘
     │                                       │
     ├─ PostgreSQL      (internal)           └─ Express Server
     ├─ FastAPI        (internal)               + React Build
     └─ Nginx + React  (port 80)
```

---

## 📦 Container Details

### 1. nginx-proxy (Reverse Proxy)
- **Image**: nginx:alpine
- **Purpose**: Route traffic based on domain name
- **Ports**: 80 (HTTP), 443 (HTTPS)
- **Routing**:
  - `dinesh-app1.zamait.in` → `hrms-app:80`
  - `dinesh-app2.zamait.in` → `app2:4000`

### 2. hrms-app (All-in-One HRMS)
- **Build**: Custom Dockerfile (`Dockerfile.combined`)
- **Purpose**: Complete HRMS application stack
- **Port**: 80 (exposed internally to docker network)
- **Internal Services**:
  - **PostgreSQL** - Database running on localhost:5432
  - **FastAPI** - Backend API on localhost:8000
  - **Nginx** - Frontend web server on port 80
  - **React** - Built frontend served by nginx
- **Management**: supervisord manages all internal services
- **External Access**: Through nginx-proxy only

### 3. app2 (Node.js Full Stack)
- **Build**: Standard Dockerfile
- **Purpose**: Node.js + React full-stack application
- **Port**: 4000 (exposed internally to docker network)
- **Internal Services**:
  - Express server serving both API and React build
- **External Access**: Through nginx-proxy only

---

## 🔄 Request Flow

### For HRMS (dinesh-app1.zamait.in):
```
User Request
    ↓
nginx-proxy (matches domain: dinesh-app1.zamait.in)
    ↓
hrms-app:80
    ↓
Internal Nginx (inside hrms-app container)
    ↓
    ├─ /api/*     → FastAPI (localhost:8000)
    ├─ /docs      → FastAPI Swagger (localhost:8000)
    ├─ /health    → FastAPI (localhost:8000)
    └─ /*         → React Frontend (static files)
```

### For App2 (dinesh-app2.zamait.in):
```
User Request
    ↓
nginx-proxy (matches domain: dinesh-app2.zamait.in)
    ↓
app2:4000
    ↓
Express Server
    ↓
    ├─ /api/*     → Express API handlers
    └─ /*         → React Build (static files)
```

---

## ✅ Benefits of This Architecture

1. **Simplified Management**
   - Only 3 containers to monitor
   - Less complex networking
   - Easier to understand

2. **Resource Efficiency**
   - Reduced container overhead
   - Shared resources within each app container
   - Lower memory footprint

3. **Easier Deployment**
   - Single build per application
   - Less coordination between containers
   - Faster startup times

4. **Self-Contained Applications**
   - Each app is fully independent
   - Can be moved/scaled easily
   - Clear separation of concerns

5. **Simplified Networking**
   - Only external proxy needs public exposure
   - Internal services communicate via localhost
   - Reduced network complexity

---

## 🚀 Deployment

### Prerequisites
```bash
# Both application folders in parent directory:
Project/
├── HRMS/                    # Must have Dockerfile.combined
├── app2/                    # Must have Dockerfile
└── multi-app-deployment/    # This folder
```

### Deploy Commands

**Linux/Mac:**
```bash
cd multi-app-deployment
cp .env.template .env
nano .env                    # Configure your settings
chmod +x deploy.sh
./deploy.sh
```

**Windows:**
```powershell
cd multi-app-deployment
Copy-Item .env.template .env
notepad .env                 # Configure your settings
.\deploy.ps1
```

### What Happens During Deployment

1. **Environment validation** - Checks .env file
2. **Cleanup** - Stops existing containers
3. **Build hrms-app** - Creates all-in-one HRMS image (takes 5-10 min)
4. **Build app2** - Creates Node.js image (takes 2-3 min)
5. **Start services** - Brings up all 3 containers
6. **Health checks** - Waits for all services to be healthy

---

## 🔍 Monitoring & Management

### Check Container Status
```bash
docker-compose ps
```

Expected output:
```
NAME          STATUS
nginx-proxy   Up (healthy)
hrms-app      Up (healthy)
app2          Up (healthy)
```

### View Logs
```bash
# All containers
docker-compose logs -f

# Specific container
docker-compose logs -f hrms-app
docker-compose logs -f app2
docker-compose logs -f nginx
```

### Restart Services
```bash
# Restart single application
docker-compose restart hrms-app
docker-compose restart app2

# Restart everything
docker-compose restart
```

### Access Container Shell
```bash
# HRMS container
docker exec -it hrms-app /bin/bash

# App2 container
docker exec -it app2 /bin/sh

# Check internal services in HRMS
docker exec -it hrms-app supervisorctl status
```

---

## 🔧 Configuration

### Environment Variables (.env)
```env
# PostgreSQL for HRMS
HRMS_POSTGRES_USER=postgres
HRMS_POSTGRES_PASSWORD=your_secure_password_here
HRMS_POSTGRES_DB=testdb

# Application Settings
ENVIRONMENT=production
LOG_LEVEL=INFO

# Domains
APP1_DOMAIN=dinesh-app1.zamait.in
APP2_DOMAIN=dinesh-app2.zamait.in

# SSL
LETSENCRYPT_EMAIL=your@email.com
```

---

## 🔒 SSL Configuration

After deployment, set up SSL certificates:

```bash
chmod +x setup-ssl.sh
./setup-ssl.sh
```

This will:
- Install Certbot
- Obtain certificates for both domains
- Configure nginx for HTTPS
- Set up auto-renewal

---

## 🧪 Testing

### Test HRMS Application
```bash
# Health check
curl https://dinesh-app1.zamait.in/health

# API docs (open in browser)
https://dinesh-app1.zamait.in/docs

# Frontend
https://dinesh-app1.zamait.in
```

### Test App2
```bash
# Health check
curl https://dinesh-app2.zamait.in/api/health

# Message endpoint
curl https://dinesh-app2.zamait.in/api/message

# Frontend
https://dinesh-app2.zamait.in
```

---

## 🐛 Troubleshooting

### Container Won't Start

**Check logs:**
```bash
docker-compose logs hrms-app
docker-compose logs app2
```

**Common issues:**
- Build failed - Check Dockerfile paths
- Port conflicts - Ensure ports 80/443 are free
- Memory issues - Need minimum 2GB RAM

### HRMS Internal Services Not Running

**Check supervisord status:**
```bash
docker exec -it hrms-app supervisorctl status
```

Expected output:
```
postgresql    RUNNING   pid 123, uptime 0:05:00
api           RUNNING   pid 124, uptime 0:04:55
nginx         RUNNING   pid 125, uptime 0:04:50
```

**Restart specific service:**
```bash
docker exec -it hrms-app supervisorctl restart api
docker exec -it hrms-app supervisorctl restart nginx
```

### Database Connection Issues

**Check PostgreSQL:**
```bash
docker exec -it hrms-app su - postgres -c "psql -c 'SELECT 1'"
```

**Check database exists:**
```bash
docker exec -it hrms-app su - postgres -c "psql -l"
```

### SSL Certificate Issues

**Verify certificates exist:**
```bash
ls -la certbot/conf/live/dinesh-app1.zamait.in/
ls -la certbot/conf/live/dinesh-app2.zamait.in/
```

**Renew certificates manually:**
```bash
docker-compose run --rm certbot renew
docker-compose restart nginx
```

---

## 📊 Resource Usage

### Expected Resources Per Container

| Container | CPU | Memory | Disk |
|-----------|-----|--------|------|
| nginx-proxy | Low | ~20MB | Minimal |
| hrms-app | Medium | ~800MB-1.5GB | ~2GB |
| app2 | Low | ~150-300MB | ~500MB |

**Total System Requirements:**
- **Minimum**: 2GB RAM, 2 vCPUs, 10GB disk
- **Recommended**: 4GB RAM, 2 vCPUs, 20GB disk

---

## 🔄 Updates & Maintenance

### Update Application Code

1. **Update code** in HRMS/ or app2/ folder
2. **Rebuild and restart:**
   ```bash
   docker-compose up -d --build hrms-app
   # OR
   docker-compose up -d --build app2
   ```

### Update Dependencies

**HRMS:**
- Edit `HRMS/hrms-api/requirements.txt`
- Edit `HRMS/hrms-web/package.json`
- Rebuild: `docker-compose up -d --build hrms-app`

**App2:**
- Edit `app2/package.json` or `app2/frontend/package.json`
- Rebuild: `docker-compose up -d --build app2`

### Backup Database

```bash
# Backup HRMS database
docker exec hrms-app su - postgres -c "pg_dump testdb" > hrms_backup.sql

# Restore
cat hrms_backup.sql | docker exec -i hrms-app su - postgres -c "psql testdb"
```

---

## 🎯 Production Checklist

- [ ] DNS records configured for both domains
- [ ] EC2 security group allows ports 80, 443
- [ ] `.env` file created with secure passwords
- [ ] Docker & Docker Compose installed
- [ ] Applications deployed and healthy
- [ ] SSL certificates obtained and configured
- [ ] Database backup strategy in place
- [ ] Monitoring/alerting configured
- [ ] Log rotation configured

---

## 📚 Additional Resources

- [README.md](README.md) - Complete documentation
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Step-by-step deployment
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Quick commands
- [SUMMARY.md](SUMMARY.md) - Project summary

---

## 🆘 Support

For issues or questions:
1. Check container logs: `docker-compose logs -f`
2. Verify health status: `docker-compose ps`
3. Check internal services: `docker exec -it hrms-app supervisorctl status`
4. Review this guide and troubleshooting section
