# 🔒 SSL/HTTPS Setup Guide for HRMS

## Prerequisites
- Domain `hrms.zamait.in` must point to your EC2 instance IP
- EC2 Security Group must allow:
  - Port 80 (HTTP) - for certificate validation
  - Port 443 (HTTPS) - for secure traffic
  - Port 22 (SSH) - for administration

---

## Quick Setup (Automated)

### On your EC2 instance:

```bash
cd ~/aws-training/devops/hackathon/HRMS

# Make script executable
chmod +x setup-ssl.sh

# Run the setup script
./setup-ssl.sh
```

This will:
1. Install Certbot
2. Stop the application temporarily
3. Obtain SSL certificate from Let's Encrypt
4. Configure Nginx with SSL
5. Restart the application with HTTPS

---

## Manual Setup

### Step 1: Verify Domain Configuration

```bash
# Check if domain points to this server
dig hrms.zamait.in +short
# Should return your EC2 public IP
```

### Step 2: Install Certbot

```bash
sudo yum install certbot -y
```

### Step 3: Stop Application

```bash
cd ~/aws-training/devops/hackathon/HRMS
docker-compose down
```

### Step 4: Obtain SSL Certificate

```bash
sudo certbot certonly \
    --standalone \
    --preferred-challenges http \
    --email admin@zamait.in \
    --agree-tos \
    --domains hrms.zamait.in \
    --non-interactive
```

### Step 5: Copy Certificates to Project

```bash
# Create directories
mkdir -p certbot/conf
mkdir -p certbot/www
mkdir -p ssl

# Copy certificates
sudo cp -r /etc/letsencrypt/* ./certbot/conf/
sudo chown -R $USER:$USER ./certbot/conf
```

### Step 6: Update Configuration

The configuration is already updated in:
- `docker-compose.yml` - Exposes port 443 and mounts SSL certificates
- `frontend/nginx.conf` - Configured for HTTPS with HTTP redirect

### Step 7: Start Application

```bash
docker-compose up -d --build
```

---

## Verification

### Test HTTPS Connection

```bash
# Check certificate
curl -I https://hrms.zamait.in

# Test API
curl https://hrms.zamait.in/health

# View certificate details
openssl s_client -connect hrms.zamait.in:443 -servername hrms.zamait.in < /dev/null
```

### Check Certificate Status

```bash
sudo certbot certificates
```

---

## Certificate Auto-Renewal

Let's Encrypt certificates expire every 90 days. Set up automatic renewal:

### Add Cron Job

```bash
# Edit crontab
sudo crontab -e

# Add this line (runs daily at 3 AM)
0 3 * * * certbot renew --quiet --post-hook 'cd /home/ec2-user/aws-training/devops/hackathon/HRMS && docker-compose restart web'
```

### Test Renewal (Dry Run)

```bash
sudo certbot renew --dry-run
```

---

## Security Group Configuration

Ensure your EC2 Security Group has these inbound rules:

| Port | Protocol | Source | Description |
|------|----------|--------|-------------|
| 22   | TCP      | Your IP | SSH |
| 80   | TCP      | 0.0.0.0/0 | HTTP (redirects to HTTPS) |
| 443  | TCP      | 0.0.0.0/0 | HTTPS |

---

## Nginx SSL Configuration Details

Current SSL configuration in `nginx.conf`:

```nginx
# HTTP -> HTTPS Redirect
listen 80;
return 301 https://$host$request_uri;

# HTTPS Server
listen 443 ssl http2;
ssl_certificate /etc/letsencrypt/live/hrms.zamait.in/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/hrms.zamait.in/privkey.pem;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers HIGH:!aNULL:!MD5;
```

---

## Troubleshooting

### Certificate Obtainment Failed

**Issue**: `Certbot failed to authenticate`

**Solutions**:
1. Verify domain DNS:
   ```bash
   dig hrms.zamait.in +short
   ```
2. Check port 80 is accessible:
   ```bash
   sudo netstat -tlnp | grep :80
   ```
3. Ensure security group allows port 80

### Certificate Not Found in Container

**Issue**: `SSL certificate not found`

**Solution**:
```bash
# Verify certificates are mounted
docker exec hrms-web ls -la /etc/letsencrypt/live/

# If missing, check volume mounts
docker-compose down
docker-compose up -d
```

### HTTPS Not Working

**Issue**: Can access HTTP but not HTTPS

**Solutions**:
1. Check port 443 in security group
2. Verify container is listening on 443:
   ```bash
   docker-compose ps
   netstat -tlnp | grep :443
   ```
3. Check logs:
   ```bash
   docker-compose logs web
   ```

### Mixed Content Warnings

**Issue**: Browser shows "Not Secure" or mixed content warnings

**Solution**: Update frontend API URL to use HTTPS:
```bash
# In docker-compose.yml, web service:
REACT_APP_API_URL=https://hrms.zamait.in
```

---

## Certificate Information

### View Certificate Details

```bash
sudo certbot certificates
```

### Manual Renewal

```bash
sudo certbot renew
docker-compose restart web
```

### Revoke Certificate (if needed)

```bash
sudo certbot revoke --cert-path /etc/letsencrypt/live/hrms.zamait.in/fullchain.pem
```

---

## URLs After SSL Setup

- **Frontend**: `https://hrms.zamait.in/`
- **API Docs**: `https://hrms.zamait.in/docs`
- **API ReDoc**: `https://hrms.zamait.in/redoc`
- **Health Check**: `https://hrms.zamait.in/health`

HTTP requests will automatically redirect to HTTPS.

---

## Best Practices

1. ✅ Always use HTTPS in production
2. ✅ Set up automatic certificate renewal
3. ✅ Monitor certificate expiration (90 days)
4. ✅ Use strong SSL protocols (TLSv1.2+)
5. ✅ Keep Certbot updated
6. ✅ Regular security audits

---

## SSL Security Check

Test your SSL configuration:
- https://www.ssllabs.com/ssltest/analyze.html?d=hrms.zamait.in

---

**SSL Setup Complete! 🔒**

Your application is now secured with HTTPS from Let's Encrypt!
