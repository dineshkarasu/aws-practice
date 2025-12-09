# Multi-App Deployment - README

Complete deployment setup for running HRMS (App1) and App2 (Node.js) on a single server with Nginx reverse proxy.

## 🏗️ Architecture

```
                          ┌─────────────────┐
                          │   Your Server   │
                          │   Public IP     │
                          └────────┬────────┘
                                   │
                          ┌────────▼────────┐
                          │  Nginx Proxy    │
                          │   Port 80/443   │
                          └────┬────────┬───┘
                               │        │
              ┌────────────────┘        └──────────────┐
              │                                        │
     ┌────────▼─────────┐                    ┌────────▼────────┐
     │  dinesh-app1     │                    │  dinesh-app2    │
     │  zamait.in       │                    │  zamait.in      │
     │  (HRMS)          │                    │  (Node.js App)  │
     └──────┬───────┬───┘                    └─────────────────┘
            │       │
     ┌──────▼──┐  ┌─▼──────┐
     │ API     │  │ Web    │
     │ :8000   │  │ :80    │
     └─────────┘  └────────┘
            │
     ┌──────▼──────┐
     │ PostgreSQL  │
     │ :5432       │
     └─────────────┘
```

## 📁 Project Structure

```
multi-app-deployment/
├── docker-compose.yml          # Main orchestration file
├── .env.template               # Environment variables template
├── .env                        # Your actual environment (create from template)
├── deploy.sh                   # Deployment script (Linux/Mac)
├── deploy.ps1                  # Deployment script (Windows)
├── setup-ssl.sh                # SSL certificate setup script
├── README.md                   # This file
└── nginx/                      # Nginx configuration
    ├── nginx.conf              # Main nginx config
    └── conf.d/                 # Site configurations
        ├── default.conf        # Health check endpoint
        ├── app1-hrms.conf      # HRMS (App1) configuration
        └── app2-nodejs.conf    # App2 configuration
```

## 🚀 Quick Start

### Prerequisites

1. **Server Requirements**:
   - Linux server (Ubuntu, Amazon Linux, etc.)
   - Docker & Docker Compose installed
   - Ports 80 and 443 open
   - Minimum 2GB RAM, 2 vCPUs

2. **DNS Configuration**:
   - Create A records pointing to your server IP:
     - `dinesh-app1.zamait.in` → Your Server IP
     - `dinesh-app2.zamait.in` → Your Server IP

3. **Application Directories**:
   - HRMS application at `../HRMS`
   - App2 application at `../app2`

### Installation Steps

#### Step 1: Configure Environment

```bash
cd multi-app-deployment

# Copy environment template
cp .env.template .env

# Edit with your actual values
nano .env
```

Update these critical values:
```env
HRMS_POSTGRES_PASSWORD=your_secure_password
LETSENCRYPT_EMAIL=your@email.com
APP1_DOMAIN=dinesh-app1.zamait.in
APP2_DOMAIN=dinesh-app2.zamait.in
```

#### Step 2: Deploy Applications

**Linux/Mac:**
```bash
chmod +x deploy.sh
./deploy.sh
```

**Windows (PowerShell):**
```powershell
.\deploy.ps1
```

#### Step 3: Setup SSL Certificates (Production)

⚠️ **Important**: Only run after DNS is configured and pointing to your server!

```bash
chmod +x setup-ssl.sh
./setup-ssl.sh
```

This will:
- Install Certbot
- Obtain SSL certificates from Let's Encrypt
- Configure HTTPS for both domains
- Set up automatic renewal

### Access Your Applications

**With SSL (Production):**
- HRMS: https://dinesh-app1.zamait.in
- App2: https://dinesh-app2.zamait.in

**Without SSL (Testing):**
- HRMS: http://dinesh-app1.zamait.in
- App2: http://dinesh-app2.zamait.in

## 📊 Container Details

| Container | Port | Purpose | Health Check |
|-----------|------|---------|--------------|
| nginx-proxy | 80, 443 | Reverse proxy & SSL termination | /health |
| hrms-db | 5432 (internal) | PostgreSQL database | pg_isready |
| hrms-api | 8000 (internal) | HRMS FastAPI backend | /health |
| hrms-web | 80 (internal) | HRMS React frontend | / |
| app2 | 4000 (internal) | Node.js full stack app | /api/health |

## 🛠️ Management Commands

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f hrms-api
docker-compose logs -f app2
docker-compose logs -f nginx
```

### Restart Services
```bash
# All services
docker-compose restart

# Individual services
docker-compose restart hrms-api
docker-compose restart app2
docker-compose restart nginx
```

### Stop/Start
```bash
# Stop all
docker-compose down

# Start all
docker-compose up -d

# Rebuild and start
docker-compose up -d --build
```

### Check Status
```bash
# Container status
docker-compose ps

# Health status
docker inspect nginx-proxy --format='{{.State.Health.Status}}'
docker inspect hrms-api --format='{{.State.Health.Status}}'
docker inspect app2 --format='{{.State.Health.Status}}'
```

## 🔒 SSL/TLS Configuration

### Initial Setup (HTTP Only)
When first deployed, applications run on HTTP (port 80) until SSL certificates are obtained.

### Obtaining Certificates
```bash
./setup-ssl.sh
```

### Certificate Renewal
Certificates expire in 90 days. Set up automatic renewal:

```bash
sudo crontab -e
```

Add:
```cron
0 3 * * * certbot renew --quiet --deploy-hook 'cd /path/to/multi-app-deployment && docker-compose restart nginx'
```

### Manual Renewal
```bash
sudo certbot renew
docker-compose restart nginx
```

## 🔧 Configuration Files

### Nginx Configuration

**Main Config**: `nginx/nginx.conf`
- Global settings
- Worker processes
- Gzip compression

**App1 Config**: `nginx/conf.d/app1-hrms.conf`
- Routes for HRMS application
- API proxy to hrms-api:8000
- Frontend proxy to hrms-web:80

**App2 Config**: `nginx/conf.d/app2-nodejs.conf`
- Routes for App2 application
- Proxy to app2:4000

### Environment Variables

See `.env.template` for all available configuration options.

Key variables:
- `HRMS_POSTGRES_PASSWORD`: Database password
- `APP1_DOMAIN`: Domain for HRMS
- `APP2_DOMAIN`: Domain for App2
- `LETSENCRYPT_EMAIL`: Email for SSL certificates
- `SSL_ENABLED`: Enable/disable SSL (true/false)

## 🚨 Troubleshooting

### Issue: DNS not resolving
**Solution**: Verify DNS A records:
```bash
nslookup dinesh-app1.zamait.in
nslookup dinesh-app2.zamait.in
```

### Issue: SSL certificate failed
**Causes**:
- DNS not pointing to server
- Ports 80/443 blocked
- Domain not accessible

**Solution**:
```bash
# Test domain accessibility
curl http://dinesh-app1.zamait.in/.well-known/acme-challenge/test

# Check ports
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443
```

### Issue: Container unhealthy
**Solution**:
```bash
# Check logs
docker-compose logs [service-name]

# Restart service
docker-compose restart [service-name]

# Full restart
docker-compose down && docker-compose up -d
```

### Issue: Cannot connect to database
**Solution**:
```bash
# Check database is running
docker-compose ps hrms-db

# Verify connection
docker exec -it hrms-db psql -U postgres -d hrmsdb
```

### Issue: 502 Bad Gateway
**Causes**:
- Backend service not running
- Backend service unhealthy

**Solution**:
```bash
# Check backend status
docker-compose ps hrms-api app2

# Restart backends
docker-compose restart hrms-api app2
```

## 📈 Monitoring

### Health Checks
```bash
# Nginx
curl http://localhost/health

# HRMS API
curl http://dinesh-app1.zamait.in/health

# App2
curl http://dinesh-app2.zamait.in/api/health
```

### Container Stats
```bash
docker stats
```

### Disk Usage
```bash
docker system df
```

## 🔐 Security Best Practices

✅ **Implemented**:
- Non-root users in containers
- HTTPS/SSL encryption
- Security headers (HSTS, X-Frame-Options, etc.)
- CORS configuration
- Network isolation

⚠️ **Recommendations**:
1. Change default database passwords in `.env`
2. Regularly update Docker images
3. Monitor logs for suspicious activity
4. Set up fail2ban for SSH protection
5. Enable firewall (ufw/firewalld)
6. Regular backups of database volumes

## 💾 Backup & Restore

### Backup Database
```bash
# Create backup
docker exec hrms-db pg_dump -U postgres hrmsdb > backup_$(date +%Y%m%d).sql

# Backup volume
docker run --rm -v hrms-postgres-data:/data -v $(pwd):/backup ubuntu tar czf /backup/hrms-db-backup.tar.gz /data
```

### Restore Database
```bash
# Restore from SQL dump
cat backup_20251209.sql | docker exec -i hrms-db psql -U postgres hrmsdb
```

## 🚀 Scaling & Performance

### Resource Limits
Add to `docker-compose.yml`:
```yaml
services:
  hrms-api:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
```

### Multiple Workers
For high traffic, scale backend services:
```bash
docker-compose up -d --scale hrms-api=3
```

## 📞 Support

For issues or questions:
1. Check logs: `docker-compose logs -f`
2. Review this README
3. Check individual app documentation:
   - HRMS: `../HRMS/README.md`
   - App2: `../app2/README.md`

## 📄 License

This deployment configuration is provided as-is for the HRMS and App2 projects.

---

**Deployment Version**: 1.0  
**Last Updated**: December 9, 2025  
**Maintained by**: DevOps Team
