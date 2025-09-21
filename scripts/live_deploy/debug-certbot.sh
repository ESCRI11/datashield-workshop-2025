#!/bin/bash

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi

echo "=== Debug Information ==="
echo "DNS_DOMAIN: $DNS_DOMAIN"
echo "Current directory: $(pwd)"
echo ""

echo "=== Checking DNS resolution ==="
nslookup $DNS_DOMAIN || echo "DNS lookup failed"
echo ""

echo "=== Testing HTTP connectivity ==="
curl -I http://$DNS_DOMAIN/.well-known/acme-challenge/test || echo "HTTP test failed"
echo ""

echo "=== Checking nginx status ==="
docker-compose ps nginx
echo ""

echo "=== Checking nginx logs ==="
docker-compose logs nginx | tail -10
echo ""

echo "=== Checking certbot logs ==="
if [ -f "ssl/logs/letsencrypt.log" ]; then
    echo "Recent certbot log entries:"
    tail -20 ssl/logs/letsencrypt.log
else
    echo "Certbot log not found at ssl/logs/letsencrypt.log"
    echo "Trying to get logs from container:"
    docker-compose run --rm certbot cat /var/log/letsencrypt/letsencrypt.log | tail -20 || echo "Could not access certbot logs"
fi
echo ""

echo "=== SSL directory contents ==="
find ssl -type f -ls 2>/dev/null || echo "SSL directory not accessible" 