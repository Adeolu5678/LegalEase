# LegalEase

[![Flutter](https://img.shields.io/badge/Flutter-3.10.4+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10.4+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20macOS-lightgrey)](https://flutter.dev)
[![Status](https://img.shields.io/badge/Status-v1.2.0%20Released-brightgreen)](https://github.com/your-org/legalease)

**AI-powered legal assistant for document analysis, Terms & Conditions scanning, and real-time legal writing assistance.**

LegalEase helps users understand complex legal documents, identify concerning clauses in T&C agreements, and provides intelligent writing assistance for legal content—all powered by multi-provider AI with customizable personas.

> **Project Status**: v1.2.0 Released - Production ready with new features including PDF export, legal dictionary, smart reminders, and voice input. See [CHANGELOG.md](CHANGELOG.md) for release history.

---

## Features

### 🔍 Deep-Scan Document Analysis
- Upload or scan legal documents (PDF, images)
- OCR text extraction using Google ML Kit
- AI-powered analysis highlighting risks, key terms, and summary
- Support for contracts, agreements, and legal correspondence

### 📱 On-Screen T&C Auto-Scanner
- **Android**: Accessibility Service overlay detects T&C text on-screen
- **iOS**: Custom keyboard extension and Safari extension for in-browser scanning
- Real-time analysis with risk scoring and plain-English summaries
- One-tap clause breakdowns

### ✍️ Real-Time Legal Writing Assistant
- Desktop overlay for Windows and macOS
- Context-aware suggestions for legal writing
- Tone and style customization
- Integration with popular document editors

### 🎭 Custom Persona Engine (Premium)
- Create personalized AI personas with custom:
  - Tone (formal, casual, assertive, empathetic)
  - Expertise areas (contracts, IP, employment law, etc.)
  - Language preferences
- Save and switch between personas
- Context-aware recommendations

### 💎 Premium Subscription
- RevenueCat-powered subscription management
- Monthly and annual plans
- Unlock advanced features: Custom Personas, unlimited scans, priority AI

### 🎨 Modern UI/UX
- Semantic color palette with light/dark theme support
- Inter typography scale for optimal readability
- Smooth page transitions and loading states
- 4-page onboarding flow for new users
- Shared UI components (loading, error states, toasts, empty states)

### 📄 Export Options (New in v1.2.0)
- Export analysis reports as PDF with professional formatting
- Share documents and summaries via email
- Export to counsel with attorney-ready formatting
- Include red flags, summary, and original text in exports

### 📖 Legal Dictionary (New in v1.2.0)
- Built-in legal terminology reference with 500+ terms
- Category-based organization (contracts, IP, employment, etc.)
- Quick definitions with plain-English explanations
- In-context term lookup during document analysis

### 📊 Confidence Scores (New in v1.2.0)
- AI confidence ratings for each red flag detection
- Visual confidence bars and badges
- Helps users assess reliability of analysis
- High/Medium/Low confidence level indicators

### 💡 Suggested Questions (New in v1.2.0)
- AI-generated questions about your document
- Context-aware suggestions based on document analysis
- Quick-tap to ask common questions
- Personalized based on detected document type

### 📧 Export to Counsel (New in v1.2.0)
- Email analysis directly to your attorney
- Pre-formatted summary for legal review
- Attach original document and analysis
- Customizable recipient and message

### ⏰ Smart Reminders (New in v1.2.0)
- Contract deadline tracking and alerts
- Important date notifications
- Custom reminder scheduling
- Push notification support

### 🎤 Voice Input (New in v1.2.0)
- Speech-to-text for chat messages
- Hands-free document querying
- Multi-language voice recognition
- Real-time transcription

---

## Screenshots

> **Note**: Add screenshots to `assets/images/screenshots/` and update paths below.

| Document Scan | T&C Scanner | Writing Assistant | Persona Engine |
|:-------------:|:-----------:|:-----------------:|:--------------:|
| ![Document Scan](assets/images/screenshots/document_scan.png) | ![T&C Scanner](assets/images/screenshots/tc_scanner.png) | ![Writing Assistant](assets/images/screenshots/writing_assistant.png) | ![Persona Engine](assets/images/screenshots/persona.png) |

| Export PDF | Legal Dictionary | Smart Reminders | Voice Input |
|:----------:|:----------------:|:---------------:|:-----------:|
| ![Export](assets/images/screenshots/export.png) | ![Dictionary](assets/images/screenshots/dictionary.png) | ![Reminders](assets/images/screenshots/reminders.png) | ![Voice](assets/images/screenshots/voice_input.png) |

---

## Prerequisites

### Required
- **Flutter SDK** 3.10.4 or higher
- **Dart SDK** 3.10.4 or higher
- **Firebase Project** with Auth, Firestore, and Storage enabled
- **AI API Keys** (at least one):
  - Google Gemini API key
  - OpenAI API key (optional)
  - Anthropic API key (optional)

### Platform-Specific

#### Android
- Android SDK 21+ (Android 5.0 Lollipop)
- Java 11+
- Android Studio (for emulator and build tools)

#### iOS
- Xcode 15+
- iOS 12.0+ deployment target
- CocoaPods (`sudo gem install cocoapods`)
- Apple Developer Account (for device deployment)

#### Web
- Chrome browser (recommended)
- Firebase Hosting (optional, for deployment)

#### Desktop (Windows)
- Visual Studio 2022 with C++ workload
- Windows 10+ SDK

#### Desktop (macOS)
- Xcode 15+
- macOS 10.14+ deployment target

---

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/legalease.git
cd legalease
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or use existing one
3. Enable the following services:
   - **Authentication**: Email/Password, Google, Apple, Anonymous
   - **Firestore Database**: Create database in Native mode
   - **Storage**: Create storage bucket

#### Add Android App
1. Add Android app with package name: `com.legalease.app`
2. Download `google-services.json`
3. Place in `android/app/google-services.json`

#### Add iOS App
1. Add iOS app with bundle ID: `com.legalease.app`
2. Download `GoogleService-Info.plist`
3. Place in `ios/Runner/GoogleService-Info.plist`

#### Generate Firebase Options
```bash
flutterfire configure --project=your-firebase-project-id
```

### 4. Run Code Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Run the App

```bash
# Debug mode
flutter run

# Specific platform
flutter run -d android
flutter run -d ios
flutter run -d chrome
flutter run -d windows
flutter run -d macos
```

---

## Configuration

### Environment Variables

Create a `.env` file in the project root (do not commit):

```env
# AI Provider Keys (configure at least one)
GEMINI_API_KEY=your_gemini_api_key
OPENAI_API_KEY=your_openai_api_key
ANTHROPIC_API_KEY=your_anthropic_api_key

# RevenueCat
REVENUECAT_API_KEY=your_revenuecat_api_key
REVENUECAT_ANDROID_API_KEY=your_android_key
REVENUECAT_IOS_API_KEY=your_ios_key

# Firebase (auto-generated by flutterfire configure)
# These are stored in lib/firebase_options.dart
```

### Firebase Options

The `lib/firebase_options.dart` file is auto-generated by `flutterfire configure`. It contains platform-specific Firebase configuration:

```dart
// lib/firebase_options.dart (auto-generated)
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform { ... }
}
```

### AI Provider Configuration

Configure AI providers in `lib/shared/models/ai_config_model.dart`:

```dart
enum AIProviderType {
  gemini,    // Default
  openai,    // GPT-4
  anthropic, // Claude
}
```

### Manual Setup Tutorials

For detailed step-by-step configuration guides, refer to the documentation:

| Guide | Description |
|-------|-------------|
| [docs/05_CICD_SETUP.md](docs/05_CICD_SETUP.md) | GitHub Actions CI/CD configuration with secrets |
| [.agent/handoffs/SESSION-2026-02-25-UIPOLISH.md](.agent/handoffs/SESSION-2026-02-25-UIPOLISH.md) | Complete MVP handoff with configuration status |

### Quick Configuration Checklist

- [ ] Create Firebase project (Auth, Firestore, Storage)
- [ ] Add `google-services.json` to `android/app/`
- [ ] Add `GoogleService-Info.plist` to `ios/Runner/`
- [ ] Run `flutterfire configure --project=your-project-id`
- [ ] Create `.env` file with API keys
- [ ] Configure RevenueCat products and entitlements
- [ ] Set up GitHub secrets for CI/CD (see docs/05_CICD_SETUP.md)

---

## Platform-Specific Setup

### Android

#### Permissions
The following permissions are configured in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
<uses-permission android:name="android.permission.BIND_ACCESSIBILITY_SERVICE" />
```

#### Accessibility Service
LegalEase uses an Accessibility Service for the T&C Auto-Scanner:

1. **Configuration**: `android/app/src/main/res/xml/accessibility_service_config.xml`
2. **Implementation**: `android/app/src/main/kotlin/com/legalease/accessibility/LegalEaseAccessibilityService.kt`
3. **Overlay Service**: `android/app/src/main/kotlin/com/legalease/overlay/OverlayService.kt`

#### User Enablement
Users must enable the Accessibility Service manually:
1. Settings → Accessibility → LegalEase
2. Enable the service
3. Grant "Display over other apps" permission

### iOS

#### Keyboard Extension
Located at `ios/KeyboardExtension/`:

1. **Bundle ID**: `com.legalease.app.keyboard`
2. **App Group**: `group.com.legalease.shared` for data sharing
3. **Configuration**: See `ios/KeyboardExtension/README.md`

#### Safari Extension
Located at `ios/SafariExtension/`:

1. **Manifest**: `ios/SafariExtension/manifest.json`
2. **Bundle ID**: `com.legalease.app.safariextension`

#### Capabilities
Enable in Xcode:
- App Groups (`group.com.legalease.shared`)
- Keychain Sharing

### Desktop (Windows/macOS)

#### Windows Accessibility
- Uses Windows UI Automation APIs
- Requires `uiAccess` in manifest for overlay functionality
- Build configuration in `windows/runner/Runner.rc`

#### macOS Accessibility
- Uses Apple Accessibility APIs
- Requires Accessibility permission (System Preferences → Security & Privacy → Privacy → Accessibility)
- Entitlements configured in `macos/Runner/DebugProfile.entitlements`

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Root widget, routing, theming
├── firebase_options.dart        # Firebase configuration (auto-generated)
│
├── core/                        # Core functionality
│   ├── constants/               # App-wide constants
│   ├── theme/                   # Theme configuration
│   ├── utils/                   # Utility functions
│   └── platform_channels/       # Native platform channels
│
├── features/                    # Feature-based modules
│   ├── auth/                    # Authentication
│   ├── document_scan/           # Document scanning & OCR
│   ├── tc_scanner/              # T&C auto-scanner
│   ├── writing_assistant/       # Writing assistant
│   ├── chat/                    # Chat/Q&A with voice input
│   ├── persona/                 # Custom persona engine
│   ├── subscription/            # Premium subscriptions
│   ├── settings/                # App settings
│   ├── export/                  # PDF export & share (New)
│   ├── legal_dictionary/        # Legal terminology reference (New)
│   ├── reminders/               # Contract deadline alerts (New)
│   ├── annotations/             # Document annotations (Beta)
│   ├── search/                  # Advanced document search (Beta)
│   ├── comparison/              # Document comparison (Beta)
│   ├── sharing/                 # Share analysis (Beta)
│   ├── cloud_storage/           # Cloud integration (Beta)
│   └── team/                    # Team workspaces (Beta)
│
├── shared/                      # Shared components
│   ├── widgets/                 # Reusable widgets
│   ├── models/                  # Data models
│   └── services/                # Shared services
│       └── ai/                  # Multi-provider AI integration
│
└── l10n/                        # Localization
```

Each feature follows Clean Architecture:
```
feature/
├── data/          # Data layer (repositories, services)
├── domain/        # Domain layer (models, repositories, services, providers)
└── presentation/  # Presentation layer (screens, widgets)
```

---

## Development

### Run Development Server

```bash
flutter run
```

### Run Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/
```

### Code Generation

```bash
# Generate code (freezed, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Linting

```bash
flutter analyze
```

### Build Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

---

## CI/CD

LegalEase uses GitHub Actions for continuous integration and deployment.

### Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci.yml` | Push to main, PRs | Code quality checks |
| `build-android.yml` | Push, tags, manual | Android builds |
| `build-ios.yml` | Push, tags, manual | iOS builds |
| `build-web.yml` | Push to main, manual | Web builds |
| `build-desktop.yml` | Push, tags, manual | Windows/macOS builds |
| `release.yml` | Release published | Full release orchestration |

### Required Secrets

Configure the following secrets in GitHub repository settings:

- `FIREBASE_ANDROID_CONFIG` - Base64 encoded `google-services.json`
- `FIREBASE_IOS_CONFIG` - Base64 encoded `GoogleService-Info.plist`
- `ANDROID_KEYSTORE_BASE64` - Release keystore
- `IOS_CERTIFICATE_BASE64` - Distribution certificate
- `APP_STORE_CONNECT_API_KEY` - App Store Connect API key

For complete CI/CD setup instructions, see [docs/05_CICD_SETUP.md](docs/05_CICD_SETUP.md).

---

## Contributing

We welcome contributions! Please follow these guidelines:

### Getting Started

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Run tests and linting: `flutter test && flutter analyze`
5. Commit with conventional commits: `git commit -m "feat: add amazing feature"`
6. Push to your fork: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` before committing
- Write tests for new functionality
- Update documentation as needed

### Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- `test:` - Adding/updating tests
- `chore:` - Maintenance tasks

### Pull Request Process

1. Ensure all CI checks pass
2. Request review from maintainers
3. Address review feedback
4. Squash commits before merging

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Support

- **Documentation**: [docs/](docs/)
- **Issues**: [GitHub Issues](https://github.com/your-org/legalease/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/legalease/discussions)

---

<p align="center">
  Built with ❤️ using Flutter
</p>
