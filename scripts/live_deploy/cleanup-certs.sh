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
