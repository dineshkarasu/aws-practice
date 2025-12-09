# 🚀 HRMS Quick Start - EC2 Deployment

## One-Command Deployment

### On Your EC2 Instance:

```bash
# 1. Clone repository
git clone https://github.com/bmohammad1/aws-training.git
cd aws-training/devops/hackathon/HRMS

# 2. Run deployment script
chmod +x deploy.sh
./deploy.sh

# 3. If first time, log out and back in
exit
ssh -i your-key.pem ec2-user@YOUR-EC2-IP

# 4. Access your application
# Frontend: http://YOUR-EC2-IP/
# API Docs: http://YOUR-EC2-IP/docs
```

---

## Manual Deployment Steps

If you prefer step-by-step:

```bash
# Update & install Docker
sudo yum update -y
sudo yum install docker git -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Log out and back in
exit
ssh -i your-key.pem ec2-user@YOUR-EC2-IP

# Clone and deploy
git clone https://github.com/bmohammad1/aws-training.git
cd aws-training/devops/hackathon/HRMS
docker-compose up -d --build
```

---

## EC2 Security Group Requirements

**ONLY these ports needed:**

| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 22   | TCP      | Your IP | SSH Access |
| 80   | TCP      | 0.0.0.0/0 | HTTP (Nginx) |
| 443  | TCP      | 0.0.0.0/0 | HTTPS (future) |

**DO NOT open:** 3000, 5432, 8000 (handled internally by Docker)

---

## Verify Deployment

```bash
# Check containers
docker-compose ps

# Should show 3 healthy services:
# ✓ hrms-db    (PostgreSQL)
# ✓ hrms-api   (FastAPI Backend)
# ✓ hrms-web   (Nginx + React Frontend)

# View logs
docker-compose logs -f

# Test health
curl http://localhost/health
```

---

## Seed Sample Data

```bash
docker exec -it hrms-api python seed_data.py
```

---

## Common Commands

```bash
# View all containers
docker-compose ps

# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Stop application
docker-compose down

# Update and rebuild
git pull origin wip
docker-compose up -d --build

# Access database
docker exec -it hrms-db psql -U postgres -d testdb
```

---

## Troubleshooting

### Can't access application?
1. Check security group has port 80 open
2. Run: `docker-compose ps` (all should be healthy)
3. Run: `curl http://localhost/health`

### Containers not starting?
```bash
docker-compose logs
docker-compose down -v
docker-compose up -d --build
```

### Permission denied?
```bash
# Log out and back in after first setup
exit
ssh -i your-key.pem ec2-user@YOUR-EC2-IP
```

---

## 📍 Your URLs

Replace `YOUR-EC2-IP` with your actual EC2 public IP:

```bash
# Get your EC2 IP
curl http://169.254.169.254/latest/meta-data/public-ipv4
```

- **App**: `http://YOUR-EC2-IP/`
- **API**: `http://YOUR-EC2-IP/docs`
- **Health**: `http://YOUR-EC2-IP/health`

---

**That's it! Your HRMS is now running with PostgreSQL persistence! 🎉**

For detailed information, see `DEPLOY.md`
