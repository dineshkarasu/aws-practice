# Multi-App Deployment - Summary

## ✅ What Was Created

I've configured a complete multi-app deployment setup for running HRMS (App1) and App2 on a single server with the following domains:
- **dinesh-app1.zamait.in** → HRMS Application
- **dinesh-app2.zamait.in** → App2 (Node.js Full Stack)

---

## 📁 Project Structure

```
multi-app-deployment/
├── docker-compose.yml           # Main orchestration (3 containers)
├── .env.template                # Environment configuration template
├── deploy.sh                    # Deployment script (Linux/Mac)
├── deploy.ps1                   # Deployment script (Windows)
├── setup-ssl.sh                 # SSL certificate setup (Linux)
├── README.md                    # Complete documentation
├── DEPLOYMENT_GUIDE.md          # Step-by-step deployment guide
├── QUICK_REFERENCE.md           # Quick commands reference
├── .gitignore                   # Git ignore rules
└── nginx/                       # Nginx reverse proxy config
    ├── nginx.conf               # Main nginx configuration
    └── conf.d/
        ├── default.conf         # Health check endpoint
        ├── app1-hrms.conf       # HRMS routing rules
        └── app2-nodejs.conf     # App2 routing rules
```

---

## 🏗️ Architecture

```
                    Internet
                       │
                   Port 80/443
                       │
                ┌──────▼──────┐
                │    Nginx    │  (Reverse Proxy + SSL)
                │  Container  │
                └──┬────────┬──┘
                   │        │
```
                    Internet
                       │
                   Port 80/443
                       │
                ┌──────▼──────┐
                │    Nginx    │  (Reverse Proxy + SSL)
                │  Container  │
                └──┬────────┬──┘
                   │        │
    ┌──────────────┘        └──────────────┐
    │                                      │
    │ dinesh-app1.zamait.in               │ dinesh-app2.zamait.in
    │                                      │
┌───▼────────────┐                   ┌────▼──────────┐
│  hrms-app      │                   │     app2      │
│  (All-in-one)  │                   │  (All-in-one) │
├────────────────┤                   └───────────────┘
│ Nginx (port 80)│                   │ Node.js + React│
│ FastAPI :8000  │                   │ Port 4000      │
│ PostgreSQL     │                   └────────────────┘
└────────────────┘
```

---

## 🐳 Docker Containers

| Container | Purpose | Port (Internal) | Health Check |
|-----------|---------|-----------------|--------------|
| nginx-proxy | Reverse proxy & SSL | 80, 443 | /health |
| hrms-app | Complete HRMS (DB+API+Web) | 80 | /health |
| app2 | Node.js full stack | 4000 | /api/health |

**Total: 3 containers**

---

## 🚀 Deployment Steps

### 1. Prerequisites
- Server with Docker & Docker Compose
- DNS A records configured:
  - `dinesh-app1.zamait.in` → Your Server IP
  - `dinesh-app2.zamait.in` → Your Server IP
- Ports 80, 443 open

### 2. Configure Environment
```bash
cd multi-app-deployment
cp .env.template .env
nano .env  # Update passwords and email
```

### 3. Deploy (Linux/Mac)
```bash
chmod +x deploy.sh
./deploy.sh
```

### 4. Setup SSL (Production)
```bash
chmod +x setup-ssl.sh
./setup-ssl.sh
```

---

## 🌐 Nginx Configuration

### App1 (HRMS) - `nginx/conf.d/app1-hrms.conf`
- **Routes**:
  - `/` → hrms-web:80 (React frontend)
  - `/api/*` → hrms-api:8000 (FastAPI backend)
  - `/docs` → hrms-api:8000/docs (API documentation)
  - `/health` → hrms-api:8000/health (Health check)

### App2 (Node.js) - `nginx/conf.d/app2-nodejs.conf`
- **Routes**:
  - `/*` → app2:4000 (All requests proxied to App2)

### Features:
- ✅ HTTP to HTTPS redirect
- ✅ SSL/TLS configuration (TLSv1.2, TLSv1.3)
- ✅ Security headers (HSTS, X-Frame-Options, etc.)
- ✅ Gzip compression
- ✅ Static asset caching
- ✅ Let's Encrypt ACME challenge support

---

## 🔒 SSL/HTTPS Configuration

### Automatic SSL Setup
The `setup-ssl.sh` script:
1. Installs Certbot
2. Obtains certificates for both domains
3. Configures Nginx for HTTPS
4. Sets up certificate renewal

### Certificate Locations
- App1: `/etc/letsencrypt/live/dinesh-app1.zamait.in/`
- App2: `/etc/letsencrypt/live/dinesh-app2.zamait.in/`

### Auto-Renewal
Add to crontab:
```bash
0 3 * * * certbot renew --quiet --deploy-hook 'cd /path/to/multi-app-deployment && docker-compose restart nginx'
```

---

## 📝 Environment Configuration

### Key Variables (.env)
```env
# Database
HRMS_POSTGRES_USER=postgres
HRMS_POSTGRES_PASSWORD=change_this_secure_password
HRMS_POSTGRES_DB=hrmsdb

# Domains
APP1_DOMAIN=dinesh-app1.zamait.in
APP2_DOMAIN=dinesh-app2.zamait.in

# SSL
LETSENCRYPT_EMAIL=admin@zamait.in
SSL_ENABLED=false  # Set to true after SSL setup

# Environment
ENVIRONMENT=production
LOG_LEVEL=INFO
```

---

## 🛠️ Management Commands

### Container Control
```bash
docker-compose ps              # Check status
docker-compose up -d           # Start all
docker-compose down            # Stop all
docker-compose restart         # Restart all
docker-compose logs -f         # View logs
```

### Service-Specific
```bash
docker-compose restart hrms-api    # Restart HRMS API
docker-compose restart app2        # Restart App2
docker-compose restart nginx       # Restart Nginx
docker-compose logs -f hrms-api    # View HRMS API logs
```

### Rebuild & Update
```bash
docker-compose up -d --build       # Rebuild all
docker-compose up -d --build app2  # Rebuild specific service
```

---

## 🔍 Health Checks

### Test Endpoints
```bash
# Nginx
curl http://localhost/health

# HRMS
curl https://dinesh-app1.zamait.in/health

# App2
curl https://dinesh-app2.zamait.in/api/health
```

### Expected Responses

**HRMS Health**:
```json
{
  "status": "healthy",
  "service": "HRMS API",
  "environment": "production"
}
```

**App2 Health**:
```json
{
  "status": "ok",
  "app": "app2",
  "environment": "production",
  "timestamp": "2025-12-09T..."
}
```

---

## 📊 Monitoring

### Container Health
```bash
docker inspect nginx-proxy --format='{{.State.Health.Status}}'
docker inspect hrms-api --format='{{.State.Health.Status}}'
docker inspect app2 --format='{{.State.Health.Status}}'
```

### Resource Usage
```bash
docker stats                    # Real-time stats
docker system df                # Disk usage
```

### Logs
```bash
docker-compose logs -f --tail=100       # All logs
docker-compose logs -f nginx            # Nginx logs
docker-compose logs -f hrms-api app2    # Multiple services
```

---

## 🔐 Security Features

### Implemented
- ✅ HTTPS/SSL encryption
- ✅ Non-root users in containers
- ✅ Security headers (HSTS, X-Frame-Options, CSP)
- ✅ Network isolation (docker bridge network)
- ✅ CORS configuration
- ✅ Database password protection

### Recommendations
- Change default passwords in .env
- Enable firewall (ufw/firewalld)
- Regular security updates
- Enable fail2ban
- Regular backups

---

## 💾 Backup & Restore

### Backup Database
```bash
docker exec hrms-db pg_dump -U postgres hrmsdb > backup_$(date +%Y%m%d).sql
```

### Restore Database
```bash
cat backup_20251209.sql | docker exec -i hrms-db psql -U postgres hrmsdb
```

### Backup Volumes
```bash
docker run --rm -v hrms-postgres-data:/data -v $(pwd):/backup ubuntu tar czf /backup/db-backup.tar.gz /data
```

---

## 🚨 Troubleshooting

### Container Not Starting
```bash
docker-compose logs [container-name]
docker-compose restart [container-name]
```

### 502 Bad Gateway
- Check backend is running: `docker-compose ps`
- Check backend health: `curl http://localhost:8000/health`
- Restart backend: `docker-compose restart hrms-api app2`

### DNS Not Resolving
- Verify A records in DNS provider
- Wait 10-30 minutes for propagation
- Test: `nslookup dinesh-app1.zamait.in`

### SSL Certificate Failed
- Ensure DNS points to server
- Check ports 80/443 are open
- Stop nginx temporarily: `docker-compose stop nginx`
- Run setup again: `./setup-ssl.sh`

---

## 📚 Documentation Files

1. **README.md** - Complete documentation (15 pages)
2. **DEPLOYMENT_GUIDE.md** - Step-by-step deployment (12 pages)
3. **QUICK_REFERENCE.md** - Quick commands (4 pages)
4. **This file** - Summary overview

---

## ✅ What's Different from Single-App Setup

### HRMS Changes
1. **New nginx config**: `hrms-web/nginx-internal.conf`
   - Removed SSL configuration (handled by main Nginx)
   - Simplified to work behind reverse proxy
   - No domain-specific configuration

2. **Updated Dockerfile**: `hrms-web/Dockerfile`
   - Now includes `nginx-internal.conf`
   - Default config changed to internal version

### App2 Changes
- No changes needed! App2 works as-is behind reverse proxy

### New Components
1. **Nginx reverse proxy** (main entry point)
2. **Docker Compose orchestration** (all services)
3. **SSL management** (centralized certificates)
4. **Unified deployment** (single command)

---

## 🎯 Access URLs

### Production (with SSL)
- **HRMS**: https://dinesh-app1.zamait.in
  - API Docs: https://dinesh-app1.zamait.in/docs
  - Health: https://dinesh-app1.zamait.in/health
  
- **App2**: https://dinesh-app2.zamait.in
  - Health: https://dinesh-app2.zamait.in/api/health
  - Message: https://dinesh-app2.zamait.in/api/message

### Development (without SSL)
- **HRMS**: http://dinesh-app1.zamait.in
- **App2**: http://dinesh-app2.zamait.in

---

## 🎉 Success Indicators

All systems operational when:
- ✅ All 5 containers showing "Up (healthy)" status
- ✅ Both domains accessible in browser
- ✅ SSL certificates valid (green padlock)
- ✅ Health checks returning 200 OK
- ✅ No errors in logs
- ✅ API endpoints responding correctly

---

## 📞 Quick Support

### Check Everything at Once
```bash
echo "=== Container Status ===" && \
docker-compose ps && \
echo -e "\n=== Health Checks ===" && \
docker inspect nginx-proxy --format='Nginx: {{.State.Health.Status}}' && \
docker inspect hrms-api --format='HRMS API: {{.State.Health.Status}}' && \
docker inspect app2 --format='App2: {{.State.Health.Status}}' && \
echo -e "\n=== Test URLs ===" && \
curl -I https://dinesh-app1.zamait.in/health 2>&1 | grep "HTTP" && \
curl -I https://dinesh-app2.zamait.in/api/health 2>&1 | grep "HTTP"
```

---

## 📋 Deployment Checklist

Before going live:
- [ ] DNS A records configured
- [ ] Server firewall configured (ports 80, 443 open)
- [ ] .env file created and passwords changed
- [ ] Applications deployed successfully
- [ ] All containers healthy
- [ ] SSL certificates obtained
- [ ] Both domains accessible via HTTPS
- [ ] Health checks passing
- [ ] Auto-renewal configured
- [ ] Backups configured
- [ ] Monitoring enabled

---

**Deployment Ready!** 🚀

All configuration files are in: `c:\Users\dkarasu\Desktop\Project\multi-app-deployment\`

For detailed instructions, see [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
