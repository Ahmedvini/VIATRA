#!/bin/bash

# Script to update the mobile app .env file with Railway backend URL

echo "================================================"
echo "VIATRA Mobile App - Railway Setup Script"
echo "================================================"
echo ""

# Check if .env file exists
if [ ! -f "/home/ahmedvini/Music/VIATRA/mobile/.env" ]; then
    echo "ERROR: .env file not found at /home/ahmedvini/Music/VIATRA/mobile/.env"
    exit 1
fi

echo "Current API configuration:"
grep "API_BASE_URL" /home/ahmedvini/Music/VIATRA/mobile/.env
grep "WS_BASE_URL" /home/ahmedvini/Music/VIATRA/mobile/.env
echo ""

# Prompt for Railway URL
echo "Please enter your Railway backend URL"
echo "(Example: https://viatra-backend-production.up.railway.app)"
read -p "Railway URL: " RAILWAY_URL

# Remove trailing slash if present
RAILWAY_URL="${RAILWAY_URL%/}"

# Validate URL format
if [[ ! "$RAILWAY_URL" =~ ^https?:// ]]; then
    echo "ERROR: URL must start with http:// or https://"
    exit 1
fi

# Extract just the domain for wss:// URL
WSS_URL=$(echo "$RAILWAY_URL" | sed 's/^http:/wss:/' | sed 's/^https:/wss:/')

echo ""
echo "Will update .env with:"
echo "  API_BASE_URL=$RAILWAY_URL/api/v1"
echo "  WS_BASE_URL=$WSS_URL"
echo ""

read -p "Continue? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "Cancelled."
    exit 0
fi

# Create backup
cp /home/ahmedvini/Music/VIATRA/mobile/.env /home/ahmedvini/Music/VIATRA/mobile/.env.backup
echo "Backup created at: /home/ahmedvini/Music/VIATRA/mobile/.env.backup"

# Update the .env file
sed -i "s|API_BASE_URL=.*|API_BASE_URL=$RAILWAY_URL/api/v1|g" /home/ahmedvini/Music/VIATRA/mobile/.env
sed -i "s|WS_BASE_URL=.*|WS_BASE_URL=$WSS_URL|g" /home/ahmedvini/Music/VIATRA/mobile/.env

echo ""
echo "✓ Updated .env file successfully!"
echo ""
echo "New configuration:"
grep "API_BASE_URL" /home/ahmedvini/Music/VIATRA/mobile/.env
grep "WS_BASE_URL" /home/ahmedvini/Music/VIATRA/mobile/.env
echo ""
echo "================================================"
echo "Next Steps:"
echo "================================================"
echo "1. Rebuild the Flutter app:"
echo "   cd /home/ahmedvini/Music/VIATRA/mobile"
echo "   flutter clean && flutter pub get && flutter run"
echo ""
echo "2. Test the registration flow"
echo ""
echo "3. Check the debug console for connection logs"
echo "================================================"
