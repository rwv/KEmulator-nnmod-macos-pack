#!/bin/bash
# KEmulator macOS App Packager using jpackage
# This script downloads KEmulator v2.20 and packages it into a self-contained macOS .app bundle with bundled JRE

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="$SCRIPT_DIR/build"
INPUT_DIR="$WORK_DIR/input"
APP_BUNDLE="$SCRIPT_DIR/KEmulator.app"
DOWNLOAD_URL="https://github.com/shinovon/KEmulator/releases/download/v2.20/kemnnx64.v2.20.zip"
ZIP_FILE="kemnnx64.v2.20.zip"
KEMULATOR_DIR="kemnnx64"

echo "KEmulator macOS App Packager (jpackage)"
echo "======================================="

# Check if jpackage is available
if ! command -v jpackage &> /dev/null; then
    echo "Error: jpackage not found. Please ensure you have Java 14+ installed."
    exit 1
fi

# Check Java version for jpackage compatibility
JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{print $1}')
if [ "$JAVA_VERSION" -lt 14 ]; then
    echo "Error: jpackage requires Java 14 or later. Current version: $JAVA_VERSION"
    exit 1
fi

# Create build directories
echo "Creating build directories..."
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
mkdir -p "$INPUT_DIR"
cd "$WORK_DIR"

# Download KEmulator if not already present
if [ ! -f "$ZIP_FILE" ]; then
    echo "Downloading KEmulator v2.20..."
    curl -L -o "$ZIP_FILE" "$DOWNLOAD_URL"
else
    echo "Using existing download: $ZIP_FILE"
fi

# Extract KEmulator
echo "Extracting KEmulator..."
unzip -q "$ZIP_FILE"

# Prepare input directory for jpackage
echo "Preparing files for jpackage..."

# Copy main JAR
cp "$KEMULATOR_DIR/KEmulator.jar" "$INPUT_DIR/"

# Copy all necessary libraries
echo "Copying libraries..."
# Copy platform-specific native libraries
find "$KEMULATOR_DIR" -name "*.dylib" -o -name "*.jnilib" | xargs -I {} cp {} "$INPUT_DIR/" 2>/dev/null || true

# Copy platform-specific JAR libraries
cp "$KEMULATOR_DIR"/lwjgl*-natives-macos*.jar "$INPUT_DIR/" 2>/dev/null || true
cp "$KEMULATOR_DIR"/lwjgl*-macos*.jar "$INPUT_DIR/" 2>/dev/null || true
cp "$KEMULATOR_DIR"/swt-macosx-*.jar "$INPUT_DIR/" 2>/dev/null || true

# Copy universal libraries
cp "$KEMULATOR_DIR/sensorsimulator.jar" "$INPUT_DIR/" 2>/dev/null || true
[ -f "$KEMULATOR_DIR/builder.jar" ] && cp "$KEMULATOR_DIR/builder.jar" "$INPUT_DIR/"

# Copy resource directories
[ -d "$KEMULATOR_DIR/lang" ] && cp -r "$KEMULATOR_DIR/lang" "$INPUT_DIR/"
[ -d "$KEMULATOR_DIR/uei" ] && cp -r "$KEMULATOR_DIR/uei" "$INPUT_DIR/"

# Create launcher properties file
cat > "$WORK_DIR/launcher.properties" << 'EOF'
arguments=-s
java-options=-Djna.nosys=true
java-options=-Dfile.encoding=UTF-8
java-options=-XX:+IgnoreUnrecognizedVMOptions
java-options=-XstartOnFirstThread
java-options=-Xmx512M
java-options=-javaagent:KEmulator.jar
java-options=--add-opens java.base/java.lang=ALL-UNNAMED
java-options=--add-opens java.base/java.lang.reflect=ALL-UNNAMED
java-options=--add-opens java.base/java.lang.ref=ALL-UNNAMED
java-options=--add-opens java.base/java.io=ALL-UNNAMED
java-options=--add-opens java.base/java.util=ALL-UNNAMED
java-options=--enable-native-access=ALL-UNNAMED
EOF

# Remove old app bundle if it exists
[ -d "$APP_BUNDLE" ] && rm -rf "$APP_BUNDLE"

echo "Building application with jpackage..."

# Build the macOS .app bundle with bundled JRE
jpackage \
    --type app-image \
    --input "$INPUT_DIR" \
    --name "KEmulator" \
    --main-jar "KEmulator.jar" \
    --app-version "2.20" \
    --copyright "Copyright © 2025 nnproject. All rights reserved." \
    --description "J2ME Emulator for mobile Java applications and games" \
    --vendor "nnproject" \
    --dest "$SCRIPT_DIR" \
    --java-options "-Djna.nosys=true" \
    --java-options "-Djava.library.path=\$APPDIR" \
    --java-options "-Dfile.encoding=UTF-8" \
    --java-options "-javaagent:\$APPDIR/KEmulator.jar" \
    --java-options "-XX:+IgnoreUnrecognizedVMOptions" \
    --java-options "-XstartOnFirstThread" \
    --java-options "-Xmx512M" \
    --java-options "--add-opens" \
    --java-options "java.base/java.lang=ALL-UNNAMED" \
    --java-options "--add-opens" \
    --java-options "java.base/java.lang.reflect=ALL-UNNAMED" \
    --java-options "--add-opens" \
    --java-options "java.base/java.lang.ref=ALL-UNNAMED" \
    --java-options "--add-opens" \
    --java-options "java.base/java.io=ALL-UNNAMED" \
    --java-options "--add-opens" \
    --java-options "java.base/java.util=ALL-UNNAMED" \
    --java-options "--enable-native-access=ALL-UNNAMED" \
    --arguments "-s" \
    --verbose

# Add file associations manually to the generated Info.plist (since jpackage app-image doesn't support them)
if [ -f "$APP_BUNDLE/Contents/Info.plist" ]; then
    echo "Adding file associations to Info.plist..."
    
    # Create a temporary file with file associations
    cat > "$WORK_DIR/file-associations.xml" << 'EOF'
	<key>CFBundleDocumentTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeExtensions</key>
			<array>
				<string>jar</string>
				<string>jad</string>
			</array>
			<key>CFBundleTypeIconFile</key>
			<string>KEmulator.icns</string>
			<key>CFBundleTypeName</key>
			<string>Java Archive</string>
			<key>CFBundleTypeRole</key>
			<string>Viewer</string>
			<key>LSHandlerRank</key>
			<string>Alternate</string>
			<key>LSTypeIsPackage</key>
			<false/>
		</dict>
	</array>
EOF

    # Insert file associations before the closing </dict></plist>
    if command -v python3 &> /dev/null; then
        python3 << EOF
import xml.etree.ElementTree as ET

# Read the generated Info.plist
tree = ET.parse('$APP_BUNDLE/Contents/Info.plist')
root = tree.getroot()

# Find the main dict element
main_dict = root.find('dict')

# Add CFBundleDocumentTypes
doc_types_key = ET.SubElement(main_dict, 'key')
doc_types_key.text = 'CFBundleDocumentTypes'

doc_types_array = ET.SubElement(main_dict, 'array')
doc_type_dict = ET.SubElement(doc_types_array, 'dict')

# Extensions
ext_key = ET.SubElement(doc_type_dict, 'key')
ext_key.text = 'CFBundleTypeExtensions'
ext_array = ET.SubElement(doc_type_dict, 'array')
jar_ext = ET.SubElement(ext_array, 'string')
jar_ext.text = 'jar'
jad_ext = ET.SubElement(ext_array, 'string')
jad_ext.text = 'jad'

# Icon
icon_key = ET.SubElement(doc_type_dict, 'key')
icon_key.text = 'CFBundleTypeIconFile'
icon_value = ET.SubElement(doc_type_dict, 'string')
icon_value.text = 'KEmulator.icns'

# Name
name_key = ET.SubElement(doc_type_dict, 'key')
name_key.text = 'CFBundleTypeName'
name_value = ET.SubElement(doc_type_dict, 'string')
name_value.text = 'Java Archive'

# Role
role_key = ET.SubElement(doc_type_dict, 'key')
role_key.text = 'CFBundleTypeRole'
role_value = ET.SubElement(doc_type_dict, 'string')
role_value.text = 'Viewer'

# Rank
rank_key = ET.SubElement(doc_type_dict, 'key')
rank_key.text = 'LSHandlerRank'
rank_value = ET.SubElement(doc_type_dict, 'string')
rank_value.text = 'Alternate'

# Package
package_key = ET.SubElement(doc_type_dict, 'key')
package_key.text = 'LSTypeIsPackage'
package_value = ET.SubElement(doc_type_dict, 'false')

# Write back to file
tree.write('$APP_BUNDLE/Contents/Info.plist', encoding='utf-8', xml_declaration=True)
print("File associations added successfully")
EOF
    else
        echo "Warning: Python3 not available, file associations not added"
    fi
fi

# Check if the app was created successfully
if [ ! -d "$APP_BUNDLE" ]; then
    echo "Error: Failed to create KEmulator.app"
    exit 1
fi

echo ""
echo "jpackage build complete!"
echo "Created: $APP_BUNDLE"
echo ""
echo "Features:"
echo "  ✓ Self-contained with bundled JRE"
echo "  ✓ Native macOS .app bundle"
echo "  ✓ File associations for .jar and .jad files"
echo "  ✓ Drag & drop support"
echo ""
echo "Usage:"
echo "  - Double-click KEmulator.app to launch the emulator"
echo "  - Drag .jar files onto the app icon to run them in the emulator"
echo "  - Right-click .jar files and choose 'Open With > KEmulator'"
echo ""
echo "To install system-wide:"
echo "  sudo cp -R KEmulator.app /Applications/"
echo ""

# Show bundle size
if command -v du &> /dev/null; then
    BUNDLE_SIZE=$(du -sh "$APP_BUNDLE" | cut -f1)
    echo "Bundle size: $BUNDLE_SIZE"
fi