# Multi-App Deployment Guide
**Complete Setup Guide for HRMS (App1) and App2 on Single Server**

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Server Setup](#server-setup)
3. [DNS Configuration](#dns-configuration)
4. [Deployment Steps](#deployment-steps)
5. [SSL Setup](#ssl-setup)
6. [Verification](#verification)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Resources
- **Server**: AWS EC2, Azure VM, DigitalOcean Droplet, or similar
  - OS: Ubuntu 20.04+, Amazon Linux 2, CentOS 7+
  - CPU: Minimum 2 vCPUs
  - RAM: Minimum 4GB (2GB might work but not recommended)
  - Storage: 20GB+ SSD
- **Domains**: 
  - `dinesh-app1.zamait.in`
  - `dinesh-app2.zamait.in`
- **Network**: 
  - Public IP address
  - Ports 22 (SSH), 80 (HTTP), 443 (HTTPS) open

### Local Requirements
- Git installed
- SSH client
- Text editor

---

## Server Setup

### Step 1: Install Docker

#### For Amazon Linux 2 / CentOS
```bash
# Update system
sudo yum update -y

# Install Docker
sudo yum install docker -y

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker ec2-user
# OR for other users:
sudo usermod -aG docker $USER
```

#### For Ubuntu / Debian
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER
```

**Important**: Log out and log back in for group changes to take effect!

### Step 2: Install Docker Compose

```bash
# Download Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make executable
sudo chmod +x /usr/local/bin/docker-compose

# Create symlink
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Verify installation
docker-compose --version
```

### Step 3: Configure Firewall

#### Amazon Linux / CentOS (firewalld)
```bash
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

#### Ubuntu (ufw)
```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

#### AWS Security Group
Ensure your EC2 security group has these inbound rules:
- SSH (22) - Your IP
- HTTP (80) - 0.0.0.0/0
- HTTPS (443) - 0.0.0.0/0

---

## DNS Configuration

### Step 1: Get Your Server's Public IP

```bash
# On AWS EC2
curl http://169.254.169.254/latest/meta-data/public-ipv4

# On other servers
curl ifconfig.me
```

### Step 2: Create DNS A Records

In your DNS provider (Cloudflare, Route53, GoDaddy, etc.), create:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | dinesh-app1.zamait.in | YOUR_SERVER_IP | 300 |
| A | dinesh-app2.zamait.in | YOUR_SERVER_IP | 300 |

### Step 3: Verify DNS Propagation

```bash
# Wait 5-10 minutes, then test:
nslookup dinesh-app1.zamait.in
nslookup dinesh-app2.zamait.in

# Should return your server IP
```

---

## Deployment Steps

### Step 1: Clone/Upload Applications

```bash
# SSH to your server
ssh ec2-user@YOUR_SERVER_IP

# Create project directory
mkdir -p ~/projects
cd ~/projects

# Clone or upload your applications
# You should have:
# - HRMS/ (your HRMS application)
# - app2/ (your App2 application)
# - multi-app-deployment/ (this deployment configuration)
```

### Step 2: Configure Environment

```bash
cd multi-app-deployment

# Create .env from template
cp .env.template .env

# Edit configuration
nano .env
```

**Update these values**:
```env
HRMS_POSTGRES_PASSWORD=YourSecurePassword123!
LETSENCRYPT_EMAIL=your-email@zamait.in
APP1_DOMAIN=dinesh-app1.zamait.in
APP2_DOMAIN=dinesh-app2.zamait.in
```

### Step 3: Deploy Applications

```bash
# Make deploy script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

The script will:
1. Check Docker installation
2. Verify application directories
3. Stop existing containers
4. Build Docker images (this takes 5-10 minutes)
5. Start all services
6. Display access URLs

### Step 4: Monitor Deployment

```bash
# Watch containers start
docker-compose ps

# Watch logs
docker-compose logs -f

# Press Ctrl+C to stop watching logs
```

Wait until all containers show "healthy" status:
```
NAME          STATUS
nginx-proxy   Up (healthy)
hrms-api      Up (healthy)
hrms-web      Up (healthy)
hrms-db       Up (healthy)
app2          Up (healthy)
```

---

## SSL Setup

⚠️ **Only proceed after**:
- DNS is configured
- Applications are deployed
- Ports 80/443 are open

### Step 1: Run SSL Setup Script

```bash
chmod +x setup-ssl.sh
./setup-ssl.sh
```

The script will:
1. Install Certbot
2. Stop Nginx temporarily
3. Obtain certificates for both domains
4. Restart services with HTTPS enabled

### Step 2: Verify SSL

```bash
# Test HTTPS access
curl -I https://dinesh-app1.zamait.in
curl -I https://dinesh-app2.zamait.in

# Check certificate
sudo certbot certificates
```

### Step 3: Configure Auto-Renewal

```bash
# Edit crontab
sudo crontab -e

# Add this line (adjust path):
0 3 * * * certbot renew --quiet --deploy-hook 'cd /home/ec2-user/projects/multi-app-deployment && docker-compose restart nginx'
```

---

## Verification

### Check Container Health

```bash
docker-compose ps
```

Expected output:
```
NAME          STATUS
nginx-proxy   Up (healthy)
hrms-api      Up (healthy)
hrms-web      Up (healthy)
hrms-db       Up (healthy)
app2          Up (healthy)
```

### Test Applications

#### HRMS (App1)
```bash
# HTTP (before SSL)
curl http://dinesh-app1.zamait.in/health

# HTTPS (after SSL)
curl https://dinesh-app1.zamait.in/health

# Expected: {"status":"healthy","service":"HRMS API","environment":"production"}
```

#### App2
```bash
# HTTP (before SSL)
curl http://dinesh-app2.zamait.in/api/health

# HTTPS (after SSL)
curl https://dinesh-app2.zamait.in/api/health

# Expected: {"status":"ok","app":"app2","environment":"production",...}
```

### Access in Browser

1. **HRMS**: https://dinesh-app1.zamait.in
   - Should see HRMS login/dashboard
   - API docs: https://dinesh-app1.zamait.in/docs

2. **App2**: https://dinesh-app2.zamait.in
   - Should see "App 2 - Full Stack" page
   - Click "Get Message" button to test

---

## Troubleshooting

### Issue 1: DNS Not Resolving

**Symptom**: Domain doesn't resolve to your server IP

**Solution**:
```bash
# Check DNS
nslookup dinesh-app1.zamait.in

# If not resolving:
# 1. Verify A records in DNS provider
# 2. Wait 10-30 minutes for propagation
# 3. Clear DNS cache: sudo systemd-resolve --flush-caches
```

### Issue 2: Container Unhealthy

**Symptom**: Container shows "unhealthy" status

**Solution**:
```bash
# Check logs
docker-compose logs [container-name]

# Common fixes:
docker-compose restart [container-name]
docker-compose up -d --build [container-name]
```

### Issue 3: 502 Bad Gateway

**Symptom**: Nginx returns 502 error

**Solution**:
```bash
# Check backend is running
docker-compose ps

# Check backend health
curl http://localhost:8000/health  # For HRMS API
curl http://localhost:4000/api/health  # For App2

# Restart backends
docker-compose restart hrms-api app2
```

### Issue 4: SSL Certificate Failed

**Symptom**: Certbot fails to obtain certificate

**Common Causes**:
1. DNS not pointing to server
2. Port 80 blocked
3. Nginx already using port 80

**Solution**:
```bash
# Test port 80 accessibility
curl http://YOUR_SERVER_IP/.well-known/acme-challenge/test

# Stop nginx temporarily
docker-compose stop nginx

# Try SSL setup again
./setup-ssl.sh
```

### Issue 5: Database Connection Error

**Symptom**: HRMS API can't connect to database

**Solution**:
```bash
# Check database is running
docker-compose ps hrms-db

# Check database logs
docker-compose logs hrms-db

# Test database connection
docker exec -it hrms-db psql -U postgres -d hrmsdb

# If needed, recreate database
docker-compose down hrms-db
docker volume rm hrms-postgres-data
docker-compose up -d hrms-db
```

### Issue 6: Permission Denied

**Symptom**: Docker commands fail with permission errors

**Solution**:
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and log back in
exit
ssh ec2-user@YOUR_SERVER_IP
```

### Issue 7: Out of Disk Space

**Symptom**: Deployment fails, "no space left on device"

**Solution**:
```bash
# Check disk usage
df -h

# Clean up Docker
docker system prune -a --volumes

# Remove old images
docker image prune -a
```

---

## Post-Deployment Tasks

### 1. Change Default Passwords

```bash
# Edit .env
nano .env

# Change HRMS_POSTGRES_PASSWORD
# Then restart
docker-compose restart hrms-db hrms-api
```

### 2. Enable Monitoring

```bash
# Install monitoring tools (optional)
docker run -d --name portainer \
  -p 9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  portainer/portainer-ce
```

### 3. Setup Backups

```bash
# Create backup script
cat > backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker exec hrms-db pg_dump -U postgres hrmsdb > /backups/hrms_$DATE.sql
find /backups -name "hrms_*.sql" -mtime +7 -delete
EOF

chmod +x backup.sh

# Add to crontab (daily at 2 AM)
crontab -e
# Add: 0 2 * * * /path/to/backup.sh
```

### 4. Configure Log Rotation

```bash
# Docker handles log rotation, but you can configure:
sudo nano /etc/docker/daemon.json

# Add:
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}

# Restart Docker
sudo systemctl restart docker
docker-compose restart
```

---

## Maintenance Commands

### Daily Checks
```bash
# Check status
docker-compose ps

# Check logs for errors
docker-compose logs --tail=100 | grep -i error
```

### Weekly Tasks
```bash
# Update system packages
sudo yum update -y  # Amazon Linux/CentOS
# OR
sudo apt update && sudo apt upgrade -y  # Ubuntu

# Check disk space
df -h

# Check certificate expiry
sudo certbot certificates
```

### Monthly Tasks
```bash
# Review and clean old images
docker image ls
docker image prune -a

# Check for application updates
cd ~/projects/HRMS && git pull
cd ~/projects/app2 && git pull
cd ~/projects/multi-app-deployment
docker-compose up -d --build
```

---

## Performance Tuning

### For High Traffic

```bash
# Scale backend services
docker-compose up -d --scale hrms-api=3

# Monitor resource usage
docker stats
```

### Nginx Optimization

Edit `nginx/nginx.conf`:
```nginx
worker_processes auto;
worker_connections 2048;
```

---

## Security Checklist

- [ ] Changed default database password
- [ ] SSL certificates installed
- [ ] Firewall configured (only 80, 443, 22 open)
- [ ] SSH key-based authentication enabled
- [ ] Regular backups configured
- [ ] Monitoring enabled
- [ ] Log rotation configured
- [ ] SSL auto-renewal configured
- [ ] Fail2ban installed (optional but recommended)

---

## Support & Resources

### Documentation
- [Main README](README.md)
- [Quick Reference](QUICK_REFERENCE.md)
- [HRMS Documentation](../HRMS/README.md)
- [App2 Documentation](../app2/README.md)

### Common Commands
```bash
# View all logs
docker-compose logs -f

# Restart everything
docker-compose restart

# Full rebuild
docker-compose down && docker-compose up -d --build

# Check health
docker-compose ps
```

---

## Success Checklist

✅ Server setup complete (Docker, Docker Compose installed)  
✅ DNS configured and propagated  
✅ Applications deployed successfully  
✅ All containers healthy  
✅ SSL certificates obtained (for production)  
✅ Applications accessible via domains  
✅ Health checks passing  
✅ Backups configured  
✅ Monitoring enabled  

---

**Deployment Complete!** 🎉

Your applications are now running on:
- **HRMS**: https://dinesh-app1.zamait.in
- **App2**: https://dinesh-app2.zamait.in

For issues or questions, check the [Troubleshooting](#troubleshooting) section.
