# KEmulator macOS App Package

This repository contains scripts to package [KEmulator](https://github.com/shinovon/KEmulator) v2.20 into a macOS .app bundle for easy installation and use on macOS.

## What is KEmulator?

KEmulator is an emulator for J2ME (Java 2 Micro Edition) applications and games, supporting CLDC, MIDP, and various vendor-specific APIs. It allows you to run mobile Java applications and games from the early 2000s era on modern computers.

## Quick Start

### Option 1: Download Pre-built App

1. Download the latest release from the [Releases](../../releases) page
2. Extract the .zip file 
3. Move `KEmulator.app` to your Applications folder
4. Double-click to launch, or drag .jar files onto the app icon

### Option 2: Build from Source

1. Clone this repository:
   ```bash
   git clone https://github.com/rwv/KEmulator-nnmod-macos-pack.git
   cd KEmulator-nnmod-macos-pack
   ```

2. Run the packaging script:
   ```bash
   ./package.sh
   ```

3. The script will:
   - Download KEmulator v2.20 from the official repository
   - Extract it and copy necessary files to the .app bundle
   - Create a ready-to-use `KEmulator.app`

## Installation

### System-wide Installation
```bash
sudo cp -R KEmulator.app /Applications/
```

### User Installation
```bash
cp -R KEmulator.app ~/Applications/
```

## Usage

### Launch KEmulator
- **GUI**: Double-click `KEmulator.app` in Finder
- **Command line**: `open KEmulator.app`

### Run J2ME Applications
- **Drag & Drop**: Drag .jar or .jad files onto the KEmulator.app icon
- **Right-click**: Right-click .jar files → "Open With" → "KEmulator"
- **Command line**: `open KEmulator.app --args /path/to/game.jar`

### File Associations
The app bundle is configured to handle:
- `.jar` files (Java Archive)
- `.jad` files (Java Application Descriptor)

## Requirements

- **macOS**: 10.9 or later
- **Java**: Java 8 (recommended) or Java 11+
  - The app will automatically detect Java installations using `/usr/libexec/java_home`
  - Install Java from [Adoptium](https://adoptium.net/) if needed

## Features

- **Native macOS Integration**: Proper .app bundle with file associations
- **Automatic Java Detection**: Finds the best Java version automatically
- **Error Handling**: User-friendly error dialogs using AppleScript
- **Drag & Drop Support**: Launch games by dropping files on the app icon
- **Universal Binary Support**: Works on both Intel and Apple Silicon Macs

## Troubleshooting

### "KEmulator.jar not found" Error
This means the .app bundle wasn't packaged correctly. Run `./package.sh` again.

### Java Not Found
Install Java 8 or 11+ from [Adoptium](https://adoptium.net/). The app will automatically detect it.

### Game Won't Load
- Ensure the .jar file is a valid J2ME application
- Some games may require specific device profiles or settings within KEmulator

## Project Structure

```
KEmulator.app/
├── Contents/
│   ├── Info.plist              # App metadata and file associations
│   ├── MacOS/
│   │   └── KEmulator           # Launch script
│   └── Resources/              # KEmulator files
│       ├── KEmulator.jar       # Main emulator
│       ├── *.dylib            # macOS native libraries
│       ├── lang/              # Language files
│       └── uei/               # J2ME API implementations
```

## Credits

- **KEmulator**: Developed by [shinovon](https://github.com/shinovon) and the nnproject team
- **Original Repository**: https://github.com/shinovon/KEmulator
- **macOS Packaging**: This repository provides the macOS .app bundle packaging

## License

This packaging script is provided as-is. KEmulator itself is subject to its own license terms - please refer to the [original repository](https://github.com/shinovon/KEmulator) for details.