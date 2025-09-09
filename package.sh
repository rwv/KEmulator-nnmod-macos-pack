#!/bin/bash
# KEmulator macOS App Packager
# This script downloads KEmulator v2.20 and packages it into a macOS .app bundle

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="$SCRIPT_DIR/build"
APP_BUNDLE="$SCRIPT_DIR/KEmulator.app"
DOWNLOAD_URL="https://github.com/shinovon/KEmulator/releases/download/v2.20/kemnnx64.v2.20.zip"
ZIP_FILE="kemnnx64.v2.20.zip"
KEMULATOR_DIR="kemnnx64"

echo "KEmulator macOS App Packager"
echo "============================"

# Create build directory
echo "Creating build directory..."
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Download KEmulator if not already present
if [ ! -f "$ZIP_FILE" ]; then
    echo "Downloading KEmulator v2.20..."
    curl -L -o "$ZIP_FILE" "$DOWNLOAD_URL"
else
    echo "Using existing download: $ZIP_FILE"
fi

# Extract if not already extracted
if [ ! -d "$KEMULATOR_DIR" ]; then
    echo "Extracting KEmulator..."
    unzip -q "$ZIP_FILE"
else
    echo "Using existing extracted files: $KEMULATOR_DIR"
fi

# Verify the .app bundle structure exists
if [ ! -d "$APP_BUNDLE" ]; then
    echo "Error: $APP_BUNDLE not found. Please ensure the .app bundle structure is created first."
    exit 1
fi

echo "Copying KEmulator files to .app bundle..."

# Copy all necessary files to Resources directory
RESOURCES_DIR="$APP_BUNDLE/Contents/Resources"

# Copy main JAR
cp "$KEMULATOR_DIR/KEmulator.jar" "$RESOURCES_DIR/"

# Copy macOS-specific native libraries
cp "$KEMULATOR_DIR"/*.dylib "$RESOURCES_DIR/" 2>/dev/null || true
cp "$KEMULATOR_DIR"/*.jnilib "$RESOURCES_DIR/" 2>/dev/null || true

# Copy macOS-specific LWJGL natives
cp "$KEMULATOR_DIR"/lwjgl*-natives-macos*.jar "$RESOURCES_DIR/"
cp "$KEMULATOR_DIR"/lwjgl*-macos*.jar "$RESOURCES_DIR/"

# Copy SWT macOS libraries
cp "$KEMULATOR_DIR"/swt-macosx-*.jar "$RESOURCES_DIR/"

# Copy universal files that work on all platforms
cp "$KEMULATOR_DIR/sensorsimulator.jar" "$RESOURCES_DIR/"

# Copy language files
if [ -d "$KEMULATOR_DIR/lang" ]; then
    cp -r "$KEMULATOR_DIR/lang" "$RESOURCES_DIR/"
fi

# Copy uei directory (J2ME APIs)
if [ -d "$KEMULATOR_DIR/uei" ]; then
    cp -r "$KEMULATOR_DIR/uei" "$RESOURCES_DIR/"
fi

# Copy builder if present
if [ -f "$KEMULATOR_DIR/builder.jar" ]; then
    cp "$KEMULATOR_DIR/builder.jar" "$RESOURCES_DIR/"
fi

echo ""
echo "Packaging complete!"
echo "Created: $APP_BUNDLE"
echo ""
echo "Usage:"
echo "  - Double-click KEmulator.app to launch the emulator"
echo "  - Drag .jar files onto the app icon to run them in the emulator"
echo "  - Right-click .jar files and choose 'Open With > KEmulator'"
echo ""
echo "To install system-wide:"
echo "  sudo cp -R KEmulator.app /Applications/"
echo ""