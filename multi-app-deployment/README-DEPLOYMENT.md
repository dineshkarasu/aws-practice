# Multi-App Deployment Guide

This directory contains the configuration to deploy **two applications** (HRMS and App2) on a **single EC2 instance** with **Nginx reverse proxy** and **SSL support**.

## 🎯 Architecture

```
                          ┌─────────────────┐
                          │   AWS EC2       │
                          │  Instance       │
                          └────────┬────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    │     Nginx Reverse Proxy     │
                    │    (Port 80/443)            │
                    └──────────────┬──────────────┘
                                   │
              ┌────────────────────┴────────────────────┐
              │                                         │
    ┌─────────▼─────────┐                  ┌───────────▼──────────┐
    │ dinesh-app1.      │                  │ dinesh-app2.         │
    │ zamait.in         │                  │ zamait.in            │
    │                   │                  │                      │
    │  HRMS App         │                  │  App2 (Node.js)      │
    │  ┌──────────┐     │                  │  ┌──────────┐        │
    │  │ React    │     │                  │  │ React    │        │
    │  │ Frontend │     │                  │  │ Frontend │        │
    │  └────┬─────┘     │                  │  └────┬─────┘        │
    │       │           │                  │       │              │
    │  ┌────▼─────┐     │                  │  ┌────▼─────┐        │
    │  │ Nginx    │     │                  │  │ Express  │        │
    │  │ (Port 80)│     │                  │  │ Server   │        │
    │  └────┬─────┘     │                  │  │(Port 4000)│       │
    │       │           │                  │  └──────────┘        │
    │  ┌────▼─────┐     │                  │                      │
    │  │ FastAPI  │     │                  └──────────────────────┘
    │  │ Backend  │     │
    │  │(Port 8000)│    │
    │  └────┬─────┘     │
    │       │           │
    │  ┌────▼─────┐     │
    │  │PostgreSQL│     │
    │  │ Database │     │
    │  └──────────┘     │
    └───────────────────┘
```

## 📦 What's Included

### Applications
- **HRMS (App1)**: Full-stack HR management system with PostgreSQL, FastAPI, and React
- **App2**: Simple full-stack Node.js/Express + React application

### Infrastructure
- **Nginx Reverse Proxy**: Routes traffic based on domain names
- **SSL/TLS Support**: Let's Encrypt certificates for HTTPS
- **Docker Compose**: Orchestrates all containers
- **Health Checks**: Ensures all services are running properly

## 🚀 Quick Start

### Prerequisites

1. **AWS EC2 Instance**
   - Amazon Linux 2 or Ubuntu 20.04+
   - Minimum: t2.medium (2 vCPU, 4GB RAM)
   - Recommended: t3.medium or larger

2. **Domain Names**
   - dinesh-app1.zamait.in (for HRMS)
   - dinesh-app2.zamait.in (for App2)

3. **Security Group Settings**
   - Port 22 (SSH) - Your IP only
   - Port 80 (HTTP) - 0.0.0.0/0
   - Port 443 (HTTPS) - 0.0.0.0/0

### Step 1: Initial EC2 Setup

SSH into your EC2 instance and run:

```bash
# Clone your repository (adjust URL as needed)
cd ~
git clone <your-repo-url>
cd Project/multi-app-deployment

# Make scripts executable
chmod +x *.sh

# Run EC2 setup script (installs Docker, Docker Compose, etc.)
./deploy-ec2.sh
```

### Step 2: Configure Environment

Edit the `.env` file:

```bash
nano .env
```

Update these critical settings:

```env
# Environment
ENVIRONMENT=production

# Database (IMPORTANT: Set a strong password!)
HRMS_POSTGRES_USER=postgres
HRMS_POSTGRES_PASSWORD=YourSecurePassword123!
HRMS_POSTGRES_DB=testdb

# Domains
APP1_DOMAIN=dinesh-app1.zamait.in
APP2_DOMAIN=dinesh-app2.zamait.in

# SSL (set to false initially, true after SSL setup)
SSL_ENABLED=false

# Email for Let's Encrypt
LETSENCRYPT_EMAIL=your-email@example.com
```

### Step 3: Configure DNS

In your DNS provider (e.g., Cloudflare, Route53):

1. Create two A records pointing to your EC2 public IP:
   - `dinesh-app1.zamait.in` → `<EC2_PUBLIC_IP>`
   - `dinesh-app2.zamait.in` → `<EC2_PUBLIC_IP>`

2. Wait 5-10 minutes for DNS propagation

3. Verify:
   ```bash
   nslookup dinesh-app1.zamait.in
   nslookup dinesh-app2.zamait.in
   ```

### Step 4: Deploy Applications

```bash
# Deploy without SSL first
./deploy.sh
```

This will:
- Build all Docker images (~10-15 minutes first time)
- Start all containers
- Run health checks
- Display status

### Step 5: Test HTTP Access

```bash
# Test HRMS
curl http://dinesh-app1.zamait.in/health

# Test App2
curl http://dinesh-app2.zamait.in/api/health
```

Or open in browser:
- http://dinesh-app1.zamait.in
- http://dinesh-app2.zamait.in

### Step 6: Set Up SSL

Once HTTP is working:

```bash
./setup-ssl.sh
```

This will:
- Install certbot
- Obtain SSL certificates from Let's Encrypt
- Update nginx configuration
- Enable HTTPS redirect

### Step 7: Access Applications

Your applications are now live:

- **HRMS**: https://dinesh-app1.zamait.in
- **App2**: https://dinesh-app2.zamait.in

## 🛠️ Management Commands

### View Logs

```bash
# All services
docker-compose logs

# Specific service
docker-compose logs hrms-api
docker-compose logs app2
docker-compose logs nginx

# Follow logs in real-time
docker-compose logs -f nginx
```

### Check Status

```bash
# All containers
docker-compose ps

# Detailed container info
docker ps -a

# Check health
docker-compose ps | grep healthy
```

### Restart Services

```bash
# Restart all
docker-compose restart

# Restart specific service
docker-compose restart hrms-web
docker-compose restart app2
docker-compose restart nginx
```

### Stop/Start

```bash
# Stop all
docker-compose down

# Start all
docker-compose up -d

# Stop and remove volumes (WARNING: deletes database!)
docker-compose down -v
```

### Update Applications

```bash
# Pull latest code
git pull

# Rebuild and restart
docker-compose build --no-cache
docker-compose up -d
```

## 📊 Monitoring

### Health Check Endpoints

- **Nginx**: http://localhost/health
- **HRMS API**: http://dinesh-app1.zamait.in/health
- **App2 API**: http://dinesh-app2.zamait.in/api/health

### Database Access

```bash
# Connect to PostgreSQL
docker exec -it hrms-db psql -U postgres -d testdb

# Backup database
docker exec hrms-db pg_dump -U postgres testdb > backup.sql

# Restore database
docker exec -i hrms-db psql -U postgres testdb < backup.sql
```

## 🐛 Troubleshooting

### Issue: Containers not starting

```bash
# Check logs
docker-compose logs

# Check individual service
docker-compose logs hrms-api

# Restart problematic service
docker-compose restart hrms-api
```

### Issue: SSL certificates not working

```bash
# Verify DNS is pointing to correct IP
nslookup dinesh-app1.zamait.in

# Check certbot logs
docker-compose logs nginx

# Manually test certificate
sudo certbot certificates
```

### Issue: Cannot connect to database

```bash
# Check database is running
docker-compose ps hrms-db

# Check database logs
docker-compose logs hrms-db

# Test connection from API container
docker exec -it hrms-api python -c "import psycopg2; conn = psycopg2.connect('postgresql://postgres:password@hrms-db:5432/testdb'); print('Connected!')"
```

### Issue: Port already in use

```bash
# Check what's using port 80/443
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443

# Stop conflicting service
sudo systemctl stop httpd  # Apache
sudo systemctl stop nginx   # Nginx
```

### Issue: Out of disk space

```bash
# Check disk usage
df -h

# Remove unused Docker resources
docker system prune -a --volumes

# Remove old logs
sudo journalctl --vacuum-time=3d
```

## 🔒 Security Recommendations

1. **Change default passwords** in `.env` file
2. **Restrict SSH access** to your IP only
3. **Enable AWS CloudWatch** for monitoring
4. **Set up automated backups** for database
5. **Keep Docker images updated** regularly
6. **Use AWS Secrets Manager** for sensitive data in production
7. **Enable AWS WAF** for DDoS protection

## 📁 File Structure

```
multi-app-deployment/
├── docker-compose.yml          # Main orchestration file
├── .env.template               # Environment variables template
├── .env                        # Your actual environment (git-ignored)
├── deploy-ec2.sh              # EC2 initial setup script
├── deploy.sh                   # Main deployment script
├── deploy.ps1                  # Windows deployment script
├── setup-ssl.sh               # SSL certificate setup
├── nginx/
│   ├── nginx.conf             # Main nginx config
│   └── conf.d/
│       ├── default.conf       # Health check endpoint
│       ├── app1-hrms.conf     # HRMS routing
│       └── app2-nodejs.conf   # App2 routing
└── README-DEPLOYMENT.md       # This file
```

## 🆘 Support

If you encounter issues:

1. Check logs: `docker-compose logs`
2. Verify DNS: `nslookup dinesh-app1.zamait.in`
3. Check security groups in AWS Console
4. Ensure ports 80 and 443 are open
5. Verify `.env` file configuration

## 📝 Notes

- First build takes 10-15 minutes
- DNS propagation can take up to 24 hours (usually 5-10 minutes)
- SSL certificate renewal is automatic (certbot runs every 12 hours)
- Database data persists in Docker volumes even after container restart
- Logs are automatically rotated by Docker

## 🎓 Learning Resources

- [Docker Documentation](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Let's Encrypt](https://letsencrypt.org/)
- [AWS EC2 User Guide](https://docs.aws.amazon.com/ec2/)
