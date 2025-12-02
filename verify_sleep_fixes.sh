#!/bin/bash

# Sleep Tracking Fix Verification Script
# Run this after rebuilding the mobile app

echo "======================================"
echo "Sleep Tracking Fix Verification"
echo "======================================"
echo ""

echo "📋 Pre-flight Checklist:"
echo "------------------------"
echo ""

# Check if we're in the right directory
if [ ! -d "mobile" ]; then
    echo "❌ Error: mobile directory not found. Run this from project root."
    exit 1
fi

echo "✅ Project structure verified"
echo ""

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter not found. Please install Flutter."
    exit 1
fi

echo "✅ Flutter is installed"
echo ""

# Check modified files exist
echo "📁 Checking modified files..."
if [ -f "mobile/lib/screens/sleep_tracking/active_sleep_screen.dart" ]; then
    echo "  ✅ active_sleep_screen.dart"
else
    echo "  ❌ active_sleep_screen.dart not found"
    exit 1
fi

if [ -f "mobile/lib/services/sleep_tracking_service.dart" ]; then
    echo "  ✅ sleep_tracking_service.dart"
else
    echo "  ❌ sleep_tracking_service.dart not found"
    exit 1
fi
echo ""

echo "🔍 Verifying key fixes in code..."
echo ""

# Check for _pausedAt variable
if grep -q "DateTime? _pausedAt" mobile/lib/screens/sleep_tracking/active_sleep_screen.dart; then
    echo "  ✅ Pause timestamp tracking added"
else
    echo "  ⚠️  Warning: _pausedAt variable not found"
fi

# Check for conditional timer update
if grep -q "if (mounted && _session.status == 'active')" mobile/lib/screens/sleep_tracking/active_sleep_screen.dart; then
    echo "  ✅ Conditional timer update implemented"
else
    echo "  ⚠️  Warning: Conditional timer update not found"
fi

# Check for improved response parsing
if grep -q "if (sessionData == null)" mobile/lib/services/sleep_tracking_service.dart; then
    echo "  ✅ Null safety checks added"
else
    echo "  ⚠️  Warning: Null safety checks not found"
fi

echo ""
echo "======================================"
echo "🚀 Build & Test Instructions"
echo "======================================"
echo ""
echo "1. Clean and rebuild the app:"
echo "   cd mobile"
echo "   flutter clean"
echo "   flutter pub get"
echo "   flutter run"
echo ""
echo "2. Test Scenarios:"
echo ""
echo "   Timer Functionality:"
echo "   • Start sleep → Verify timer starts from 00:00:00"
echo "   • Wait 1-2 min → Verify timer updates every second"
echo "   • Pause → Verify timer freezes"
echo "   • Wait 30 sec → Verify timer stays frozen"
echo "   • Resume → Verify timer continues from pause point"
echo ""
echo "   Pause/Resume:"
echo "   • Start sleep → Pause with reason → No crash?"
echo "   • Check UI changes to 'You're Awake' (orange)"
echo "   • Resume → Check UI changes to 'Sweet Dreams' (indigo)"
echo "   • Verify success messages appear"
echo ""
echo "   Error Handling:"
echo "   • Test with airplane mode"
echo "   • Verify proper error messages"
echo "   • App should not crash"
echo ""
echo "======================================"
echo "📊 Expected Results"
echo "======================================"
echo ""
echo "✅ Timer updates when active"
echo "✅ Timer freezes when paused"
echo "✅ No type errors on pause/resume"
echo "✅ Smooth UI transitions"
echo "✅ Proper error messages"
echo ""
echo "======================================"
echo ""

# Offer to start the build
read -p "Would you like to rebuild the app now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🔨 Starting build process..."
    echo ""
    cd mobile
    flutter clean
    flutter pub get
    echo ""
    echo "✅ Build preparation complete!"
    echo ""
    echo "Now run: flutter run -d <device>"
    echo ""
    echo "Available devices:"
    flutter devices
else
    echo ""
    echo "Skipping build. Run manually when ready."
fi

echo ""
echo "======================================"
echo "📚 Documentation"
echo "======================================"
echo ""
echo "For detailed fix information, see:"
echo "  • SLEEP_TRACKING_FIXES.md"
echo ""
echo "For full project status, see:"
echo "  • PHQ9_INTEGRATION_COMPLETE.md"
echo "  • QUICK_START_PHQ9.md"
echo ""
echo "======================================"
echo "✅ Verification Complete"
echo "======================================"
