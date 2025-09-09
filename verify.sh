#!/bin/bash
# KEmulator .app bundle verification script

set -e

APP_BUNDLE="KEmulator.app"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "KEmulator .app Bundle Verification"
echo "================================="

cd "$SCRIPT_DIR"

if [ ! -d "$APP_BUNDLE" ]; then
    echo "❌ Error: $APP_BUNDLE not found"
    echo "Run ./package.sh first to create the app bundle"
    exit 1
fi

echo "✅ App bundle exists: $APP_BUNDLE"

# Check bundle structure
required_files=(
    "Contents/Info.plist"
    "Contents/MacOS/KEmulator"
    "Contents/Resources/KEmulator.jar"
)

for file in "${required_files[@]}"; do
    if [ -f "$APP_BUNDLE/$file" ]; then
        echo "✅ Required file found: $file"
    else
        echo "❌ Missing required file: $file"
        exit 1
    fi
done

# Check if launcher script is executable
if [ -x "$APP_BUNDLE/Contents/MacOS/KEmulator" ]; then
    echo "✅ Launcher script is executable"
else
    echo "❌ Launcher script is not executable"
    exit 1
fi

# Check for macOS-specific libraries
macos_libs=(
    "Contents/Resources/libamrdecoder.dylib"
    "Contents/Resources/libjinput-osx.dylib"
    "Contents/Resources/lwjgl-natives-macos.jar"
    "Contents/Resources/swt-macosx-x86_64.jar"
)

macos_lib_count=0
for lib in "${macos_libs[@]}"; do
    if [ -f "$APP_BUNDLE/$lib" ]; then
        macos_lib_count=$((macos_lib_count + 1))
    fi
done

if [ $macos_lib_count -gt 0 ]; then
    echo "✅ Found $macos_lib_count macOS-specific libraries"
else
    echo "⚠️  Warning: No macOS-specific libraries found"
fi

# Check bundle identifier in Info.plist
if grep -q "cc.nnproject.kemulator" "$APP_BUNDLE/Contents/Info.plist"; then
    echo "✅ Correct bundle identifier found in Info.plist"
else
    echo "❌ Bundle identifier not found in Info.plist"
    exit 1
fi

# Count total files
total_files=$(find "$APP_BUNDLE" -type f | wc -l | tr -d ' ')
echo "✅ Total files in bundle: $total_files"

echo ""
echo "🎉 App bundle verification completed successfully!"
echo ""
echo "Bundle size:"
du -sh "$APP_BUNDLE"
echo ""
echo "To test the app bundle:"
echo "  open $APP_BUNDLE"
echo ""
echo "To install system-wide:"
echo "  sudo cp -R $APP_BUNDLE /Applications/"
echo ""