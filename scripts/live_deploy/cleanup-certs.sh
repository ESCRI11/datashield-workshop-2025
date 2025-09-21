#!/bin/bash

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi

if [ -z "$DNS_DOMAIN" ]; then
    echo "Error: DNS_DOMAIN must be set in .env file"
    exit 1
fi

echo "Cleaning up SSL certificates for $DNS_DOMAIN..."

# Stop nginx temporarily to avoid certificate in use errors
docker-compose stop nginx

# Remove all certificate directories for this domain
echo "Removing certificate directories..."
rm -rf ssl/live/$DNS_DOMAIN*
rm -rf ssl/archive/$DNS_DOMAIN*
rm -rf ssl/renewal/$DNS_DOMAIN*

# Create fresh temporary certificate for nginx startup
echo "Creating temporary certificate..."
mkdir -p ssl/live/$DNS_DOMAIN

openssl req -x509 -nodes -days 1 -newkey rsa:2048 \
    -keyout ssl/live/$DNS_DOMAIN/privkey.pem \
    -out ssl/live/$DNS_DOMAIN/fullchain.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=$DNS_DOMAIN"

echo "Cleanup complete. You can now run:"
echo "1. docker-compose up -d nginx"
echo "2. docker-compose run --rm certbot"
echo "3. docker-compose restart nginx" 