#!/bin/bash
# KEmulator .app bundle verification script
# Works with both manual and jpackage-generated bundles

set -e

APP_BUNDLE="KEmulator.app"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "KEmulator .app Bundle Verification"
echo "================================="

cd "$SCRIPT_DIR"

if [ ! -d "$APP_BUNDLE" ]; then
    echo "❌ Error: $APP_BUNDLE not found"
    echo "Run ./package.sh or ./package-jpackage.sh first to create the app bundle"
    exit 1
fi

echo "✅ App bundle exists: $APP_BUNDLE"

# Check bundle structure
required_files=(
    "Contents/Info.plist"
)

# Check for different launcher types (manual vs jpackage)
if [ -f "$APP_BUNDLE/Contents/MacOS/KEmulator" ]; then
    required_files+=("Contents/MacOS/KEmulator")
    BUNDLE_TYPE="manual"
elif [ -d "$APP_BUNDLE/Contents/runtime" ]; then
    # jpackage creates a runtime directory with bundled JRE
    BUNDLE_TYPE="jpackage"
    # Find the actual launcher executable
    launcher_executable=$(find "$APP_BUNDLE/Contents/MacOS" -type f -executable | head -n 1)
    if [ -n "$launcher_executable" ]; then
        required_files+=("$(echo "$launcher_executable" | sed "s|$APP_BUNDLE/||")")
    fi
else
    echo "❌ Unable to determine bundle type"
    exit 1
fi

# Check for KEmulator.jar in different locations
if [ -f "$APP_BUNDLE/Contents/Resources/KEmulator.jar" ]; then
    required_files+=("Contents/Resources/KEmulator.jar")
elif [ -f "$APP_BUNDLE/Contents/app/KEmulator.jar" ]; then
    required_files+=("Contents/app/KEmulator.jar")
    JAR_PATH="Contents/app"
else
    echo "❌ KEmulator.jar not found in expected locations"
    exit 1
fi

for file in "${required_files[@]}"; do
    if [ -f "$APP_BUNDLE/$file" ] || [ -d "$APP_BUNDLE/$file" ]; then
        echo "✅ Required file found: $file"
    else
        echo "❌ Missing required file: $file"
        exit 1
    fi
done

echo "✅ Bundle type: $BUNDLE_TYPE"

# Check if launcher is executable
launcher=$(find "$APP_BUNDLE/Contents/MacOS" -type f -executable | head -n 1)
if [ -n "$launcher" ] && [ -x "$launcher" ]; then
    echo "✅ Launcher is executable: $(basename "$launcher")"
else
    echo "❌ No executable launcher found"
    exit 1
fi

# Check for bundled JRE (jpackage feature)
if [ -d "$APP_BUNDLE/Contents/runtime" ]; then
    java_executable="$APP_BUNDLE/Contents/runtime/Contents/Home/bin/java"
    if [ -x "$java_executable" ]; then
        echo "✅ Bundled JRE found and executable"
        # Check JRE version
        jre_version=$("$java_executable" -version 2>&1 | head -n 1)
        echo "   JRE version: $jre_version"
    else
        echo "❌ Bundled JRE found but not executable"
        exit 1
    fi
else
    echo "ℹ️  No bundled JRE (manual bundle, requires system Java)"
fi

# Check for macOS-specific libraries (location depends on bundle type)
if [ "$BUNDLE_TYPE" = "jpackage" ]; then
    lib_dir="$APP_BUNDLE/Contents/app"
else
    lib_dir="$APP_BUNDLE/Contents/Resources"
fi

macos_libs=(
    "libamrdecoder.dylib"
    "libjinput-osx.dylib"
    "lwjgl-natives-macos.jar"
    "swt-macosx-x86_64.jar"
)

macos_lib_count=0
for lib in "${macos_libs[@]}"; do
    if [ -f "$lib_dir/$lib" ]; then
        macos_lib_count=$((macos_lib_count + 1))
    fi
done

if [ $macos_lib_count -gt 0 ]; then
    echo "✅ Found $macos_lib_count macOS-specific libraries"
else
    echo "⚠️  Warning: No macOS-specific libraries found"
fi

# Check bundle identifier in Info.plist (more flexible matching)
if grep -q "kemulator\|KEmulator" "$APP_BUNDLE/Contents/Info.plist"; then
    echo "✅ KEmulator bundle identifier found in Info.plist"
else
    echo "❌ KEmulator bundle identifier not found in Info.plist"
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