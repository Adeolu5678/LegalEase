# iOS Custom Keyboard Extension Setup Guide

## Overview
This folder contains the iOS Custom Keyboard Extension for LegalEase. Since Apple doesn't allow global accessibility text scanning on iOS, we provide a custom keyboard extension that allows users to analyze legal text from any app.

## Xcode Setup Instructions

### Step 1: Add the Keyboard Extension Target
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select your project in the navigator (top-left)
3. Go to **File > New > Target**
4. Select **Custom Keyboard Extension** under iOS > Application Extension
5. Name it `KeyboardExtension`
6. Click **Finish**

### Step 2: Replace Generated Files
1. Delete the auto-generated `KeyboardViewController.swift` in the new target
2. Copy `KeyboardViewController.swift` and `Info.plist` from this folder to the new target

### Step 3: Configure App Groups (CRITICAL)
This enables data sharing between the main app and keyboard extension:

**For the Main App Target:**
1. Select the Runner target
2. Go to **Signing & Capabilities**
3. Click **+ Capability** > **App Groups**
4. Add: `group.com.legalease.shared`

**For the Keyboard Extension Target:**
1. Select the KeyboardExtension target
2. Go to **Signing & Capabilities**
3. Click **+ Capability** > **App Groups**
4. Add: `group.com.legalease.shared` (same identifier)

### Step 4: Verify Bundle Identifiers
- Main App: `com.legalease.app` (or your actual bundle ID)
- Keyboard Extension: `com.legalease.app.KeyboardExtension`

### Step 5: Update Info.plist
The `Info.plist` in this folder includes the required configuration:
- NSExtension configuration for keyboard service
- App Groups entitlement
- Requests open access for URL scheme support

### Step 6: Build and Run
1. Select the main app scheme and run on a device/simulator
2. Go to **Settings > General > Keyboard > Keyboards > Add New Keyboard**
3. Select **LegalEase** from the list
4. Enable **Full Access** (required for opening the main app)

## User Flow
1. User switches to LegalEase keyboard in any app
2. Keyboard displays text from the current text field
3. User taps "Analyze" or selects a quick action
4. Keyboard saves text to shared App Group
5. Keyboard opens main app via URL scheme (`legalease://analyze`)
6. Main app reads shared data and performs analysis

## URL Schemes
The keyboard uses these URL schemes to communicate with the main app:
- `legalease://analyze` - Analyze text for legal issues
- `legalease://translate` - Translate to plain English
- `legalease://summarize` - Summarize the text
- `legalease://ask` - Ask a question about the text

## Testing
1. Run the app on a device or simulator
2. Open any app with a text field (Notes, Messages, etc.)
3. Long-press the globe/emoji key and select LegalEase
4. The keyboard will show the current text context
5. Tap "Analyze for Legal Issues" to send text to the main app

## Troubleshooting
- **Keyboard not appearing**: Make sure it's added in Settings
- **"Full Access" warning**: Required for URL scheme communication
- **Data not sharing**: Verify App Groups are configured identically
- **Build errors**: Check that both targets use the same development team
