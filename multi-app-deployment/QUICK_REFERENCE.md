# Multi-App Deployment - Quick Reference

## 🚀 Quick Commands

### Initial Setup
```bash
cd multi-app-deployment
cp .env.template .env
nano .env              # Edit configuration
./deploy.sh            # Deploy (Linux/Mac)
# OR
.\deploy.ps1           # Deploy (Windows)
```

### SSL Setup (Production)
```bash
./setup-ssl.sh         # Linux/Mac only
```

---

## 📊 Application Access

### Development (HTTP)
- **HRMS**: http://dinesh-app1.zamait.in
- **App2**: http://dinesh-app2.zamait.in

### Production (HTTPS)
- **HRMS**: https://dinesh-app1.zamait.in
  - API Docs: https://dinesh-app1.zamait.in/docs
  - Health: https://dinesh-app1.zamait.in/health
- **App2**: https://dinesh-app2.zamait.in
  - Health: https://dinesh-app2.zamait.in/api/health
  - Message: https://dinesh-app2.zamait.in/api/message

---

## 🐳 Docker Commands

### Container Management
```bash
docker-compose ps                    # Check status
docker-compose up -d                 # Start all
docker-compose down                  # Stop all
docker-compose restart               # Restart all
docker-compose up -d --build         # Rebuild & restart
```

### Logs
```bash
docker-compose logs -f               # All logs
docker-compose logs -f nginx         # Nginx logs
docker-compose logs -f hrms-app      # HRMS app logs
docker-compose logs -f app2          # App2 logs
```

### Individual Service Control
```bash
docker-compose restart hrms-app      # Restart HRMS
docker-compose restart app2          # Restart App2
docker-compose restart nginx         # Restart Nginx
```

---

## 🏗️ Architecture

```
Internet
   │
   ├─> dinesh-app1.zamait.in ─> Nginx ─> hrms-app:80 (Complete HRMS)
   │                                      ├─ PostgreSQL (internal)
   │                                      ├─ FastAPI (internal)
   │                                      └─ Nginx + React (port 80)
   │
   └─> dinesh-app2.zamait.in ─> Nginx ─> app2:4000 (Node.js + React)
```

**Total: 3 containers** (nginx-proxy, hrms-app, app2)

---

## 📁 Project Structure

```
multi-app-deployment/
├── docker-compose.yml          # Main orchestration
├── .env                        # Configuration (create from template)
├── deploy.sh / deploy.ps1      # Deployment scripts
├── setup-ssl.sh                # SSL setup
└── nginx/
    ├── nginx.conf              # Main config
    └── conf.d/
        ├── app1-hrms.conf      # HRMS routing
        ├── app2-nodejs.conf    # App2 routing
        └── default.conf        # Health check
```

---

## 🔧 Configuration

### Environment Variables (.env)
```env
# Database
HRMS_POSTGRES_PASSWORD=change_this_password

# Domains
APP1_DOMAIN=dinesh-app1.zamait.in
APP2_DOMAIN=dinesh-app2.zamait.in

# SSL
LETSENCRYPT_EMAIL=admin@zamait.in
SSL_ENABLED=false  # Set to true after SSL setup
```

---

## 🚨 Troubleshooting

### Check Container Health
```bash
docker inspect nginx-proxy --format='{{.State.Health.Status}}'
docker inspect hrms-api --format='{{.State.Health.Status}}'
docker inspect app2 --format='{{.State.Health.Status}}'
```

### Test Health Endpoints
```bash
curl http://localhost/health                           # Nginx
curl http://dinesh-app1.zamait.in/health              # HRMS
curl http://dinesh-app2.zamait.in/api/health          # App2
```

### View Real-Time Logs
```bash
docker-compose logs -f --tail=100
```

### Restart Stuck Service
```bash
docker-compose restart [service-name]
```

### Full Reset
```bash
docker-compose down -v
docker-compose up -d --build
```

---

## 🔒 SSL Certificate Management

### Obtain Certificates
```bash
./setup-ssl.sh
```

### Renew Certificates
```bash
sudo certbot renew
docker-compose restart nginx
```

### Auto-Renewal (Cron)
```bash
sudo crontab -e
# Add:
0 3 * * * certbot renew --quiet --deploy-hook 'cd /path/to/multi-app-deployment && docker-compose restart nginx'
```

---

## 📈 Monitoring

### Container Stats
```bash
docker stats
```

### Disk Usage
```bash
docker system df
```

### Network Inspection
```bash
docker network inspect multi-app-network
```

---

## 💾 Backup Database

### Create Backup
```bash
docker exec hrms-db pg_dump -U postgres hrmsdb > backup_$(date +%Y%m%d).sql
```

### Restore Backup
```bash
cat backup_20251209.sql | docker exec -i hrms-db psql -U postgres hrmsdb
```

---

## 🛠️ Common Tasks

### Update Application Code
```bash
cd multi-app-deployment
docker-compose up -d --build [service-name]
```

### Scale Service
```bash
docker-compose up -d --scale hrms-api=3
```

### View Service Details
```bash
docker-compose config
```

---

## 📞 DNS Configuration

### Required A Records
```
dinesh-app1.zamait.in  →  [Your Server IP]
dinesh-app2.zamait.in  →  [Your Server IP]
```

### Verify DNS
```bash
nslookup dinesh-app1.zamait.in
nslookup dinesh-app2.zamait.in
```

---

## ✅ Pre-Deployment Checklist

- [ ] DNS A records configured
- [ ] Ports 80 and 443 open
- [ ] Docker and Docker Compose installed
- [ ] `.env` file created and configured
- [ ] Application directories exist (../HRMS, ../app2)
- [ ] Database password changed from default

---

## 🎯 Quick Status Check

```bash
# All in one
docker-compose ps && \
docker inspect nginx-proxy --format='Nginx: {{.State.Health.Status}}' && \
docker inspect hrms-api --format='HRMS API: {{.State.Health.Status}}' && \
docker inspect app2 --format='App2: {{.State.Health.Status}}'
```

---

## 📝 Important Notes

1. **First deployment runs on HTTP** - SSL certificates must be obtained separately
2. **DNS must be configured** before running SSL setup
3. **Database password** should be changed in `.env` before production
4. **Firewall rules** must allow ports 80 and 443
5. **Automatic backups** should be configured for production

---

## 🎉 Success Indicators

✅ All containers showing "Up" status  
✅ All health checks passing  
✅ Applications accessible via domains  
✅ SSL certificates valid (if enabled)  
✅ No errors in logs  

---

**Need Help?** Check the main [README.md](README.md) for detailed documentation.
