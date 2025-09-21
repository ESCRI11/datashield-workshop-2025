#!/bin/bash

set -e

echo "Renewing Let's Encrypt certificates..."

# Renew certificates
docker-compose run --rm certbot renew

# Reload nginx to use renewed certificates
docker-compose exec nginx nginx -s reload

echo "Certificate renewal complete!" 