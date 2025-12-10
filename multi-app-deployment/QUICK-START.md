# 🚀 Quick Deployment Guide

## One-Page Reference for EC2 Deployment

### 📋 Prerequisites
- ✅ EC2 instance (t2.medium minimum, Amazon Linux 2 or Ubuntu)
- ✅ DNS A records: `dinesh-app1.zamait.in` and `dinesh-app2.zamait.in` → EC2 IP
- ✅ Security Group: Allow ports 22 (SSH), 80 (HTTP), 443 (HTTPS)

---

## 🎯 5-Step Deployment

### Step 1: Upload Files to EC2
```bash
# From your local machine
scp -r Project ec2-user@<EC2_IP>:~/
```

### Step 2: Initial Setup (One-Time)
```bash
# SSH into EC2
ssh ec2-user@<EC2_IP>

# Navigate to deployment folder
cd ~/Project/multi-app-deployment

# Make scripts executable
chmod +x *.sh

# Run EC2 setup (installs Docker, Docker Compose, Git)
./deploy-ec2.sh
```

### Step 3: Configure Environment
```bash
# Edit .env file
nano .env

# Update these critical values:
# - HRMS_POSTGRES_PASSWORD=YourSecurePassword123!
# - LETSENCRYPT_EMAIL=your-email@example.com
```

### Step 4: Deploy Applications
```bash
# Validate configuration first
./validate.sh

# Deploy (takes 10-15 minutes first time)
./deploy.sh

# Test HTTP access
curl http://dinesh-app1.zamait.in/health
curl http://dinesh-app2.zamait.in/api/health
```

### Step 5: Enable HTTPS
```bash
# Set up SSL certificates (requires DNS to be working)
./setup-ssl.sh

# Test HTTPS access
curl https://dinesh-app1.zamait.in/health
curl https://dinesh-app2.zamait.in/api/health
```

---

## 🔧 Common Commands

### View Status
```bash
docker-compose ps                    # Container status
docker-compose logs                  # All logs
docker-compose logs -f nginx         # Follow nginx logs
docker-compose logs -f hrms-api      # Follow API logs
```

### Restart Services
```bash
docker-compose restart               # Restart all
docker-compose restart nginx         # Restart nginx only
docker-compose restart hrms-api      # Restart HRMS API only
```

### Stop/Start
```bash
docker-compose down                  # Stop all containers
docker-compose up -d                 # Start all containers
```

### Update Application
```bash
git pull                             # Pull latest code
docker-compose build --no-cache      # Rebuild images
docker-compose up -d                 # Restart containers
```

---

## 🌐 Access URLs

- **HRMS App**: https://dinesh-app1.zamait.in
- **App2**: https://dinesh-app2.zamait.in
- **HRMS API Docs**: https://dinesh-app1.zamait.in/docs

---

## 🔍 Troubleshooting

### Containers Won't Start
```bash
docker-compose logs                  # Check all logs
docker-compose down                  # Stop everything
docker-compose up -d                 # Start fresh
```

### SSL Not Working
```bash
# Verify DNS points to correct IP
nslookup dinesh-app1.zamait.in

# Check certbot logs
docker-compose logs nginx

# Re-run SSL setup
./setup-ssl.sh
```

### Database Connection Issues
```bash
# Check database is running
docker-compose ps hrms-db

# Check database logs
docker-compose logs hrms-db

# Connect to database
docker exec -it hrms-db psql -U postgres -d testdb
```

### Port Already in Use
```bash
# Find what's using port 80/443
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443

# Stop conflicting service
sudo systemctl stop httpd
sudo systemctl stop nginx
```

---

## 📊 Health Checks

```bash
# HRMS health
curl http://dinesh-app1.zamait.in/health

# App2 health  
curl http://dinesh-app2.zamait.in/api/health

# Check all containers
docker-compose ps | grep healthy
```

---

## 💾 Database Backup/Restore

```bash
# Backup
docker exec hrms-db pg_dump -U postgres testdb > backup_$(date +%Y%m%d).sql

# Restore
docker exec -i hrms-db psql -U postgres testdb < backup_20231209.sql
```

---

## 🔐 Security Checklist

- ✅ Changed default database password in `.env`
- ✅ Set correct email in `.env` for SSL certificates
- ✅ Security group allows only necessary ports (22, 80, 443)
- ✅ SSH key-based authentication enabled
- ✅ Restrict SSH to your IP (optional but recommended)
- ✅ SSL certificates installed and auto-renewal configured

---

## 📁 Important Files

```
multi-app-deployment/
├── docker-compose.yml          # Main orchestration
├── .env                        # Your configuration (git-ignored)
├── deploy-ec2.sh              # Initial EC2 setup
├── deploy.sh                   # Deploy applications
├── setup-ssl.sh               # Set up SSL
├── validate.sh                # Validate before deploy
├── nginx/
│   └── conf.d/
│       ├── app1-hrms.conf     # HRMS routing
│       └── app2-nodejs.conf   # App2 routing
└── README-DEPLOYMENT.md       # Full documentation
```

---

## 📞 Quick Reference

### Service Names in Docker
- `nginx` - Reverse proxy
- `hrms-db` - PostgreSQL database
- `hrms-api` - FastAPI backend
- `hrms-web` - React frontend + Nginx
- `app2` - Node.js full-stack app

### Ports
- 80 - HTTP (redirects to HTTPS)
- 443 - HTTPS (main entry point)
- 8000 - HRMS API (internal only)
- 4000 - App2 (internal only)
- 5432 - PostgreSQL (internal only)

### Networks
- `multi-app-network` - Bridge network connecting all containers

---

## ✅ Deployment Verification

After deployment, verify:

1. ✅ All 5 containers running: `docker-compose ps`
2. ✅ All containers healthy: `docker-compose ps | grep healthy`
3. ✅ HRMS accessible: Open https://dinesh-app1.zamait.in
4. ✅ App2 accessible: Open https://dinesh-app2.zamait.in
5. ✅ HRMS API docs: Open https://dinesh-app1.zamait.in/docs
6. ✅ SSL valid: Check browser lock icon
7. ✅ HTTP redirects to HTTPS: Try http://dinesh-app1.zamait.in

---

## 🎓 Next Steps After Deployment

1. **Test all functionality** in both applications
2. **Set up monitoring** (AWS CloudWatch recommended)
3. **Configure automated backups** for database
4. **Document any customizations** you make
5. **Plan for scaling** if needed

---

## 📚 Additional Resources

- Full Guide: `README-DEPLOYMENT.md`
- Cleanup Report: `CLEANUP-REPORT.md`
- Validation Script: `./validate.sh`

---

**Need Help?** Check logs with `docker-compose logs` and review `README-DEPLOYMENT.md` for detailed troubleshooting.
