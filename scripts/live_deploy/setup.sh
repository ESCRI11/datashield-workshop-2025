#!/bin/bash

set -e

echo "Setting up DataShield Workshop environment..."

# Create necessary directories
echo "Creating directories..."
mkdir -p data/opal data/mongo logs ssl

# Make scripts executable
chmod +x generate-ssl.sh init-letsencrypt.sh renew-certs.sh

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "Warning: .env file not found. Please copy and configure it:"
    echo "  cp .env .env"
    echo "  # Edit .env with your domain settings"
    exit 1
fi

# Source environment variables
source .env

# Validate required variables
if [ -z "$DNS_DOMAIN" ]; then
    echo "Error: Please set DNS_DOMAIN in your .env file"
    exit 1
fi

echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Ensure your DNS points to this server: $DNS_DOMAIN"
echo "2. Start other services: docker-compose up -d mongo rock opal"
echo "3. Initialize Let's Encrypt certificates: ./init-letsencrypt.sh"
echo "4. Your site will be available at: https://$DNS_DOMAIN" 