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

# Remove existing app bundle (but keep the structure we committed)
if [ -d "$APP_BUNDLE/Contents/Resources" ]; then
    echo "Cleaning app bundle resources..."
    # Remove all files but keep directory structure
    find "$APP_BUNDLE/Contents/Resources" -type f -delete 2>/dev/null || true
    find "$APP_BUNDLE/Contents/Resources" -type d -empty -delete 2>/dev/null || true
fi

echo "Running fresh package build..."
./package.sh

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