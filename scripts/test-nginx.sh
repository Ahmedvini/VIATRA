#!/bin/bash

# Nginx Configuration Test Script for Viatra Health Platform
# This script tests the nginx configuration without starting Docker

echo "🔧 Testing Nginx Configuration"
echo "==============================="

# Test nginx configuration syntax
echo "1. Testing nginx.conf syntax..."
if docker run --rm -v "$(pwd)/docker/nginx/nginx.conf:/etc/nginx/nginx.conf:ro" -v "$(pwd)/docker/nginx/conf.d:/etc/nginx/conf.d:ro" nginx:alpine nginx -t; then
    echo "✅ nginx.conf syntax is valid"
else
    echo "❌ nginx.conf has syntax errors"
    exit 1
fi

# Check SSL certificates exist
echo ""
echo "2. Checking SSL certificates..."
if [[ -f "docker/nginx/ssl/server.crt" && -f "docker/nginx/ssl/server.key" ]]; then
    echo "✅ SSL certificates exist"
    
    # Check certificate validity
    echo "   Certificate details:"
    openssl x509 -in docker/nginx/ssl/server.crt -text -noout | grep -E "(Subject|Not Before|Not After)"
else
    echo "❌ SSL certificates missing"
    echo "   Run: cd docker/nginx/ssl && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server.key -out server.crt -subj '/CN=localhost'"
    exit 1
fi

# Check directory structure
echo ""
echo "3. Verifying directory structure..."
required_dirs=("docker/nginx" "docker/nginx/conf.d" "docker/nginx/ssl" "docker/volumes")
for dir in "${required_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
        echo "✅ $dir exists"
    else
        echo "❌ $dir missing"
        exit 1
    fi
done

# Check required files
echo ""
echo "4. Checking required configuration files..."
required_files=("docker/nginx/nginx.conf" "docker/nginx/conf.d/default.conf")
for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
        exit 1
    fi
done

echo ""
echo "🎉 Nginx configuration is ready!"
echo ""
echo "Next steps:"
echo "1. Start services: docker-compose up -d"
echo "2. Test HTTPS: curl -k https://localhost/health"
echo "3. View logs: docker-compose logs nginx"
echo "4. Access via browser: https://localhost (accept certificate)"
