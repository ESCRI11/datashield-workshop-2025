#!/bin/bash

set -e

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi

if [ -z "$DNS_DOMAIN" ]; then
    echo "Error: DNS_DOMAIN must be set in .env file"
    exit 1
fi

echo "Getting SSL certificates for $DNS_DOMAIN..."

# Step 1: Clean up any existing certificates
echo "Cleaning up existing certificates..."
rm -rf ssl/live/$DNS_DOMAIN*
rm -rf ssl/archive/$DNS_DOMAIN*
rm -rf ssl/renewal/$DNS_DOMAIN*

# Step 2: Start nginx with HTTP-only config
echo "Starting nginx with HTTP-only configuration..."
sed -i 's|nginx-template.conf|nginx-http-only.conf|g' docker-compose.yml
docker-compose up -d nginx

# Step 3: Wait for nginx to be ready
sleep 5

# Step 4: Test ACME challenge path
echo "Testing ACME challenge path..."
docker-compose exec nginx sh -c 'mkdir -p /var/www/certbot && echo "test123" > /var/www/certbot/test'
if curl -f http://$DNS_DOMAIN/.well-known/acme-challenge/test >/dev/null 2>&1; then
    echo "✓ ACME challenge path is working"
else
    echo "✗ ACME challenge path is not accessible from internet"
    echo "Please check:"
    echo "1. DNS points to this server: nslookup $DNS_DOMAIN"
    echo "2. Port 80 is open in AWS Security Group"
    exit 1
fi

# Step 5: Get certificates
echo "Requesting SSL certificate from Let's Encrypt..."
docker-compose run --rm certbot

# Step 6: Check if certificates were created
if [ -f "ssl/live/$DNS_DOMAIN/fullchain.pem" ]; then
    echo "✓ SSL certificates obtained successfully!"
    
    # Step 7: Switch to full nginx config with SSL
    echo "Switching to full nginx configuration with SSL..."
    sed -i 's|nginx-http-only.conf|nginx-template.conf|g' docker-compose.yml
    docker-compose restart nginx
    
    echo "✓ Setup complete! Your site is available at:"
    echo "  https://$DNS_DOMAIN"
else
    echo "✗ Failed to obtain SSL certificates"
    echo "Check the logs: docker-compose logs certbot"
    exit 1
fi 