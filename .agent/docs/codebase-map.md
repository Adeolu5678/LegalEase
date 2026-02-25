# 🗺️ CODEBASE MAP

> **Purpose**: Quick navigation guide for finding relevant files.
> **Project**: LegalEase
> **Technology**: Flutter/Dart
> **Last Updated**: 2026-02-25

---

## 📁 Project Structure

```
project-root/
├── .agent/                    # 🤖 Ralph Workflow System
│   ├── workflows/             # Workflow definitions
│   │   └── ralph.md           # Main workflow file
│   ├── docs/                  # Workflow documentation
│   │   ├── codebase-map.md    # This file
│   │   ├── task-registry.md   # Task tracking
│   │   ├── context-template.md
│   │   └── handoff-template.md
│   ├── contexts/              # Task-specific context files
│   └── handoffs/              # Handoff reports
│
├── .workflow-engine/          # 🔧 Workflow engine submodule
│
├── lib/                       # 📦 Flutter Source Code
│   ├── main.dart              # App entry point
│   ├── app.dart               # Root app widget
│   ├── firebase_options.dart  # Firebase configuration
│   ├── core/                  # Core functionality
│   │   ├── constants/         # App-wide constants
│   │   ├── theme/             # Theme configuration
│   │   │   ├── app_colors.dart      # Semantic color palette
│   │   │   ├── app_text_styles.dart # Typography scale (Inter)
│   │   │   └── app_spacing.dart     # Spacing, sizing, animation constants
│   │   ├── router/            # App routing
│   │   │   └── transitions/   # Custom page transitions
│   │   │       └── fade_page_route.dart # Fade transition
│   │   ├── utils/             # Utility functions
│   │   └── platform_channels/ # Native platform channels
│   ├── features/              # Feature-based modules
│   │   ├── auth/              # Authentication feature
│   │   ├── document_scan/     # Document scanning feature
│   │   ├── tc_scanner/        # T&C auto-scanner feature
│   │   ├── writing_assistant/ # Writing assistant feature
│   │   ├── chat/              # Chat/Q&A feature
│   │   ├── persona/           # Custom persona engine
│   │   ├── subscription/      # Premium subscription monetization
│   │   ├── onboarding/        # Onboarding flow
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── onboarding_screen.dart
│   │   │       └── widgets/
│   │   │           └── onboarding_page.dart
│   │   └── settings/          # App settings and persona management
│   ├── shared/                # Shared components
│   │   ├── widgets/           # Reusable widgets
│   │   │   ├── widgets.dart                # Barrel export
│   │   │   ├── branded_loading_indicator.dart
│   │   │   ├── shimmer_loading.dart
│   │   │   ├── progress_overlay.dart
│   │   │   ├── error_state_widget.dart
│   │   │   ├── error_banner.dart
│   │   │   ├── toast_notification.dart
│   │   │   └── empty_state_widget.dart
│   │   ├── models/            # Data models
│   │   └── services/          # Shared services
│   └── l10n/                  # Localization
│
├── assets/                    # 🎨 Static Assets
│   ├── images/                # Image assets
│   ├── icons/                 # Icon assets
│   └── fonts/                 # Custom fonts
│
├── android/                   # 🤖 Android platform
├── ios/                       # 🍎 iOS platform
├── web/                       # 🌐 Web platform
├── windows/                   # 🪟 Windows platform
├── macos/                     # 🍎 macOS platform
├── test/                      # 🧪 Test files
│
├── docs/                      # 📄 Project Documentation
│   ├── 01_PRD.md              # Product Requirements Document
│   ├── 02_MDD.md              # Module/Master Design Document
│   ├── 03_SSD.md              # System Sequence Document
│   ├── 04_TECH_STACK.md       # Technology Stack Document
│   └── 05_CICD_SETUP.md       # CI/CD Setup Guide
│
├── .github/                   # 🔄 GitHub Actions CI/CD
│   └── workflows/             # Workflow definitions
│       ├── ci.yml             # PR validation (analyze, test)
│       ├── build-android.yml  # Android builds
│       ├── build-ios.yml      # iOS builds
│       ├── build-web.yml      # Web builds
│       ├── build-desktop.yml  # Windows/macOS builds
│       └── release.yml        # Release orchestration
│
├── Agent Brief.md             # 📋 Project brief
├── pubspec.yaml               # Flutter dependencies
├── analysis_options.yaml      # Dart analyzer config
├── README.md                  # Project readme
└── workflow.config.json       # Ralph workflow config
```

---

## 🏷️ Directory Purposes

| Directory | Purpose | When to Look Here |
|-----------|---------|-------------------|
| `.agent/` | Ralph Workflow System - task management, contexts, handoffs | Starting tasks, tracking progress, handoffs |
| `lib/` | Flutter source code (features, core, shared) | All app development - screens, widgets, services, models |
| `lib/features/auth/` | Authentication (email, Google, Apple, anonymous) | Implementing or modifying auth flows |
| `lib/features/document_scan/` | Document OCR and processing | Document scanning, text extraction, PDF handling |
| `lib/features/persona/` | Custom persona engine (model, repository, service, providers) | Implementing AI persona customization |
| `lib/features/subscription/` | Premium subscription with RevenueCat | Subscription management, paywall UI, purchase flow |
| `lib/features/settings/` | App settings including persona management UI | User preferences and persona configuration |
| `lib/features/onboarding/` | Onboarding flow for new users | First-time user experience and feature introduction |
| `lib/core/theme/` | Theme configuration (colors, typography, spacing) | Customizing app appearance and design system |
| `lib/shared/services/ai/` | Multi-provider AI integration layer | AI provider implementations, switching providers |
| `assets/` | Static assets (images, icons, fonts) | Adding or referencing media resources |
| `android/` | Android platform-specific code | Android native configuration, permissions |
| `ios/` | iOS platform-specific code | iOS native configuration, permissions |
| `web/` | Web platform-specific code | Web deployment configuration |
| `windows/` | Windows platform-specific code | Windows desktop configuration |
| `macos/` | macOS platform-specific code | macOS desktop configuration |
| `test/` | Test files | Unit tests, widget tests, integration tests |
| `docs/` | Project documentation - PRD, MDD, SSD, tech stack | Understanding requirements, architecture, design |
| `.github/` | GitHub Actions workflows for CI/CD | Setting up automated builds and deployments |
| `.workflow-engine/` | Workflow engine submodule | Workflow execution logic |

---

## 🔎 Quick Find Guide

| Looking For | Check These Locations |
|-------------|----------------------|
| App entry point | `lib/main.dart` |
| Root widget & routing | `lib/app.dart` |
| Feature implementation | `lib/features/<feature_name>/` |
| Authentication | `lib/features/auth/` |
| Document scanning | `lib/features/document_scan/` |
| T&C auto-scanner | `lib/features/tc_scanner/` |
| Writing assistant | `lib/features/writing_assistant/` |
| Chat/Q&A | `lib/features/chat/` |
| Onboarding | `lib/features/onboarding/` |
| Settings | `lib/features/settings/` |
| Reusable widgets | `lib/shared/widgets/` |
| Data models | `lib/shared/models/` |
| Shared services | `lib/shared/services/` |
| Theme & styling | `lib/core/theme/` |
| App constants | `lib/core/constants/` |
| Utility functions | `lib/core/utils/` |
| Platform channels | `lib/core/platform_channels/` |
| Localization | `lib/l10n/` |
| Static images | `assets/images/` |
| Icons | `assets/icons/` |
| Custom fonts | `assets/fonts/` |
| Documentation | `docs/` |
| Configuration | `pubspec.yaml`, `workflow.config.json` |
| Tasks & Planning | `.agent/docs/task-registry.md` |

---

## 📌 Key Files

| File | Purpose |
|------|---------|
| `pubspec.yaml` | Flutter dependencies and configuration |
| `lib/main.dart` | Application entry point |
| `lib/app.dart` | Root app widget with theming and routing |
| `lib/firebase_options.dart` | Firebase platform configuration |
| `lib/shared/services/ai/ai_provider.dart` | Abstract AI provider interface (Strategy pattern) |
| `lib/shared/services/ai/gemini_provider.dart` | Google Gemini AI implementation |
| `lib/shared/services/ai/openai_provider.dart` | OpenAI GPT implementation |
| `lib/shared/services/ai/anthropic_provider.dart` | Anthropic Claude implementation |
| `lib/core/theme/app_colors.dart` | Semantic color palette with light/dark support |
| `lib/core/theme/app_text_styles.dart` | Typography scale using Inter font |
| `lib/core/theme/app_spacing.dart` | Spacing, sizing, border radius, animation constants |
| `lib/core/router/transitions/fade_page_route.dart` | Custom fade page transition |
| `lib/shared/widgets/widgets.dart` | Barrel export for shared UI components |
| `lib/shared/widgets/branded_loading_indicator.dart` | LegalEase branded loading spinner |
| `lib/shared/widgets/shimmer_loading.dart` | Shimmer loading placeholder effect |
| `lib/shared/widgets/error_state_widget.dart` | Error state with retry action |
| `lib/shared/widgets/error_banner.dart` | Inline error banner notification |
| `lib/shared/widgets/toast_notification.dart` | Toast notification overlay |
| `lib/shared/widgets/empty_state_widget.dart` | Empty state with illustration |
| `lib/features/onboarding/presentation/screens/onboarding_screen.dart` | 4-page onboarding flow |
| `lib/shared/providers/ai_providers.dart` | Riverpod providers for AI service |
| `lib/shared/models/ai_config_model.dart` | AI configuration and provider types |
| `lib/shared/models/persona_model.dart` | Persona data model with tone/style/language |
| `lib/features/persona/domain/services/persona_service.dart` | Service for persona-based AI operations |
| `lib/features/persona/domain/providers/persona_providers.dart` | Riverpod providers for persona state |
| `lib/features/settings/presentation/screens/persona_settings_screen.dart` | Persona list and selection UI |
| `lib/features/settings/presentation/screens/persona_create_screen.dart` | Persona creation/edit form |
| `lib/features/document_scan/data/services/ocr_service.dart` | ML Kit OCR text extraction |
| `lib/features/document_scan/data/services/document_processor.dart` | PDF processing, document detection |
| `lib/features/auth/data/repositories/auth_repository.dart` | Auth repository interface |
| `lib/features/auth/domain/providers/auth_providers.dart` | Auth state providers |
| `lib/features/auth/presentation/screens/login_screen.dart` | Login UI |
| `Agent Brief.md` | Project requirements and feature specifications |
| `docs/01_PRD.md` | Product requirements and user stories |
| `docs/02_MDD.md` | System architecture and API design |
| `docs/03_SSD.md` | User journey sequence diagrams |
| `docs/04_TECH_STACK.md` | Technology decisions and justifications |
| `docs/05_CICD_SETUP.md` | CI/CD setup guide with secrets configuration |
| `lib/features/subscription/domain/models/subscription_models.dart` | Subscription data models (Plan, Subscription, Offering) |
| `lib/features/subscription/domain/repositories/subscription_repository.dart` | Abstract subscription repository interface |
| `lib/features/subscription/data/repositories/revenuecat_subscription_repository.dart` | RevenueCat implementation |
| `lib/features/subscription/domain/services/subscription_service.dart` | Subscription business logic service |
| `lib/features/subscription/domain/providers/subscription_providers.dart` | Riverpod providers for subscription state |
| `lib/features/subscription/presentation/screens/subscription_screen.dart` | Paywall screen for purchasing subscriptions |
| `lib/features/subscription/presentation/screens/subscription_management_screen.dart` | Screen to manage existing subscription |
| `lib/features/subscription/presentation/widgets/premium_paywall_dialog.dart` | Reusable premium feature paywall dialog |
| `workflow.config.json` | Ralph workflow configuration |
| `analysis_options.yaml` | Dart analyzer configuration |

---

## 🔗 Related Documentation

- Task Registry: `.agent/docs/task-registry.md`
- Workflow Guide: `.agent/workflows/ralph.md`
- Context Template: `.agent/docs/context-template.md`
- Handoff Template: `.agent/docs/handoff-template.md`

---

> ⚠️ **MAINTENANCE**: When adding new directories or key files, UPDATE THIS MAP.
