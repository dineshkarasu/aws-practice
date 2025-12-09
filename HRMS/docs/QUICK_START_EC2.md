# 🚀 HRMS EC2 Quick Deployment Commands

## Step-by-Step EC2 Deployment

### 1️⃣ Connect to EC2
```bash
ssh -i your-key.pem ec2-user@your-ec2-public-dns
```

### 2️⃣ Setup System (One-time)
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

# Install Git
sudo yum install git -y

# MUST LOG OUT AND BACK IN
exit
```

### 3️⃣ SSH Back In
```bash
ssh -i your-key.pem ec2-user@your-ec2-public-dns
```

### 4️⃣ Clone Repository
```bash
git clone https://github.com/bmohammad1/aws-training.git
cd aws-training/devops/hackathon/HRMS
```

### 5️⃣ Deploy Application
```bash
docker-compose up -d --build
```

### 6️⃣ Verify Deployment
```bash
# Check containers
docker-compose ps

# Check logs
docker-compose logs -f

# Check health
curl http://localhost:8000/health
```

### 7️⃣ Get Public IP
```bash
curl http://169.254.169.254/latest/meta-data/public-ipv4
```

### 8️⃣ Access Application
```
Frontend: http://YOUR-EC2-IP:3000
API Docs: http://YOUR-EC2-IP:8000/docs
```

---

## 🔧 Essential Commands

```bash
# View logs
docker-compose logs -f

# Restart
docker-compose restart

# Stop
docker-compose down

# Rebuild
docker-compose up -d --build

# Check status
docker-compose ps

# System stats
docker stats
```

---

## ⚠️ Security Group Requirements

**Inbound Rules:**
- Port 22 (SSH) - Your IP
- Port 3000 (Frontend) - 0.0.0.0/0
- Port 8000 (API) - 0.0.0.0/0

---

## 📋 Troubleshooting

**Can't access from browser?**
1. Check Security Group has ports 3000, 8000 open
2. Verify containers: `docker-compose ps`
3. Check logs: `docker-compose logs`

**Containers won't start?**
```bash
docker-compose down
docker system prune -a
docker-compose up -d --build
```

---

## ✅ Success Checklist
- [ ] EC2 instance running
- [ ] Security group configured (22, 3000, 8000)
- [ ] Docker installed
- [ ] Code cloned from GitHub
- [ ] Containers running (`docker-compose ps`)
- [ ] Can access http://YOUR-IP:3000
- [ ] Can access http://YOUR-IP:8000/docs

---

**Repository:** https://github.com/bmohammad1/aws-training
**Branch:** wip
**Path:** devops/hackathon/HRMS
