# GitHub Workflows

This directory contains GitHub Actions workflows for the Bessere Radwege app.

## Workflows

### 1. CI (ci.yml)
Continuous Integration workflow that runs on every push and pull request to main and develop branches.

**Steps:**
- Checkout code
- Setup Flutter (v3.19.0)
- Install dependencies
- Verify code formatting
- Run static analysis
- Run tests

**Triggers:**
- Push to main or develop branches
- Pull requests to main or develop branches
- Manual workflow dispatch

### 2. Debug Build (debug-build.yml)
Builds debug APK for Android.

**Steps:**
- Checkout code
- Setup Java 17 and Flutter
- Install dependencies
- Build debug APK
- Upload APK artifact (7 days retention)

**Triggers:**
- Push to main or develop branches
- Pull requests to main or develop branches
- Manual workflow dispatch

### 3. Release Build (release-build.yml)
Builds release versions for both Android and iOS.

**Android Build:**
- Builds release APK and App Bundle
- Supports signing with keystore (requires secrets)
- Uploads artifacts (30 days retention)

**iOS Build:**
- Builds iOS release (no codesign)
- Creates IPA archive
- Uploads artifact (30 days retention)

**Triggers:**
- Push tags matching 'v*' pattern
- Manual workflow dispatch

## Required Secrets

For release builds with code signing, configure these secrets in GitHub:

- `KEYSTORE_BASE64`: Base64 encoded Android keystore file
- `KEY_PROPERTIES`: Android key.properties file content with:
  - keyAlias
  - keyPassword
  - storeFile
  - storePassword

## Usage

### Manual Workflow Dispatch
All workflows can be triggered manually from the Actions tab in GitHub.

### Release Process
To create a release build:
1. Tag your commit: `git tag -a v1.0.0 -m "Release v1.0.0"`
2. Push the tag: `git push origin v1.0.0`
3. The release workflow will automatically build and upload artifacts

## Notes

- Debug builds are available for 7 days
- Release builds are available for 30 days
- iOS builds require macOS runner and are not codesigned by default
- Android release builds will use debug signing if keystore secrets are not configured
