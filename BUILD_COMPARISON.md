# Building KEmulator for macOS: Manual vs jpackage

This document explains the two different approaches available for building KEmulator.app bundles.

## Quick Comparison

| Approach | Bundle Size | Java Required | Best For |
|----------|-------------|---------------|----------|
| **jpackage** | ~200-300MB | No (bundled) | Distribution, end users |
| **Manual** | ~16MB | Yes (system) | Development, power users |

## jpackage Build (Recommended for Distribution)

**Command:** `./package-jpackage.sh`

### Advantages
- ✅ **Self-contained**: No Java installation required on user's machine
- ✅ **Professional**: Uses Oracle's official packaging tool
- ✅ **Compatibility**: Works regardless of user's Java setup
- ✅ **Future-proof**: Modern packaging approach
- ✅ **Automation**: Works with CI/CD (GitHub Actions)

### Disadvantages
- ❌ **Size**: Much larger download (~200-300MB vs 16MB)
- ❌ **Build time**: Slower to build due to JRE bundling
- ❌ **Java 14+ required**: For building (not running)

### Use Cases
- Distributing to end users
- App Store submissions
- Corporate deployments
- Users without Java knowledge

## Manual Build (Legacy)

**Command:** `./package.sh`

### Advantages
- ✅ **Small size**: Only ~16MB download
- ✅ **Fast build**: Quick packaging process
- ✅ **Flexible**: Uses any compatible Java version
- ✅ **Traditional**: Classic Unix-style approach

### Disadvantages
- ❌ **Java dependency**: User must install Java 8 or 11+
- ❌ **Setup complexity**: Users need to configure Java
- ❌ **Compatibility issues**: May break with Java updates
- ❌ **Support burden**: More troubleshooting needed

### Use Cases
- Development and testing
- Power users with Java knowledge
- Environments with strict size constraints
- Quick prototyping

## Which Should You Use?

### For Distribution
Use **jpackage** (`./package-jpackage.sh`) when:
- Distributing to general users
- Publishing releases
- Want professional app experience
- Size isn't a major concern

### For Development
Use **manual** (`./package.sh`) when:
- Testing during development
- Size is critical
- Users are Java-savvy
- Quick iterations needed

## Migration Notes

Both approaches create functionally identical apps:
- Same file associations (.jar, .jad)
- Same drag & drop functionality  
- Same KEmulator features and compatibility
- Same macOS integration

The only differences are:
- Bundle size and structure
- Java runtime dependencies
- Build requirements