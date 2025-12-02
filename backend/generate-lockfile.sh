#!/bin/bash

# Script to generate package-lock.json for Railway deployment
# Run this script in an environment where Node.js/npm is available

set -e

echo "========================================"
echo "Generating package-lock.json for Railway"
echo "========================================"
echo ""

# Check if npm is available
if ! command -v npm &> /dev/null; then
    echo "❌ Error: npm is not installed"
    echo ""
    echo "Please install Node.js and npm first:"
    echo "  - Ubuntu/Debian: sudo apt-get install nodejs npm"
    echo "  - macOS: brew install node"
    echo "  - Or download from: https://nodejs.org/"
    exit 1
fi

# Show Node.js and npm versions
echo "📦 Node.js version: $(node --version)"
echo "📦 npm version: $(npm --version)"
echo ""

# Navigate to backend directory
cd "$(dirname "$0")"

echo "🔍 Current directory: $(pwd)"
echo ""

# Remove old package-lock.json and node_modules to start fresh
echo "🧹 Cleaning up old files..."
rm -f package-lock.json
rm -rf node_modules
echo "✓ Cleanup complete"
echo ""

# Generate fresh package-lock.json
echo "📝 Generating package-lock.json..."
npm install --package-lock-only --legacy-peer-deps
echo "✓ package-lock.json generated successfully"
echo ""

# Verify the lock file exists
if [ -f "package-lock.json" ]; then
    echo "✅ Success! package-lock.json has been created"
    echo ""
    echo "File size: $(wc -c < package-lock.json) bytes"
    echo "Packages: $(grep -o '"node_modules/' package-lock.json | wc -l) modules"
    echo ""
    echo "Next steps:"
    echo "  1. Review the generated package-lock.json"
    echo "  2. Commit the file: git add package-lock.json"
    echo "  3. Commit: git commit -m 'Add synced package-lock.json for Railway deployment'"
    echo "  4. Push: git push origin main"
    echo "  5. Railway will automatically redeploy with the new lock file"
else
    echo "❌ Error: package-lock.json was not created"
    exit 1
fi
