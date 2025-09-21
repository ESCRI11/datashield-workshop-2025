# DataShield Workshop - Live Deployment

This setup provides a complete DataShield environment with a reverse proxy for production deployment on AWS or any cloud provider.

## Architecture

- **Nginx**: Reverse proxy with SSL termination, security headers, and rate limiting
- **Opal**: DataShield administration server
- **Rock**: R computation server for DataShield
- **MongoDB**: Database backend for Opal

## Quick Start

### 1. Configure Environment

Copy and edit the environment file:
```bash
cp .env.example .env
# Edit .env with your domain settings
```

### 2. Run Setup Script

```bash
chmod +x setup.sh generate-ssl.sh
./setup.sh
```

### 3. Deploy

```bash
docker-compose up -d
```

## Environment Configuration

Edit `.env` file with your settings:

```bash
# DNS Configuration
DNS_DOMAIN=your-domain.com          # Your main domain

# Opal Configuration
OPAL_ADMINISTRATOR_PASSWORD=your-secure-password

# SSL Configuration (for production)
SSL_EMAIL=admin@your-domain.com

# Network Configuration
HTTP_PORT=80                        # HTTP port (redirects to HTTPS)
HTTPS_PORT=443                      # HTTPS port
```

## AWS Deployment Guide

### 1. EC2 Instance Setup

1. Launch an EC2 instance (recommended: t3.medium or larger)
2. Security Group rules:
   - Port 80 (HTTP) - open to 0.0.0.0/0
   - Port 443 (HTTPS) - open to 0.0.0.0/0
   - Port 22 (SSH) - open to your IP

### 2. Domain Configuration

1. Point your domain DNS to the EC2 instance public IP:
   ```
   A record: your-domain.com -> YOUR_EC2_PUBLIC_IP
   ```

### 3. SSL Certificates (Production)

For production, replace self-signed certificates with Let's Encrypt:

```bash
# Install certbot
sudo apt-get update
sudo apt-get install certbot

# Stop nginx temporarily
docker-compose stop nginx

# Generate certificates
sudo certbot certonly --standalone -d your-domain.com

# Copy certificates
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem ssl/nginx-selfsigned.crt
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem ssl/nginx-selfsigned.key

# Restart services
docker-compose up -d
```

## Accessing Services

- **DataShield Opal**: https://your-domain.com
- **Health Check**: https://your-domain.com/health

Default Opal credentials:
- Username: `administrator`
- Password: Value from `OPAL_ADMINISTRATOR_PASSWORD` in `.env`

## Monitoring and Logs

View logs:
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f nginx
docker-compose logs -f opal
```

## Security Features

- **SSL/TLS**: HTTPS with modern cipher suites
- **Security Headers**: XSS protection, content type sniffing prevention
- **Rate Limiting**: API rate limiting to prevent abuse
- **Proxy Headers**: Proper forwarding of client information

## Maintenance

### Backup Data

```bash
# Backup MongoDB data
docker-compose exec mongo mongodump --out /data/backup

# Backup Opal data
tar -czf opal-backup.tar.gz data/opal/
```

### Update Services

```bash
docker-compose pull
docker-compose up -d
```

## Troubleshooting

### Check Service Status
```bash
docker-compose ps
```

### Test Nginx Configuration
```bash
docker-compose exec nginx nginx -t
```

### View Nginx Error Logs
```bash
docker-compose logs nginx
```

### Common Issues

1. **SSL Certificate Issues**: Check certificate files in `ssl/` directory
2. **DNS Issues**: Verify domain points to correct IP
3. **Port Issues**: Ensure ports 80/443 are open in security groups
4. **Memory Issues**: Consider upgrading instance size for heavy workloads 