# Windows Startup Script Reference

The problem statement mentioned using `KEmulator.bat` as a reference for the Windows startup script. Here's the original Windows batch file from KEmulator v2.20:

## KEmulator.bat (Windows)
```batch
@rem KEmulator nnx64 starter, only for JRE 8!

@echo off
set dir=%~dp0
set f=%1
if defined f (
start javaw -Djava.library.path=%dir% -Xmx512M -jar "%dir%KEmulator.jar" -jar "%1"
) else (
start javaw -Djava.library.path=%dir% -Xmx512M -jar "%dir%KEmulator.jar"
)
```

## macOS Equivalent

The macOS .app bundle launcher script (Contents/MacOS/KEmulator) implements the equivalent functionality with macOS-specific enhancements:

### Key Differences in macOS Version:

1. **Java Detection**: Uses `/usr/libexec/java_home` to find the best Java installation
2. **macOS-specific Arguments**: Adds `-XstartOnFirstThread` for Cocoa/SWT compatibility
3. **Error Handling**: Shows AppleScript dialogs for user-friendly error messages
4. **File Path Handling**: Properly handles file paths passed via Finder drag & drop
5. **Bundle-aware Paths**: Dynamically determines resource paths within the .app bundle
6. **Java Version Support**: Handles both Java 8 and newer Java versions with appropriate arguments

### Functional Equivalence:

- ✅ Launches KEmulator without arguments (empty emulator)
- ✅ Launches KEmulator with a JAR file as argument
- ✅ Sets proper Java library path for native libraries
- ✅ Sets memory limit (-Xmx512M)
- ✅ Uses proper javaagent configuration

### macOS-specific Enhancements:

- 🍎 Native macOS .app bundle integration
- 🍎 Drag & drop support in Finder
- 🍎 File associations for .jar and .jad files
- 🍎 Automatic Java version detection and configuration
- 🍎 User-friendly error dialogs
- 🍎 Support for IDE integration features

## Usage Comparison

### Windows:
```cmd
KEmulator.bat                    # Launch empty emulator
KEmulator.bat game.jar          # Launch with JAR file
```

### macOS:
```bash
open KEmulator.app                           # Launch empty emulator
open KEmulator.app --args /path/to/game.jar  # Launch with JAR file
```

Or simply:
- Double-click KEmulator.app in Finder
- Drag game.jar onto KEmulator.app icon
- Right-click game.jar → "Open With" → "KEmulator"