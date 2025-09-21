#!/bin/bash

set -e

echo "Setting up DataShield Workshop environment..."

# Create necessary directories
echo "Creating directories..."
mkdir -p data/opal data/mongo logs ssl

# Generate SSL certificates if they don't exist
if [ ! -f "ssl/nginx-selfsigned.crt" ] || [ ! -f "ssl/nginx-selfsigned.key" ]; then
    echo "Generating SSL certificates..."
    ./generate-ssl.sh
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "Warning: .env file not found. Please copy and configure it:"
    echo "  cp .env.example .env"
    echo "  # Edit .env with your domain settings"
fi

echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Configure your .env file with proper domain settings"
echo "2. For production: Replace self-signed certificates with proper SSL certificates"
echo "3. Point your DNS to this server"
echo "4. Run: docker-compose up -d" 