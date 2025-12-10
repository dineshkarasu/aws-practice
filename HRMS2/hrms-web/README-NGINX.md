# NGINX Configuration Guide

This directory contains two NGINX configuration files:

## Configuration Files

### 1. `nginx.dev.conf` - Development Configuration (HTTP Only)
- **Use for**: Local development, testing
- **Protocol**: HTTP only (port 80)
- **SSL**: Not required
- **Domains**: localhost, any IP
- **Default**: Used by default in Dockerfile

### 2. `nginx.conf` - Production Configuration (HTTPS)
- **Use for**: Production deployment with SSL/TLS
- **Protocol**: HTTPS (port 443) with HTTP redirect
- **SSL**: Requires Let's Encrypt certificates
- **Domains**: hrms.zamait.in (configurable)
- **Certificates**: Mounts from `/etc/letsencrypt`

## Switching Between Configurations

### Method 1: At Build Time
Edit `Dockerfile` to change which config is copied as `default.conf`:

```dockerfile
# For development (default)
COPY nginx.dev.conf /etc/nginx/conf.d/default.conf

# For production
COPY nginx.conf /etc/nginx/conf.d/default.conf
```

### Method 2: At Runtime (Override)
Mount the desired config at container runtime:

```bash
# Development
docker run -v $(pwd)/nginx.dev.conf:/etc/nginx/conf.d/default.conf ...

# Production
docker run -v $(pwd)/nginx.conf:/etc/nginx/conf.d/default.conf ...
```

### Method 3: Environment-Based (Recommended)
Modify docker-compose.yml to use environment-specific configs:

```yaml
services:
  web:
    volumes:
      - ./hrms-web/nginx.${ENVIRONMENT:-dev}.conf:/etc/nginx/conf.d/default.conf:ro
```

## SSL Certificate Setup

For production with HTTPS (`nginx.conf`):

1. **Obtain SSL certificates** using Let's Encrypt:
   ```bash
   ./setup-ssl.sh
   ```

2. **Ensure certificates are mounted** in docker-compose.yml:
   ```yaml
   volumes:
     - ./certbot/conf:/etc/letsencrypt:ro
     - ./certbot/www:/var/www/certbot:ro
   ```

3. **Update domain name** in nginx.conf:
   - Replace `hrms.zamait.in` with your domain
   - Update certificate paths accordingly

## Testing Configuration

Test nginx config syntax before deploying:

```bash
# Inside container
docker exec hrms-web nginx -t

# Or test locally if nginx installed
nginx -t -c nginx.dev.conf
```

## Common Issues

### Issue: 502 Bad Gateway
- **Cause**: Backend API not accessible
- **Fix**: Check API service is running: `docker ps` and verify network connectivity

### Issue: SSL Certificate Error
- **Cause**: Using nginx.conf without certificates
- **Fix**: Either:
  - Use `nginx.dev.conf` for local development
  - Run `./setup-ssl.sh` to obtain certificates

### Issue: CORS Errors
- **Cause**: API CORS not matching frontend origin
- **Fix**: Check backend CORS configuration matches nginx proxy headers

## Environment Variables

Both configs support these proxy headers:
- `X-Real-IP`: Client's real IP address
- `X-Forwarded-For`: Full proxy chain
- `X-Forwarded-Proto`: Original protocol (http/https)
- `Host`: Original host header

## Performance Tuning

Both configurations include:
- **Gzip compression** for text assets
- **Static asset caching** (1 year for immutable files)
- **HTTP/2** support (production only)
- **Connection keep-alive**

## Security Headers

Applied in both configurations:
- `X-Frame-Options: SAMEORIGIN`
- `X-Content-Type-Options: nosniff`
- `X-XSS-Protection: 1; mode=block`

Production adds:
- SSL/TLS protocols: TLSv1.2, TLSv1.3
- Strong cipher suites
- SSL session caching
