#!/bin/bash

set -e

# Load environment variables from .env file
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found"
    exit 1
fi

# Check if required environment variables are set
if [ -z "$DNS_DOMAIN" ]; then
    echo "Error: DNS_DOMAIN must be set in .env file"
    exit 1
fi

echo "Initializing Let's Encrypt certificates for $DNS_DOMAIN..."

# Create necessary directories
mkdir -p ssl/live/$DNS_DOMAIN
mkdir -p ssl/archive/$DNS_DOMAIN

# Check if certificates already exist
if [ -f "ssl/live/$DNS_DOMAIN/fullchain.pem" ]; then
    echo "Certificates already exist. Skipping initialization."
    exit 0
fi

echo "Creating temporary self-signed certificate for initial nginx startup..."

# Create temporary self-signed certificate
openssl req -x509 -nodes -days 1 -newkey rsa:2048 \
    -keyout ssl/live/$DNS_DOMAIN/privkey.pem \
    -out ssl/live/$DNS_DOMAIN/fullchain.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=$DNS_DOMAIN"

echo "Starting nginx with temporary certificate..."

# Start nginx with temporary certificate
docker-compose up -d nginx

# Wait for nginx to be ready
sleep 10

echo "Requesting Let's Encrypt certificate..."

# Request the real certificate
docker-compose run --rm certbot

# Check if certificate was successfully created
if [ -f "ssl/live/$DNS_DOMAIN/fullchain.pem" ]; then
    echo "Certificate successfully obtained!"
    
    # Reload nginx with the new certificate
    docker-compose exec nginx nginx -s reload
    
    echo "Setup complete! Your site should now have a valid SSL certificate."
else
    echo "Failed to obtain certificate. Check the logs:"
    docker-compose logs certbot
    exit 1
fi 