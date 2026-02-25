# CI/CD Setup Guide

## Overview

LegalEase uses GitHub Actions for continuous integration and deployment across all supported platforms:
- **Android** - APK and App Bundle with Google Play deployment
- **iOS** - IPA with TestFlight/App Store deployment
- **Web** - GitHub Pages and Firebase Hosting
- **Windows** - Native Windows application
- **macOS** - Native macOS application

## Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci.yml` | Push to main, PRs | Code quality checks |
| `build-android.yml` | Push, tags, manual | Android builds |
| `build-ios.yml` | Push, tags, manual | iOS builds |
| `build-web.yml` | Push to main, manual | Web builds |
| `build-desktop.yml` | Push, tags, manual | Windows/macOS builds |
| `release.yml` | Release published | Full release orchestration |

## Required GitHub Secrets

### Firebase Configuration

| Secret | Description | How to Create |
|--------|-------------|---------------|
| `FIREBASE_ANDROID_CONFIG` | Base64 encoded `google-services.json` | Download from Firebase Console → Project Settings → Android app |
| `FIREBASE_IOS_CONFIG` | Base64 encoded `GoogleService-Info.plist` | Download from Firebase Console → Project Settings → iOS app |

**Encoding**: `base64 -i google-services.json | pbcopy`

### Android Signing

| Secret | Description |
|--------|-------------|
| `ANDROID_KEYSTORE_BASE64` | Base64 encoded keystore file |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | Key alias name |
| `ANDROID_KEY_PASSWORD` | Key password |

**Create keystore**: `keytool -genkey -v -keystore legalease-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias legalease`

### Google Play

| Secret | Description |
|--------|-------------|
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Service account JSON with Play Console access |

**Setup**: Google Play Console → Setup → API access → Create service account

### iOS/macOS Signing

| Secret | Description |
|--------|-------------|
| `IOS_CERTIFICATE_BASE64` | Base64 encoded .p12 distribution certificate |
| `IOS_CERTIFICATE_PASSWORD` | Certificate password |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64 encoded provisioning profile |

**Export certificate**: In Keychain Access, export the certificate as .p12

### App Store Connect

| Secret | Description |
|--------|-------------|
| `APP_STORE_CONNECT_API_KEY` | Base64 encoded API key (.p8 file) |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID from App Store Connect |
| `APP_STORE_CONNECT_KEY_ID` | Key ID from App Store Connect |

**Setup**: App Store Connect → Users and Access → Keys

### Firebase Hosting (Optional)

| Secret | Description |
|--------|-------------|
| `FIREBASE_TOKEN` | Firebase CLI token |
| `FIREBASE_SERVICE_ACCOUNT` | Service account JSON for Firebase |
| `FIREBASE_PROJECT_ID` | Firebase project ID |

**Get token**: `firebase login:ci`

### Notifications (Optional)

| Secret | Description |
|--------|-------------|
| `SLACK_WEBHOOK_URL` | Slack incoming webhook URL |

## Adding Secrets to GitHub

1. Go to repository Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Enter the secret name and value
4. Click "Add secret"

## Runner Requirements

| Platform | Runner | Notes |
|----------|--------|-------|
| CI/Android/Web | `ubuntu-latest` | Linux-based builds |
| iOS/macOS | `macos-latest` | Requires macOS for Xcode |
| Windows | `windows-latest` | Native Windows builds |

## Manual Workflow Dispatch

All build workflows can be triggered manually:

1. Go to Actions tab in GitHub
2. Select the workflow
3. Click "Run workflow"
4. Select branch and click "Run workflow"

## Release Process

1. **Prepare Release**
   - Update version in `pubspec.yaml`
   - Update CHANGELOG.md
   - Ensure all tests pass

2. **Create GitHub Release**
   - Go to Releases → Draft a new release
   - Create a new tag (e.g., v1.0.0)
   - Fill in release notes
   - Click "Publish release"

3. **Automated Release**
   - The `release.yml` workflow triggers automatically
   - All platforms are built in parallel
   - Artifacts are attached to the release
   - Stores deployment happens (if configured)

## Troubleshooting

### Build Fails: Firebase config not found
- Ensure `FIREBASE_ANDROID_CONFIG` and `FIREBASE_IOS_CONFIG` secrets are set
- Verify base64 encoding is correct

### iOS Build Fails: Code signing error
- Check that certificates and provisioning profiles are valid
- Ensure bundle ID matches the provisioning profile
- Verify App Store Connect API key has correct permissions

### Android Build Fails: Keystore error
- Verify keystore base64 encoding
- Check that key alias exists in keystore
- Ensure passwords are correct

### Web Deployment Fails
- Verify Firebase token is valid: `firebase login:ci`
- Check Firebase project ID is correct

## Workflow Files Reference

- `.github/workflows/ci.yml` - Continuous integration
- `.github/workflows/build-android.yml` - Android builds
- `.github/workflows/build-ios.yml` - iOS builds
- `.github/workflows/build-web.yml` - Web builds
- `.github/workflows/build-desktop.yml` - Desktop builds
- `.github/workflows/release.yml` - Release orchestration
