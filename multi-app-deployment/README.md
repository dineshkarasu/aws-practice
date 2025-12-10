# Multi-App Deployment

Deploy **HRMS** and **App2** on a single EC2 instance with Nginx reverse proxy and SSL.

## 🎯 What This Does

Deploys 2 applications on 1 EC2 instance:
- **dinesh-app1.zamait.in** → HRMS (PostgreSQL + FastAPI + React)
- **dinesh-app2.zamait.in** → App2 (Node.js + Express + React)

## 🚀 Quick Deploy (5 Steps)

### 1. Upload to EC2
```bash
scp -r Project ec2-user@<EC2_IP>:~/
```

### 2. Initial Setup (one-time)
```bash
ssh ec2-user@<EC2_IP>
cd ~/Project/multi-app-deployment
chmod +x *.sh
./deploy-ec2.sh
```

### 3. Configure
```bash
nano .env
# Update: HRMS_POSTGRES_PASSWORD and LETSENCRYPT_EMAIL
```

### 4. Deploy
```bash
./deploy.sh
```

### 5. Enable HTTPS
```bash
./setup-ssl.sh
```

## 📚 Full Documentation

- **[QUICK-START.md](QUICK-START.md)** - Commands reference
- **[README-DEPLOYMENT.md](README-DEPLOYMENT.md)** - Complete guide with troubleshooting

## 📁 Files

```
multi-app-deployment/
├── docker-compose.yml      # Defines 5 containers
├── .env.template          # Config template
├── deploy-ec2.sh         # Installs Docker, Git, etc.
├── deploy.sh             # Builds & starts containers
├── deploy.ps1            # Windows version
├── setup-ssl.sh          # Gets SSL certificates
└── nginx/                # Reverse proxy config
```

## 🔧 Manage

```bash
docker-compose ps           # Check status
docker-compose logs -f      # View logs
docker-compose restart      # Restart all
docker-compose down         # Stop all
```

## 🌐 Access After Deployment

- https://dinesh-app1.zamait.in (HRMS)
- https://dinesh-app2.zamait.in (App2)
- https://dinesh-app1.zamait.in/docs (API docs)

## ✅ Prerequisites

- EC2 instance (t2.medium, Amazon Linux 2/Ubuntu)
- DNS: Both domains pointing to EC2 public IP
- Security Group: Ports 22, 80, 443 open
