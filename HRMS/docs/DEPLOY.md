# HRMS Deployment Guide - PostgreSQL Version

## 🚀 Quick EC2 Deployment

### Prerequisites
- AWS EC2 instance (t2.small or larger recommended)
- Security Group with ports: **22 (SSH), 80 (HTTP), 443 (HTTPS)**
- SSH key pair (.pem file)

---

## Step 1: Launch EC2 Instance

1. **AWS Console** → EC2 → Launch Instance
2. Configure:
   - **Name**: `hrms-production`
   - **AMI**: Amazon Linux 2023
   - **Instance Type**: `t2.small` (minimum) or `t2.medium` (recommended)
   - **Key Pair**: Create or select existing
   - **Security Group**: 
     - SSH (22) - Your IP only
     - HTTP (80) - 0.0.0.0/0
     - HTTPS (443) - 0.0.0.0/0
   - **Storage**: 20 GB minimum

---

## Step 2: Connect to EC2

### Windows (PowerShell)
```powershell
# Set permissions (first time only)
icacls "your-key.pem" /inheritance:r
icacls "your-key.pem" /grant:r "%username%:R"

# Connect
ssh -i "your-key.pem" ec2-user@YOUR-EC2-PUBLIC-IP
```

### Linux/Mac
```bash
chmod 400 your-key.pem
ssh -i your-key.pem ec2-user@YOUR-EC2-PUBLIC-IP
```

---

## Step 3: Install Dependencies

```bash
# Update system
sudo yum update -y

# Install Docker
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker ec2-user

# Install Git
sudo yum install git -y

# IMPORTANT: Log out and back in
exit
```

**SSH back in:**
```bash
ssh -i your-key.pem ec2-user@YOUR-EC2-PUBLIC-IP
```

---

## Step 4: Deploy Application

```bash
# Clone repository
git clone https://github.com/bmohammad1/aws-training.git
cd aws-training/devops/hackathon/HRMS

# Start all services (PostgreSQL + API + Nginx)
docker-compose up -d --build
```

This will:
- Pull PostgreSQL 15 image
- Build API backend (FastAPI)
- Build frontend (React + Nginx)
- Initialize database tables
- Start all services

---

## Step 5: Seed Initial Data (Optional)

```bash
# Run seed script to populate sample data
docker exec -it hrms-api python seed_data.py
```

---

## Step 6: Verify Deployment

### Check Containers
```bash
docker-compose ps

# Should show 3 healthy containers:
# - hrms-db (PostgreSQL)
# - hrms-api (FastAPI)
# - hrms-web (Nginx)
```

### Check Logs
```bash
# All services
docker-compose logs

# Specific service
docker-compose logs db
docker-compose logs api
docker-compose logs web

# Follow logs
docker-compose logs -f
```

### Test Locally
```bash
# API health
curl http://localhost/health

# API docs
curl http://localhost/docs
```

---

## Step 7: Access Application

### Get EC2 Public IP
```bash
curl http://169.254.169.254/latest/meta-data/public-ipv4
```

### Access URLs (Replace with your EC2 IP)
- **Frontend**: `http://YOUR-EC2-IP/`
- **API Docs**: `http://YOUR-EC2-IP/docs`
- **API ReDoc**: `http://YOUR-EC2-IP/redoc`
- **Health Check**: `http://YOUR-EC2-IP/health`

Example:
- `http://54.123.45.67/`
- `http://54.123.45.67/docs`

---

## 🧪 Test the Application

1. **Open Frontend**: `http://YOUR-EC2-IP/`
2. **Test Features**:
   - View employees list
   - Create new employee
   - View departments
   - Submit leave request
3. **Test API**: `http://YOUR-EC2-IP/docs`
   - Try interactive Swagger UI
   - Test endpoints directly

---

## 🔍 Troubleshooting

### Containers Not Starting
```bash
# Check Docker status
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Rebuild containers
docker-compose down -v
docker-compose up -d --build
```

### Can't Access Application
1. **Verify Security Group**:
   - EC2 Console → Security Groups
   - Ensure port 80 is open to 0.0.0.0/0

2. **Check containers**:
   ```bash
   docker-compose ps
   docker-compose logs
   ```

3. **Test locally first**:
   ```bash
   curl http://localhost/health
   ```

### Database Issues
```bash
# Check PostgreSQL logs
docker-compose logs db

# Access database directly
docker exec -it hrms-db psql -U postgres -d testdb

# Inside psql:
\dt              # List tables
\q               # Quit
```

### API Errors
```bash
# View API logs
docker-compose logs api

# Check database connection
docker exec -it hrms-api python -c "from database import engine; print(engine)"

# Restart API
docker-compose restart api
```

---

## 🔄 Update Application

```bash
cd aws-training
git pull origin wip
cd devops/hackathon/HRMS

# Rebuild and restart
docker-compose down
docker-compose up -d --build
```

---

## 🛑 Stop Application

```bash
# Stop containers (data persists)
docker-compose stop

# Stop and remove containers (data persists in volume)
docker-compose down

# Stop and REMOVE ALL DATA
docker-compose down -v
```

---

## 💾 Database Management

### Backup Database
```bash
# Backup to file
docker exec hrms-db pg_dump -U postgres testdb > backup_$(date +%Y%m%d).sql
```

### Restore Database
```bash
# Restore from file
cat backup_20240101.sql | docker exec -i hrms-db psql -U postgres testdb
```

### Reset Database
```bash
# WARNING: Deletes all data
docker-compose down -v
docker-compose up -d --build
docker exec -it hrms-api python seed_data.py
```

---

## 📊 Monitoring

```bash
# Container resource usage
docker stats

# System resources
top
free -h
df -h

# Container health
docker-compose ps
```

---

## 🔒 Security Best Practices

1. ✅ Only port 80 exposed (no direct DB or API access)
2. ✅ SSH restricted to your IP
3. ⚠️ Change default PostgreSQL password for production:
   ```yaml
   # In docker-compose.yml
   POSTGRES_PASSWORD=YOUR_SECURE_PASSWORD
   # Also update DATABASE_URL in api service
   ```
4. ⚠️ Add HTTPS/SSL for production
5. ⚠️ Use AWS Secrets Manager for credentials
6. ⚠️ Enable CloudWatch monitoring

---

## 🏗️ Architecture

```
Internet → Port 80 → Nginx (Container)
                      ↓
                    /api/* → FastAPI (Container) → PostgreSQL (Container)
                      ↓
                    /* → React Frontend
```

**Key Points:**
- Only Nginx exposed on port 80
- API and Database are internal only
- Data persists in Docker volume
- All services in same Docker network

---

## 📞 Quick Commands Reference

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Logs
docker-compose logs -f

# Status
docker-compose ps

# Rebuild
docker-compose up -d --build

# Shell access
docker exec -it hrms-api sh
docker exec -it hrms-db psql -U postgres -d testdb

# Clean everything
docker-compose down -v
docker system prune -a
```

---

## ✅ Production Checklist

- [ ] EC2 instance running
- [ ] Security group configured (22, 80, 443)
- [ ] Docker and Docker Compose installed
- [ ] Application deployed and running
- [ ] All 3 containers healthy
- [ ] Frontend accessible from browser
- [ ] API documentation accessible
- [ ] Database initialized and seeded
- [ ] Logs showing no errors
- [ ] (Production) HTTPS/SSL configured
- [ ] (Production) Database password changed
- [ ] (Production) Monitoring enabled

---

**Deployment Complete! 🎉**

Access your application at: `http://YOUR-EC2-IP/`
