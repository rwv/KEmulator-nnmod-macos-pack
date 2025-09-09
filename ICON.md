# Adding a Custom Icon to KEmulator.app

To add a custom icon to the KEmulator.app bundle, follow these steps:

## Option 1: Using an existing .icns file

1. Obtain or create a KEmulator.icns file (macOS icon format)
2. Copy it to the app bundle:
   ```bash
   cp KEmulator.icns KEmulator.app/Contents/Resources/
   ```
3. The Info.plist is already configured to use this icon file

## Option 2: Converting from PNG/other formats

1. Create or obtain a high-resolution icon (preferably 1024x1024 PNG)
2. Use macOS's built-in iconutil to convert:
   ```bash
   # Create an iconset directory
   mkdir KEmulator.iconset
   
   # Copy your source image (1024x1024) to the iconset
   cp icon-1024.png KEmulator.iconset/icon_512x512@2x.png
   
   # Generate other required sizes (you can use sips to resize)
   sips -z 16 16     KEmulator.iconset/icon_512x512@2x.png --out KEmulator.iconset/icon_16x16.png
   sips -z 32 32     KEmulator.iconset/icon_512x512@2x.png --out KEmulator.iconset/icon_16x16@2x.png
   sips -z 32 32     KEmulator.iconset/icon_512x512@2x.png --out KEmulator.iconset/icon_32x32.png
   sips -z 64 64     KEmulator.iconset/icon_512x512@2x.png --out KEmulator.iconset/icon_32x32@2x.png
   sips -z 128 128   KEmulator.iconset/icon_512x512@2x.png --out KEmulator.iconset/icon_128x128.png
   sips -z 256 256   KEmulator.iconset/icon_512x512@2x.png --out KEmulator.iconset/icon_128x128@2x.png
   sips -z 256 256   KEmulator.iconset/icon_512x512@2x.png --out KEmulator.iconset/icon_256x256.png
   sips -z 512 512   KEmulator.iconset/icon_512x512@2x.png --out KEmulator.iconset/icon_256x256@2x.png
   sips -z 512 512   KEmulator.iconset/icon_512x512@2x.png --out KEmulator.iconset/icon_512x512.png
   
   # Convert to .icns
   iconutil -c icns KEmulator.iconset
   
   # Copy to app bundle
   cp KEmulator.icns KEmulator.app/Contents/Resources/
   ```

## Option 3: Extracting from original KEmulator

If you want to use the original KEmulator icon:

1. Look for icon resources in the original KEmulator.jar
2. Extract any icon files from the JAR:
   ```bash
   unzip -l KEmulator.app/Contents/Resources/KEmulator.jar | grep -i icon
   ```
3. Convert the extracted image to .icns format using the method above

## Icon Requirements

- The icon file should be named `KEmulator.icns`
- Place it in `KEmulator.app/Contents/Resources/`
- The Info.plist already references this filename
- Recommended sizes: 16x16, 32x32, 128x128, 256x256, 512x512 (and @2x variants)

## Testing

After adding the icon:
1. Run `./verify.sh` to ensure the bundle is still valid
2. In Finder, the KEmulator.app should display your custom icon
3. The icon will also appear in the Dock when the app is running