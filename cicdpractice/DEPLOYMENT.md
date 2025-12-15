# Deployment Setup Guide

This guide explains how to set up automated deployment using GitHub Actions with a self-hosted runner.

## Architecture

- **GitHub Actions**: Triggers deployment when code is pushed to master branch
- **Self-Hosted Runner**: Runs on your EC2 instance
- **Deployment Script**: Pulls latest code, builds Docker image, and runs container

## Prerequisites

1. EC2 instance running with Docker installed
2. Git installed on EC2 instance
3. GitHub repository with this code
4. Self-hosted runner configured on EC2 instance

## Initial Setup on EC2 Instance

### 1. Clone the Repository

```bash
cd /home/ec2-user
git clone https://github.com/your-username/your-repo-name.git cicdpractice
cd cicdpractice
```

### 2. Configure Git for Password-less Pull

**Option A: Using SSH (Recommended)**

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Display public key
cat ~/.ssh/id_ed25519.pub

# Add this key to GitHub:
# Go to GitHub Settings → SSH and GPG keys → New SSH key
# Paste the public key

# Update remote URL to use SSH
cd /home/ec2-user/cicdpractice
git remote set-url origin git@github.com:your-username/your-repo-name.git
```

**Option B: Using Personal Access Token**

```bash
# Create PAT: GitHub Settings → Developer settings → Personal access tokens → Generate new token
# Select repo scope

# Configure git to store credentials
git config --global credential.helper store

# Pull once to save credentials
git pull
# Enter username and PAT when prompted
```

### 3. Make Deployment Script Executable

```bash
chmod +x /home/ec2-user/cicdpractice/deploy.sh
```

### 4. Update Configuration

Edit the deployment script and update:
```bash
nano /home/ec2-user/cicdpractice/deploy.sh

# Update these lines:
GITHUB_REPO="your-username/your-repo-name"
APP_DIR="/home/ec2-user/cicdpractice"
```

### 5. Test Deployment Script

```bash
bash /home/ec2-user/cicdpractice/deploy.sh
```

## Setting Up Self-Hosted Runner

### 1. Add Runner to Repository

1. Go to your GitHub repository
2. Navigate to **Settings → Actions → Runners**
3. Click **New self-hosted runner**
4. Select **Linux** and **x64**
5. Follow the commands provided

### 2. Install Runner on EC2

```bash
# Create a folder for the runner
mkdir actions-runner && cd actions-runner

# Download the latest runner package
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz

# Extract the installer
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz

# Configure the runner
./config.sh --url https://github.com/your-username/your-repo-name --token YOUR_TOKEN

# Install as a service
sudo ./svc.sh install

# Start the runner service
sudo ./svc.sh start

# Check status
sudo ./svc.sh status
```

## How It Works

1. **Push Code**: Developer pushes code to master branch
2. **GitHub Actions Triggered**: Workflow detects push event
3. **Runner Executes**: Self-hosted runner on EC2 picks up the job
4. **Deployment Script Runs**: 
   - Pulls latest code from GitHub
   - Stops old container
   - Builds new Docker image
   - Starts new container

## Deployment Workflow File

Location: `.github/workflows/deploy.yml`

```yaml
name: Deploy Application

on:
  push:
    branches: [ "master" ]

jobs:
  deploy:
    runs-on: self-hosted

    steps:
    - name: Execute deployment script
      run: bash /home/ec2-user/cicdpractice/deploy.sh
```

## Deployment Script

Location: `deploy.sh`

The script performs:
- Git pull to get latest code
- Docker container stop/remove
- Docker image rebuild
- New container startup
- Status verification and log display

## Port Configuration

The container is bound to `127.0.0.1:8080:80`, meaning:
- Container runs on port 80 internally
- Mapped to port 8080 on localhost only
- Use nginx or another reverse proxy to expose publicly

## Troubleshooting

### Runner Not Picking Up Jobs

```bash
# Check runner service status
cd ~/actions-runner
sudo ./svc.sh status

# View runner logs
journalctl -u actions.runner.* -f
```

### Deployment Script Fails

```bash
# Run script manually with verbose output
bash -x /home/ec2-user/cicdpractice/deploy.sh

# Check Docker status
docker ps -a
docker logs cicd-pipeline
```

### Git Pull Fails

```bash
# Check git status
cd /home/ec2-user/cicdpractice
git status
git pull origin master

# Check credentials
git config --list
```

### Permission Issues

```bash
# Ensure ec2-user can run Docker without sudo
sudo usermod -aG docker ec2-user

# Logout and login again for changes to take effect
```

## Manual Deployment

If needed, you can manually trigger deployment:

```bash
ssh -i your-key.pem ec2-user@your-ec2-ip
bash /home/ec2-user/cicdpractice/deploy.sh
```

## Security Considerations

1. **Runner Security**: Self-hosted runner has access to your server
2. **Git Credentials**: Use SSH keys instead of passwords
3. **Container Isolation**: Container runs on localhost only
4. **Firewall Rules**: Ensure only necessary ports are open
5. **Regular Updates**: Keep Docker and OS updated

## Monitoring

### Check Application Status

```bash
# Container status
docker ps | grep cicd-pipeline

# View logs
docker logs -f cicd-pipeline

# Check resource usage
docker stats cicd-pipeline
```

### View Deployment History

Check GitHub Actions tab in your repository for deployment history and logs.

## Rolling Back

```bash
cd /home/ec2-user/cicdpractice
git log --oneline
git reset --hard <commit-hash>
bash deploy.sh
```

## Benefits of This Approach

✅ **No Docker Hub dependency** - Everything stays local  
✅ **Simpler workflow** - Single GitHub Action file  
✅ **Faster deployments** - No push/pull to registry  
✅ **Full control** - Direct access to deployment script  
✅ **Easy debugging** - Can run script manually  
✅ **Cost effective** - No external registry needed  

## Next Steps

1. Set up SSL/TLS with Let's Encrypt
2. Configure nginx as reverse proxy
3. Add health checks
4. Implement blue-green deployments
5. Add automated testing before deployment
