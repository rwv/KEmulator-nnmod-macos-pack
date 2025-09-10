# KEmulator-nnmod-macos-pack

This repository contains a GitHub Actions workflow that automatically downloads KEmulator v2.20 and packages it as a standalone macOS app using jpackage.

## What it does

1. Downloads KEmulator v2.20 release from https://github.com/shinovon/KEmulator/releases/download/v2.20/kemnnx64.v2.20.zip
2. Extracts the Java application and its dependencies
3. Uses jpackage to create a native macOS app bundle (.app)
4. Uploads the resulting app as a GitHub Actions artifact

## How to use

The workflow runs automatically on:
- Push to main branch
- Pull requests to main branch
- Manual trigger via workflow_dispatch

To manually trigger the workflow:
1. Go to the Actions tab in this repository
2. Select "Build KEmulator macOS App" workflow
3. Click "Run workflow"

## Download the macOS app

After the workflow completes successfully:
1. Go to the Actions tab
2. Click on the latest successful workflow run
3. Download the "KEmulator-macOS-App-v2.20" artifact
4. Extract the .tar.gz file to get the KEmulator.app bundle
5. Double-click KEmulator.app to run the emulator

## About KEmulator

KEmulator is a J2ME (Java ME) emulator that allows you to run Java games and applications designed for old mobile phones on modern systems. This packaged version includes all necessary dependencies and native libraries for macOS.

Original KEmulator project: https://github.com/shinovon/KEmulator