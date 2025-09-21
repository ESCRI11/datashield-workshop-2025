#!/bin/bash

set -e

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found"
    exit 1
fi

if [ -z "$DNS_DOMAIN" ]; then
    echo "Error: DNS_DOMAIN must be set in .env file"
    exit 1
fi

echo "Setting up DataShield with Let's Encrypt for $DNS_DOMAIN..."

# Create directories
mkdir -p data/opal data/mongo logs ssl

# Clean up any existing certificates to avoid numbering
echo "Cleaning up existing certificates..."
rm -rf ssl/live/$DNS_DOMAIN*
rm -rf ssl/archive/$DNS_DOMAIN*
rm -rf ssl/renewal/$DNS_DOMAIN*

echo "Starting services..."

# Start backend services first
docker-compose up -d mongo rock opal

echo "Requesting SSL certificate..."

# Start certbot to get certificates
docker-compose up certbot

echo "Starting nginx (will restart automatically once certificates are ready)..."

# Start nginx - it will fail and restart until certificates are available
docker-compose up -d nginx

echo ""
echo "Setup complete!"
echo "- Nginx is starting and will restart until SSL certificates are ready"
echo "- Your site will be available at: https://$DNS_DOMAIN"
echo "- Monitor with: docker-compose logs -f nginx" 