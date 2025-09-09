#!/bin/bash
# Clean build script for KEmulator.app
# This script removes any existing build artifacts and creates a fresh .app bundle

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_BUNDLE="$SCRIPT_DIR/KEmulator.app"
BUILD_DIR="$SCRIPT_DIR/build"

echo "KEmulator Clean Build"
echo "===================="

cd "$SCRIPT_DIR"

# Remove existing build artifacts
if [ -d "$BUILD_DIR" ]; then
    echo "Removing existing build directory..."
    rm -rf "$BUILD_DIR"
fi

# Remove existing app bundle completely for clean build
if [ -d "$APP_BUNDLE" ]; then
    echo "Removing existing app bundle..."
    rm -rf "$APP_BUNDLE"
fi

# Ask user which build method to use
echo ""
echo "Choose build method:"
echo "1) jpackage (recommended - self-contained with bundled JRE)"
echo "2) manual (legacy - requires system Java)"
echo ""
read -p "Enter choice (1 or 2): " choice

case $choice in
    1)
        echo "Building with jpackage..."
        ./package-jpackage.sh
        ;;
    2)
        echo "Building with manual packaging..."
        ./package.sh
        ;;
    *)
        echo "Invalid choice. Defaulting to jpackage..."
        ./package-jpackage.sh
        ;;
esac

echo ""
echo "Running verification..."
./verify.sh

echo ""
echo "✅ Clean build completed successfully!"
echo ""
echo "The app bundle is ready for distribution:"
echo "  $APP_BUNDLE"
echo ""
echo "To create a distributable archive:"
echo "  zip -r KEmulator-macOS-v2.20.zip KEmulator.app"
echo ""