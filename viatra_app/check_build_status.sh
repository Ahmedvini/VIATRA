#!/bin/sh

echo "=== VIATRA Health Platform - Build Status Check ==="
echo ""
echo "Checking environment..."

cd /home/ahmedvini/Documents/VIATRA/viatra_app

# Check Flutter
echo "Flutter version:"
flutter --version | head -3

echo ""
echo "Running analysis (this may take a minute)..."
echo ""

# Run analysis and parse output
flutter analyze --no-pub 2>&1 > /tmp/analysis_full.txt

# Count errors
ERROR_COUNT=$(grep -c "error •" /tmp/analysis_full.txt || echo "0")
WARNING_COUNT=$(grep -c "warning •" /tmp/analysis_full.txt || echo "0")
INFO_COUNT=$(grep -c "info •" /tmp/analysis_full.txt || echo "0")

echo "=== Analysis Summary ==="
echo "Errors: $ERROR_COUNT"
echo "Warnings: $WARNING_COUNT"
echo "Info: $INFO_COUNT"
echo ""

if [ "$ERROR_COUNT" -gt "0" ]; then
    echo "=== First 20 Errors ==="
    grep -A2 "error •" /tmp/analysis_full.txt | head -60
    echo ""
fi

echo "Full analysis saved to: /tmp/analysis_full.txt"
echo ""
echo "=== Next Steps ==="
if [ "$ERROR_COUNT" -eq "0" ]; then
    echo "✓ No errors found! Ready to build."
    echo "Run: flutter build apk --debug"
else
    echo "✗ $ERROR_COUNT errors need to be fixed."
    echo "Check /tmp/analysis_full.txt for details"
fi
