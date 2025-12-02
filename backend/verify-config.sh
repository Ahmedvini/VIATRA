#!/bin/bash

# Quick verification script to check if all Railway configs are in place

echo "================================================"
echo "Railway Deployment Configuration Verification"
echo "================================================"
echo ""

BACKEND_DIR="/home/ahmedvini/Music/VIATRA/backend"
ALL_GOOD=true

# Check if backend directory exists
if [ ! -d "$BACKEND_DIR" ]; then
    echo "❌ Backend directory not found at: $BACKEND_DIR"
    exit 1
fi

cd "$BACKEND_DIR"

echo "📋 Checking configuration files..."
echo ""

# Check railway.json
if [ -f "railway.json" ]; then
    echo "✅ railway.json exists"
    if grep -q "npm install --legacy-peer-deps" railway.json; then
        echo "   ✓ Contains npm install command"
    else
        echo "   ⚠️  May not have correct build command"
        ALL_GOOD=false
    fi
else
    echo "❌ railway.json missing"
    ALL_GOOD=false
fi
echo ""

# Check nixpacks.toml
if [ -f "nixpacks.toml" ]; then
    echo "✅ nixpacks.toml exists"
    if grep -q "legacy-peer-deps" nixpacks.toml; then
        echo "   ✓ Contains legacy-peer-deps configuration"
    else
        echo "   ⚠️  May not have correct npm configuration"
        ALL_GOOD=false
    fi
else
    echo "❌ nixpacks.toml missing"
    ALL_GOOD=false
fi
echo ""

# Check .npmrc
if [ -f ".npmrc" ]; then
    echo "✅ .npmrc exists"
    if grep -q "legacy-peer-deps" .npmrc; then
        echo "   ✓ Contains legacy-peer-deps setting"
    else
        echo "   ⚠️  May not have correct configuration"
        ALL_GOOD=false
    fi
else
    echo "❌ .npmrc missing"
    ALL_GOOD=false
fi
echo ""

# Check Dockerfile
if [ -f "Dockerfile" ]; then
    echo "✅ Dockerfile exists"
    if grep -q "npm install.*legacy-peer-deps" Dockerfile; then
        echo "   ✓ Contains npm install with legacy-peer-deps"
    else
        echo "   ⚠️  May still use npm ci"
        ALL_GOOD=false
    fi
else
    echo "❌ Dockerfile missing"
    ALL_GOOD=false
fi
echo ""

# Check package.json dependencies
if [ -f "package.json" ]; then
    echo "✅ package.json exists"
    if grep -q "@google/generative-ai" package.json; then
        echo "   ✓ Contains @google/generative-ai dependency"
    else
        echo "   ❌ Missing @google/generative-ai dependency"
        ALL_GOOD=false
    fi
    if grep -q "sharp" package.json; then
        echo "   ✓ Contains sharp dependency"
    else
        echo "   ❌ Missing sharp dependency"
        ALL_GOOD=false
    fi
else
    echo "❌ package.json missing"
    ALL_GOOD=false
fi
echo ""

# Check package-lock.json
if [ -f "package-lock.json" ]; then
    echo "⚠️  package-lock.json exists (may be outdated)"
    echo "   ℹ️  Should regenerate to sync with package.json"
else
    echo "⚠️  package-lock.json missing"
    echo "   ℹ️  This is OK - Railway config will handle it"
fi
echo ""

# Check Gemini service
if [ -f "src/services/gemini/geminiService.js" ]; then
    echo "✅ Gemini service exists"
    if grep -q "GoogleGenerativeAI" "src/services/gemini/geminiService.js"; then
        echo "   ✓ Imports Google Generative AI"
    fi
else
    echo "⚠️  Gemini service not found"
fi
echo ""

# Check helper script
if [ -f "generate-lockfile.sh" ]; then
    echo "✅ generate-lockfile.sh exists"
    if [ -x "generate-lockfile.sh" ]; then
        echo "   ✓ Is executable"
    else
        echo "   ⚠️  Not executable (run: chmod +x generate-lockfile.sh)"
    fi
else
    echo "⚠️  generate-lockfile.sh missing"
fi
echo ""

# Summary
echo "================================================"
if [ "$ALL_GOOD" = true ]; then
    echo "✅ ALL CONFIGURATION FILES ARE IN PLACE"
    echo ""
    echo "Railway deployment should work with the fallback"
    echo "configuration (npm install instead of npm ci)."
    echo ""
    echo "To ensure 100% reliability, generate package-lock.json:"
    echo "  ./generate-lockfile.sh"
else
    echo "⚠️  SOME ISSUES DETECTED"
    echo ""
    echo "Review the warnings above and fix any missing files."
fi
echo "================================================"
echo ""

# Show next steps
echo "📝 Next Steps:"
echo ""
echo "1. Check Railway dashboard for latest deployment status"
echo "   → Look for build success/failure"
echo ""
echo "2. If deployment is failing:"
echo "   → Generate package-lock.json: ./generate-lockfile.sh"
echo "   → Or check Railway logs for specific errors"
echo ""
echo "3. If deployment is succeeding:"
echo "   → Test health endpoint: curl https://your-app.railway.app/health"
echo "   → Check backend logs for any module errors"
echo ""
echo "4. Verify environment variables in Railway:"
echo "   → GEMINI_API_KEY"
echo "   → NODE_ENV=production"
echo "   → DATABASE_URL, REDIS_URL, etc."
echo ""
