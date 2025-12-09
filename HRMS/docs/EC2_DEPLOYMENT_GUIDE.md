# HRMS EC2 Deployment Guide

## 🚀 Complete EC2 Deployment Steps

### Prerequisites
- AWS Account with EC2 access
- SSH key pair (.pem file)
- Security Group configured (ports 22, 80, 3000, 8000)

---

## Step 1: Launch EC2 Instance

### 1.1 Launch Instance
1. Go to AWS Console → EC2 → Launch Instance
2. Configure:
   - **Name**: `hrms-app-server`
   - **AMI**: Amazon Linux 2023 (or Amazon Linux 2)
   - **Instance Type**: `t2.small` or `t2.medium` (t2.micro may be too small for Docker)
   - **Key Pair**: Select or create new key pair
   - **Network Settings**: 
     - Allow SSH (port 22) from your IP
     - Allow Custom TCP (port 8000) from 0.0.0.0/0
     - Allow Custom TCP (port 3000) from 0.0.0.0/0
     - Allow HTTP (port 80) - optional
   - **Storage**: 20-30 GB

3. Click **Launch Instance**

### 1.2 Note Your Instance Details
- Public IPv4 address: `ec2-xx-xx-xx-xx.compute.amazonaws.com`
- Key pair name and location

---

## Step 2: Connect to EC2 Instance

### Windows (PowerShell)
```powershell
# Set key file permissions (only first time)
icacls "C:\path\to\your-key.pem" /inheritance:r
icacls "C:\path\to\your-key.pem" /grant:r "%username%:R"

# Connect via SSH
ssh -i "C:\path\to\your-key.pem" ec2-user@your-ec2-public-dns
```

### Linux/Mac
```bash
# Set key file permissions (only first time)
chmod 400 /path/to/your-key.pem

# Connect via SSH
ssh -i /path/to/your-key.pem ec2-user@your-ec2-public-dns
```

---

## Step 3: Setup EC2 Instance

### Option A: Using Automated Script (Recommended)

```bash
# Clone your repository first
git clone https://github.com/bmohammad1/aws-training.git
cd aws-training/devops/hackathon/HRMS

# Make script executable
chmod +x deploy-ec2.sh

# Run setup script
./deploy-ec2.sh

# IMPORTANT: Log out and log back in
exit

# SSH back in
ssh -i your-key.pem ec2-user@your-ec2-public-dns
```

### Option B: Manual Setup

```bash
# Update system
sudo yum update -y

# Install Docker
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install Git
sudo yum install git -y

# Verify installations
docker --version
docker-compose --version

# IMPORTANT: Log out and log back in
exit

# SSH back in
ssh -i your-key.pem ec2-user@your-ec2-public-dns
```

---

## Step 4: Deploy HRMS Application

```bash
# If not already cloned, clone the repository
git clone https://github.com/bmohammad1/aws-training.git
cd aws-training/devops/hackathon/HRMS

# Verify files are present
ls -la

# Start the application with Docker Compose
docker-compose up -d --build

# This will:
# - Build the API container (Python/FastAPI)
# - Build the Web container (React/Nginx)
# - Start both containers
# - Set up networking between them
```

---

## Step 5: Verify Deployment

### Check Container Status
```bash
# View running containers
docker-compose ps

# Should show:
# - hrms-api (healthy)
# - hrms-web (healthy)
```

### Check Logs
```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs api
docker-compose logs web

# Follow logs in real-time
docker-compose logs -f
```

### Check Health
```bash
# Check API health
curl http://localhost:8000/health

# Check Web health
curl http://localhost:80
```

---

## Step 6: Access the Application

### Get Your EC2 Public IP/DNS
```bash
# On EC2 instance
curl http://169.254.169.254/latest/meta-data/public-ipv4
curl http://169.254.169.254/latest/meta-data/public-hostname
```

### Access URLs
- **Frontend**: `http://your-ec2-public-ip:3000`
- **API**: `http://your-ec2-public-ip:8000`
- **API Docs**: `http://your-ec2-public-ip:8000/docs`

Example:
- `http://ec2-54-123-45-67.compute-1.amazonaws.com:3000`
- `http://54.123.45.67:3000`

---

## Step 7: Test the Application

1. **Open Frontend**: Navigate to `http://your-ec2-ip:3000`
2. **Test Employees**: 
   - View existing employees
   - Add new employee
   - Edit employee
   - Delete employee
3. **Test Departments**:
   - Create department
   - View departments
4. **Test Leave Requests**:
   - Submit leave request
   - Approve/reject requests

---

## 🔧 Troubleshooting

### Containers Won't Start
```bash
# Check Docker service
sudo systemctl status docker

# Check if ports are available
sudo netstat -tlnp | grep -E ':(3000|8000)'

# Restart Docker
sudo systemctl restart docker
docker-compose down
docker-compose up -d --build
```

### Can't Access from Browser
1. **Check Security Group**:
   - Go to EC2 → Security Groups
   - Ensure inbound rules allow:
     - Port 3000 from 0.0.0.0/0
     - Port 8000 from 0.0.0.0/0
     - Port 22 from your IP

2. **Check containers are running**:
   ```bash
   docker-compose ps
   docker ps -a
   ```

3. **Check firewall** (if using Amazon Linux 2):
   ```bash
   sudo systemctl status firewalld
   # If active, add rules:
   sudo firewall-cmd --permanent --add-port=3000/tcp
   sudo firewall-cmd --permanent --add-port=8000/tcp
   sudo firewall-cmd --reload
   ```

### Frontend Shows Connection Error
1. **Check API container**:
   ```bash
   docker-compose logs api
   docker exec -it hrms-api curl http://localhost:8000/health
   ```

2. **Check network connectivity**:
   ```bash
   docker network inspect hrms-network
   ```

### Build Fails
```bash
# Clean up and rebuild
docker-compose down -v
docker system prune -a
docker-compose up --build
```

---

## 🛑 Stop the Application

```bash
# Stop containers
docker-compose stop

# Stop and remove containers
docker-compose down

# Stop and remove everything including volumes
docker-compose down -v
```

---

## 🔄 Update Application

```bash
# Pull latest changes
cd aws-training
git pull origin main

# Rebuild and restart
cd devops/hackathon/HRMS
docker-compose down
docker-compose up -d --build
```

---

## 📊 Monitoring

### View Resource Usage
```bash
# Container stats
docker stats

# System resources
top
free -h
df -h
```

### View Logs
```bash
# Last 100 lines
docker-compose logs --tail=100

# Follow logs
docker-compose logs -f

# Specific service
docker-compose logs -f api
```

---

## 🔒 Security Best Practices

1. **Restrict SSH access** to your IP only
2. **Use HTTPS** in production (add SSL/TLS)
3. **Update packages regularly**:
   ```bash
   sudo yum update -y
   ```
4. **Set up CloudWatch** for monitoring
5. **Enable AWS Systems Manager** for secure access
6. **Use IAM roles** instead of access keys
7. **Regular backups** of data

---

## 💰 Cost Optimization

1. **Stop instance when not in use**:
   ```bash
   # From AWS Console: EC2 → Instances → Stop
   ```
2. **Use t2.micro** for testing (free tier eligible)
3. **Set up auto-shutdown** with CloudWatch alarms
4. **Use Elastic IP** only if needed (costs when not attached)

---

## 📚 Quick Reference Commands

```bash
# Start application
docker-compose up -d

# Stop application
docker-compose down

# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Rebuild
docker-compose up -d --build

# Check status
docker-compose ps

# Access API container
docker exec -it hrms-api sh

# Access Web container
docker exec -it hrms-web sh

# Clean up
docker-compose down -v
docker system prune -a
```

---

## 🎯 Production Checklist

- [ ] Security group properly configured
- [ ] Application accessible from browser
- [ ] All API endpoints working
- [ ] Frontend communicating with API
- [ ] Health checks passing
- [ ] Logs showing no errors
- [ ] SSL/TLS configured (for production)
- [ ] Monitoring set up
- [ ] Backup strategy in place

---

## 📞 Support

If you encounter issues:
1. Check logs: `docker-compose logs`
2. Verify security group settings
3. Check EC2 instance has enough resources
4. Review the troubleshooting section above

---

**Good luck with your deployment! 🚀**
