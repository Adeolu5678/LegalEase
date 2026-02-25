# LegalEase Architecture Documentation

**Document Version:** 1.2  
**Last Updated:** February 25, 2026  
**Status:** Production Release  

---

## Table of Contents

1. [High-Level System Overview](#1-high-level-system-overview)
2. [Flutter App Architecture](#2-flutter-app-architecture)
3. [Feature Module Structure](#3-feature-module-structure)
4. [AI Integration Architecture](#4-ai-integration-architecture)
5. [State Management](#5-state-management)
6. [Platform Channels Architecture](#6-platform-channels-architecture)
7. [Native Platform Implementations](#7-native-platform-implementations)
8. [Data Flow Diagrams](#8-data-flow-diagrams)
9. [Security Considerations](#9-security-considerations)
10. [Performance Considerations](#10-performance-considerations)

---

## 1. High-Level System Overview

### 1.1 System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              LEGALEASE SYSTEM                                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                        FLUTTER APPLICATION LAYER                         │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐  │    │
│  │  │   Features   │  │    Shared    │  │     Core     │  │    L10n     │  │    │
│  │  │  (Modules)   │  │  (Services)  │  │   (Config)   │  │ (i18n)      │  │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └─────────────┘  │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                      │                                           │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                       PLATFORM CHANNELS LAYER                            │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐ │    │
│  │  │   Android   │  │     iOS     │  │   Windows   │  │     macOS       │ │    │
│  │  │ Accessibility│  │  Keyboard   │  │  UI Auto.   │  │   AXUIElement   │ │    │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                      │                                           │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                        EXTERNAL SERVICES LAYER                           │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐ │    │
│  │  │   Firebase  │  │  AI APIs    │  │  RevenueCat │  │   ML Kit OCR    │ │    │
│  │  │  (Auth/Fire)│  │ Gemini/OpenAI│  │ (Subscript.)│  │  (Text Extract) │ │    │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| UI Framework | Flutter 3.x | Cross-platform UI |
| State Management | Riverpod 2.x | Reactive state management |
| Routing | GoRouter | Declarative routing |
| Backend | Firebase | Authentication, Firestore |
| AI Providers | Gemini, OpenAI, Anthropic | Multi-provider AI strategy |
| Subscriptions | RevenueCat | In-app purchases |
| OCR | Google ML Kit | Document text extraction |
| Native Android | Kotlin | AccessibilityService, Overlay |
| Native iOS | Swift | Keyboard Extension |
| Native Windows | C++ | UI Automation |
| Native macOS | Swift | Accessibility API |

### 1.3 Key Architectural Decisions

1. **Multi-Provider AI Strategy**: Runtime-switchable AI providers for flexibility and resilience
2. **Feature-Based Clean Architecture**: Self-contained feature modules with clear boundaries
3. **Platform-Abstraction Layer**: Unified API hiding platform-specific implementations
4. **Riverpod State Management**: Compile-time safety with dependency injection

---

## 2. Flutter App Architecture

### 2.1 Directory Structure

```
lib/
├── main.dart                    # App entry point with Firebase initialization
├── app.dart                     # Root widget with GoRouter configuration
├── firebase_options.dart        # Firebase configuration
│
├── core/                        # Core infrastructure
│   ├── constants/
│   │   └── app_constants.dart   # Application-wide constants
│   ├── theme/
│   │   └── app_theme.dart       # Material 3 theme configuration
│   ├── router/
│   │   └── app_router.dart      # GoRouter route definitions
│   ├── platform_channels/
│   │   ├── accessibility_channel.dart      # Unified accessibility API
│   │   ├── ios_keyboard_channel.dart       # iOS keyboard extension
│   │   ├── windows_accessibility_channel.dart  # Windows UI Automation
│   │   ├── macos_accessibility_channel.dart    # macOS accessibility
│   │   └── desktop_overlay_channel.dart    # Desktop overlay management
│   └── deep_link_handler.dart   # Deep link processing
│
├── features/                    # Feature modules (Clean Architecture)
│   ├── auth/                    # Authentication feature
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       ├── auth_repository.dart
│   │   │       └── firebase_auth_repository.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   └── providers/
│   │   │       └── auth_providers.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   └── signup_screen.dart
│   │       └── widgets/
│   │           └── auth_form.dart
│   │
│   ├── document_scan/            # Document scanning & analysis
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── ocr_result_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── document_repository.dart
│   │   │   └── services/
│   │   │       ├── document_processor.dart
│   │   │       └── ocr_service.dart
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   └── analysis_result.dart
│   │   │   └── providers/
│   │   │       └── document_scan_providers.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── home_screen.dart
│   │       │   ├── document_upload_screen.dart
│   │       │   ├── analysis_processing_screen.dart
│   │       │   └── analysis_result_screen.dart
│   │       └── widgets/
│   │           ├── red_flag_card.dart
│   │           ├── document_text_viewer.dart
│   │           └── analysis_progress_indicator.dart
│   │
│   ├── tc_scanner/               # Terms & Conditions auto-scan
│   │   ├── data/
│   │   │   └── services/
│   │   │       └── tc_detector_service.dart
│   │   └── domain/
│   │       └── providers/
│   │           └── tc_scanner_providers.dart
│   │
│   ├── writing_assistant/        # AI writing assistance
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   └── writing_suggestion.dart
│   │   │   ├── providers/
│   │   │   │   └── writing_assistant_providers.dart
│   │   │   └── services/
│   │   │       └── writing_assistant_service.dart
│   │   └── presentation/
│   │       └── screens/
│   │           └── writing_assistant_overlay_screen.dart
│   │
│   ├── chat/                     # Document Q&A chat
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   └── chat_message.dart
│   │   │   └── providers/
│   │   │       └── chat_providers.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── chat_screen.dart
│   │       └── widgets/
│   │           ├── message_bubble.dart
│   │           ├── chat_input.dart
│   │           ├── typing_indicator.dart
│   │           └── suggested_questions.dart
│   │
│   ├── persona/                  # AI persona management
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       ├── persona_repository.dart
│   │   │       └── firebase_persona_repository.dart
│   │   └── domain/
│   │       ├── providers/
│   │       │   └── persona_providers.dart
│   │       └── services/
│   │           └── persona_service.dart
│   │
│   ├── subscription/             # Premium subscriptions
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       ├── subscription_repository.dart
│   │   │       └── revenuecat_subscription_repository.dart
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   └── subscription_models.dart
│   │   │   ├── repositories/
│   │   │   │   └── subscription_repository.dart
│   │   │   ├── services/
│   │   │   │   └── subscription_service.dart
│   │   │   └── providers/
│   │   │       └── subscription_providers.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── subscription_screen.dart
│   │       │   └── subscription_management_screen.dart
│   │       └── widgets/
│   │           └── premium_paywall_dialog.dart
│   │
│   └── settings/                 # App settings & persona config
│       ├── domain/
│       │   └── providers/
│       │       └── settings_providers.dart
│       └── presentation/
│           ├── screens/
│           │   ├── persona_settings_screen.dart
│           │   └── persona_create_screen.dart
│           └── widgets/
│               ├── persona_card.dart
│               └── persona_form.dart
│
│   ├── export/                    # PDF export & share (v1.2.0)
│   │   ├── domain/
│   │   │   ├── services/
│   │   │   │   └── export_service.dart
│   │   │   └── providers/
│   │   │       └── export_providers.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── export_to_counsel_screen.dart
│   │       └── widgets/
│   │           └── export_button.dart
│   │
│   ├── legal_dictionary/          # Legal terminology reference (v1.2.0)
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── legal_term.dart
│   │   ├── domain/
│   │   │   ├── services/
│   │   │   │   └── dictionary_service.dart
│   │   │   └── providers/
│   │   │       └── dictionary_providers.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── dictionary_screen.dart
│   │       └── widgets/
│   │           └── term_definition_card.dart
│   │
│   ├── reminders/                 # Contract deadline alerts (v1.2.0)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── reminder.dart
│   │   │   └── services/
│   │   │       └── reminder_service.dart
│   │   └── domain/
│   │       └── providers/
│   │           └── reminder_providers.dart
│   │
│   ├── annotations/               # Document annotations (Beta)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── annotation.dart
│   │   │   └── services/
│   │   │       └── annotation_service.dart
│   │   ├── domain/
│   │   │   └── providers/
│   │   │       └── annotation_providers.dart
│   │   └── presentation/
│   │       └── widgets/
│   │           ├── annotation_marker.dart
│   │           ├── annotation_dialog.dart
│   │           └── annotation_sidebar.dart
│   │
│   ├── search/                    # Advanced document search (Beta)
│   │   ├── data/
│   │   │   └── services/
│   │   │       └── search_service.dart
│   │   ├── domain/
│   │   │   └── providers/
│   │   │       └── search_providers.dart
│   │   └── presentation/
│   │       └── screens/
│   │           └── search_screen.dart
│   │
│   ├── comparison/                # Document comparison (Beta)
│   │   ├── data/
│   │   │   └── services/
│   │   │       └── comparison_service.dart
│   │   ├── domain/
│   │   │   └── providers/
│   │   │       └── comparison_providers.dart
│   │   └── presentation/
│   │       └── screens/
│   │           └── comparison_screen.dart
│   │
│   ├── sharing/                   # Share analysis (Beta)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── shared_analysis.dart
│   │   │   └── services/
│   │   │       └── sharing_service.dart
│   │   ├── domain/
│   │   │   └── providers/
│   │   │       └── sharing_providers.dart
│   │   └── presentation/
│   │       └── screens/
│   │           └── share_analysis_screen.dart
│   │
│   ├── cloud_storage/             # Cloud integration (Beta)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── cloud_provider.dart
│   │   │   └── services/
│   │   │       └── google_drive_service.dart
│   │   ├── domain/
│   │   │   └── providers/
│   │   │       └── cloud_providers.dart
│   │   └── presentation/
│   │       └── screens/
│   │           └── cloud_accounts_screen.dart
│   │
│   └── team/                      # Team workspaces (Beta)
│       ├── data/
│       │   └── services/
│       │       └── team_service.dart
│       └── domain/
│           └── providers/
│               └── team_providers.dart
│
├── shared/                       # Shared utilities & services
│   ├── models/
│   │   ├── document_model.dart   # Document & RedFlag models
│   │   ├── persona_model.dart    # Persona configuration
│   │   └── ai_config_model.dart  # AI provider configuration
│   ├── services/
│   │   ├── ai/
│   │   │   ├── ai_provider.dart       # Abstract interface
│   │   │   ├── ai_service.dart        # Provider orchestration
│   │   │   ├── ai_providers.dart      # Riverpod providers
│   │   │   ├── gemini_provider.dart   # Google Gemini
│   │   │   ├── openai_provider.dart   # OpenAI GPT
│   │   │   └── anthropic_provider.dart # Anthropic Claude
│   │   └── ios_keyboard_service.dart
│   └── providers/
│       ├── ai_providers.dart     # AI service Riverpod providers
│       └── ocr_provider.dart     # OCR service providers
│
└── l10n/
    └── app_localizations.dart    # Internationalization
```

### 2.2 Application Bootstrap Sequence

```
main.dart                         app.dart
    │                                 │
    ▼                                 ▼
┌─────────────────┐           ┌──────────────────┐
│ WidgetsFlutter  │           │ ProviderScope    │
│ Binding.ensure  │           │ (Riverpod)       │
│ Initialized()   │           └────────┬─────────┘
└────────┬────────┘                    │
         │                             ▼
         ▼                    ┌──────────────────┐
┌─────────────────┐           │ MaterialApp.     │
│ Firebase.       │           │ router()         │
│ initializeApp() │           └────────┬─────────┘
└────────┬────────┘                    │
         │                             ▼
         ▼                    ┌──────────────────┐
┌─────────────────┐           │ GoRouter         │
│ ProviderScope   │           │ (appRouterProvider)
│ (Riverpod)      │           └────────┬─────────┘
└────────┬────────┘                    │
         │                             ▼
         ▼                    ┌──────────────────┐
┌─────────────────┐           │ Feature Screens  │
│ LegalEaseApp()  │──────────▶│ (Feature Modules)│
└─────────────────┘           └──────────────────┘
```

---

## 3. Feature Module Structure

### 3.1 Clean Architecture Layers

Each feature follows a three-layer architecture:

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                           │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │    Screens      │  │    Widgets      │  │   Providers     │ │
│  │  (UI Screens)   │  │ (UI Components) │  │ (UI State)      │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                               │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │    Entities     │  │     Models      │  │   Providers     │ │
│  │ (Business objs) │  │ (Data structs)  │  │ (Business logic)│ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                       DATA LAYER                                │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Repositories   │  │    Services     │  │     Models      │ │
│  │ (Data access)   │  │ (External APIs) │  │ (Data transfer) │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Document Scan Feature Example

```
features/document_scan/
│
├── data/                                    # Data Layer
│   ├── models/
│   │   └── ocr_result_model.dart            # OCR result DTO
│   ├── repositories/
│   │   └── document_repository.dart         # Document persistence
│   └── services/
│       ├── ocr_service.dart                 # ML Kit OCR integration
│       └── document_processor.dart          # Document processing
│
├── domain/                                  # Domain Layer
│   ├── models/
│   │   └── analysis_result.dart             # Analysis result model
│   └── providers/
│       └── document_scan_providers.dart     # Business logic providers
│
└── presentation/                            # Presentation Layer
    ├── screens/
    │   ├── home_screen.dart                 # Main entry screen
    │   ├── document_upload_screen.dart      # Document selection
    │   ├── analysis_processing_screen.dart  # Processing UI
    │   └── analysis_result_screen.dart      # Results display
    └── widgets/
        ├── red_flag_card.dart               # Red flag display card
        ├── document_text_viewer.dart        # Document text viewer
        ├── document_source_selector.dart    # Upload source selection
        └── analysis_progress_indicator.dart # Progress UI
```

### 3.3 State Flow in Document Scan

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                         DOCUMENT ANALYSIS FLOW                                │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  User Action          StateNotifier           Services          AI Provider  │
│       │                     │                     │                   │       │
│       ▼                     ▼                     ▼                   ▼       │
│  ┌─────────┐         ┌─────────────┐       ┌───────────┐       ┌─────────┐   │
│  │ Select  │────────▶│ Analysis    │──────▶│ OcrService│       │         │   │
│  │ Document│         │ StateNotifier│       │ (ML Kit)  │       │         │   │
│  └─────────┘         └──────┬──────┘       └─────┬─────┘       │         │   │
│                             │                    │             │         │   │
│                             │  ┌─────────────────┘             │         │   │
│                             │  │                               │         │   │
│                             ▼  ▼                               ▼         │   │
│                      ┌─────────────┐                      ┌─────────┐   │   │
│                      │ State:      │                      │ Gemini  │   │   │
│                      │ extracting  │                      │ Provider│   │   │
│                      └──────┬──────┘                      │ or      │   │   │
│                             │                             │ OpenAI  │   │   │
│                             │                             │ or      │   │   │
│                             ▼                             │Anthropic│   │   │
│                      ┌─────────────┐                      └────┬────┘   │   │
│                      │ AiService.  │───────────────────────────┘        │   │
│                      │ summarize() │◀────────────────────────────────────┘   │
│                      └──────┬──────┘                                         │
│                             │                                                │
│                             ▼                                                │
│                      ┌─────────────┐                                         │
│                      │ State:      │                                         │
│                      │ analyzing   │                                         │
│                      └──────┬──────┘                                         │
│                             │                                                │
│                             ▼                                                │
│                      ┌─────────────┐                                         │
│                      │ AiService.  │                                         │
│                      │ detectRed   │                                         │
│                      │ Flags()     │                                         │
│                      └──────┬──────┘                                         │
│                             │                                                │
│                             ▼                                                │
│                      ┌─────────────┐                                         │
│                      │ State:      │                                         │
│                      │ completed   │                                         │
│                      │ with result │                                         │
│                      └─────────────┘                                         │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. AI Integration Architecture

### 4.1 Strategy Pattern Implementation

The AI integration uses the Strategy Pattern to enable runtime provider switching:

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        AI INTEGRATION ARCHITECTURE                            │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐     │
│  │                        AiProvider (Interface)                        │     │
│  │  ┌─────────────────────────────────────────────────────────────┐   │     │
│  │  │ + name: String                                               │   │     │
│  │  │ + modelId: String                                            │   │     │
│  │  │ + summarizeDocument(text, persona): Future<String>           │   │     │
│  │  │ + translateToPlainEnglish(text, persona): Future<String>     │   │     │
│  │  │ + detectRedFlags(text, persona): Future<List<RedFlag>>       │   │     │
│  │  │ + detectRedFlagsWithConfidence(text): Future<List<RedFlag>>  │   │     │
│  │  │ + generateSuggestedQuestions(text): Future<List<String>>     │   │     │
│  │  │ + defineLegalTerm(term, context): Future<String>             │   │     │
│  │  │ + chatWithContext(...): Future<String>                       │   │     │
│  │  │ + generateText(prompt, persona, maxTokens): Future<String>   │   │     │
│  │  │ + isAvailable(): Future<bool>                                │   │     │
│  │  │ + initialize(): Future<void>                                 │   │     │
│  │  │ + dispose(): void                                            │   │     │
│  │  └─────────────────────────────────────────────────────────────┘   │     │
│  └───────────────────────────────┬─────────────────────────────────────┘     │
│                                  │                                            │
│           ┌──────────────────────┼──────────────────────┐                    │
│           │                      │                      │                    │
│           ▼                      ▼                      ▼                    │
│  ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐            │
│  │ GeminiProvider  │   │ OpenAIProvider  │   │AnthropicProvider│            │
│  ├─────────────────┤   ├─────────────────┤   ├─────────────────┤            │
│  │ - _apiKey       │   │ - _apiKey       │   │ - _apiKey       │            │
│  │ - _modelId      │   │ - _modelId      │   │ - _modelId      │            │
│  │ - _model        │   │ - _client       │   │ - _client       │            │
│  ├─────────────────┤   ├─────────────────┤   ├─────────────────┤            │
│  │ SDK: google_    │   │ SDK: http       │   │ SDK: http       │            │
│  │ generative_ai   │   │ (REST API)      │   │ (REST API)      │            │
│  └─────────────────┘   └─────────────────┘   └─────────────────┘            │
│                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐     │
│  │                            AiService                                 │     │
│  │  ┌─────────────────────────────────────────────────────────────┐   │     │
│  │  │ - _config: AiConfig                                          │   │     │
│  │  │ - _providers: Map<AiProviderType, AiProvider>                │   │     │
│  │  │ - _currentProvider: AiProvider?                              │   │     │
│  │  ├─────────────────────────────────────────────────────────────┤   │     │
│  │  │ + provider: AiProvider (current)                             │   │     │
│  │  │ + getProvider(type): AiProvider                              │   │     │
│  │  │ + setCurrentProvider(type): void                             │   │     │
│  │  │ + availableProviders: List<AiProviderType>                   │   │     │
│  │  │ + checkProviderAvailability(): Future<Map<Type, bool>>       │   │     │
│  │  └─────────────────────────────────────────────────────────────┘   │     │
│  └─────────────────────────────────────────────────────────────────────┘     │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 AiProvider Interface

```dart
abstract class AiProvider {
  String get name;
  String get modelId;
  set modelId(String modelId);

  Future<String> summarizeDocument(String documentText, {Persona? persona});
  Future<String> translateToPlainEnglish(String legaleseText, {Persona? persona});
  Future<List<RedFlag>> detectRedFlags(String documentText, {Persona? persona});
  Future<String> chatWithContext({
    required String documentText,
    required String userQuery,
    List<Map<String, String>>? conversationHistory,
    Persona? persona,
  });
  Future<String> generateText({
    required String prompt,
    String? persona,
    int? maxTokens,
  });
  
  // New methods for v1.2.0
  Future<List<RedFlag>> detectRedFlagsWithConfidence(String documentText, {Persona? persona});
  Future<List<String>> generateSuggestedQuestions(String documentText, {Persona? persona});
  Future<String> defineLegalTerm(String term, {String? context});

  Future<bool> isAvailable();
  Future<void> initialize();
  void dispose();
}
```

### 4.3 Provider Configuration Model

```dart
enum AiProviderType {
  gemini,
  openai,
  anthropic,
}

class AiConfig {
  final AiProviderType defaultProvider;
  final Map<String, String> apiKeys;
  final Map<String, String> defaultModels;
  final Map<String, dynamic> providerSettings;

  // Available models per provider
  static const geminiModels = ['gemini-pro', 'gemini-1.5-pro', 'gemini-1.5-flash'];
  static const openaiModels = ['gpt-4', 'gpt-4-turbo', 'gpt-4o', 'gpt-3.5-turbo'];
  static const anthropicModels = ['claude-3-opus', 'claude-3-sonnet', 'claude-3-haiku'];
}
```

### 4.4 Provider Switching Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    PROVIDER SWITCHING FLOW                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  User Selection          AiService              AiProvider       │
│       │                      │                       │           │
│       ▼                      ▼                       ▼           │
│  ┌──────────┐         ┌───────────┐           ┌───────────┐     │
│  │ Settings │────────▶│ setCurrent│           │ Gemini    │     │
│  │ Screen   │         │ Provider()│──────────▶│ Provider  │     │
│  └──────────┘         └─────┬─────┘           └───────────┘     │
│                             │                                   │
│                             │  Current: gemini                  │
│                             ▼                                   │
│                      ┌───────────┐                              │
│                      │ _current  │                              │
│                      │ Provider  │                              │
│                      └─────┬─────┘                              │
│                            │                                    │
│       ┌────────────────────┼────────────────────┐               │
│       │                    │                    │               │
│       ▼                    ▼                    ▼               │
│  ┌───────────┐      ┌───────────┐      ┌───────────┐           │
│  │ Gemini    │      │ OpenAI    │      │ Anthropic │           │
│  │ Provider  │      │ Provider  │      │ Provider  │           │
│  │           │      │           │      │           │           │
│  │ ✓ Ready   │      │ ✓ Ready   │      │ ✓ Ready   │           │
│  └───────────┘      └───────────┘      └───────────┘           │
│                                                                  │
│  On Switch:                                                      │
│  1. AiService.setCurrentProvider(type)                           │
│  2. _currentProvider = _providers[type]                         │
│  3. All subsequent calls use new provider                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. State Management

### 5.1 Riverpod Provider Architecture

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        RIVERPOD PROVIDER HIERARCHY                            │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ┌───────────────────────────────────────────────────────────────────────┐   │
│  │                          PROVIDER SCOPE (Root)                         │   │
│  │                                                                        │   │
│  │  ┌─────────────────────┐  ┌─────────────────────┐                    │   │
│  │  │   Provider<T>       │  │ StateProvider<T>    │                    │   │
│  │  │   (Read-only)       │  │ (Mutable state)     │                    │   │
│  │  ├─────────────────────┤  ├─────────────────────┤                    │   │
│  │  │ aiConfigProvider    │  │ selectedProvider    │                    │   │
│  │  │ currentAiProvider   │  │ TypeProvider        │                    │   │
│  │  │ availableProviders  │  │ processingStep      │                    │   │
│  │  └─────────────────────┘  └─────────────────────┘                    │   │
│  │                                                                        │   │
│  │  ┌─────────────────────┐  ┌─────────────────────┐                    │   │
│  │  │ StateNotifierProvider│  │ FutureProvider<T>   │                    │   │
│  │  │ <Notifier, State>   │  │ (Async data)        │                    │   │
│  │  ├─────────────────────┤  ├─────────────────────┤                    │   │
│  │  │ aiServiceProvider   │  │ providerAvailability │                    │   │
│  │  │ authNotifierProvider│  │ currentSubscription  │                    │   │
│  │  │ analysisState       │  │ authStateChanges     │                    │   │
│  │  │ subscriptionScreen  │  │                      │                    │   │
│  │  └─────────────────────┘  └─────────────────────┘                    │   │
│  │                                                                        │   │
│  │  ┌─────────────────────┐                                              │   │
│  │  │ StreamProvider<T>   │                                              │   │
│  │  │ (Reactive streams)  │                                              │   │
│  │  ├─────────────────────┤                                              │   │
│  │  │ authStateChanges    │                                              │   │
│  │  └─────────────────────┘                                              │   │
│  │                                                                        │   │
│  └───────────────────────────────────────────────────────────────────────┘   │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 5.2 Key Providers

| Provider | Type | Purpose |
|----------|------|---------|
| `aiConfigProvider` | `Provider<AiConfig>` | AI configuration (read-only) |
| `aiServiceProvider` | `StateNotifierProvider` | AI service instance |
| `currentAiProviderProvider` | `Provider<AiProvider?>` | Current active AI provider |
| `selectedProviderTypeProvider` | `StateProvider` | User-selected provider type |
| `authRepositoryProvider` | `Provider<AuthRepository>` | Auth repository instance |
| `authStateChangesProvider` | `StreamProvider<User?>` | Firebase auth state |
| `authNotifierProvider` | `StateNotifierProvider` | Auth state management |
| `analysisStateProvider` | `StateNotifierProvider` | Document analysis state |
| `subscriptionScreenViewModelProvider` | `StateNotifierProvider` | Subscription UI state |

### 5.3 State Notifier Pattern

```dart
// Analysis State Example
class AnalysisState {
  final AnalysisResult? result;
  final bool isProcessing;
  final String? errorMessage;
  final ProcessingStep currentStep;
  final double progress;
}

class AnalysisStateNotifier extends StateNotifier<AnalysisState> {
  final Ref _ref;

  AnalysisStateNotifier(this._ref) : super(const AnalysisState());

  Future<void> analyzeDocument(File document) async {
    state = const AnalysisState(
      isProcessing: true, 
      currentStep: ProcessingStep.extractingText
    );
    
    // OCR extraction
    final ocrService = _ref.read(documentScanOcrServiceProvider);
    final ocrResult = await ocrService.extractTextFromImage(document);
    
    state = state.copyWith(progress: 0.3, currentStep: ProcessingStep.analyzingDocument);
    
    // AI analysis
    final aiService = _ref.read(aiServiceProvider);
    final summary = await aiService.provider.summarizeDocument(ocrResult.text);
    
    // ... continue processing
    
    state = state.copyWith(
      result: result,
      isProcessing: false,
      currentStep: ProcessingStep.completed,
      progress: 1.0,
    );
  }
}
```

### 5.4 Provider Dependencies

```
┌─────────────────────────────────────────────────────────────────┐
│                    PROVIDER DEPENDENCY GRAPH                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  aiConfigProvider ──────────────┐                               │
│         │                       │                               │
│         ▼                       ▼                               │
│  aiServiceProvider ◀───── selectedProviderTypeProvider          │
│         │                       │                               │
│         ▼                       │                               │
│  currentAiProviderProvider ◀────┘                               │
│         │                                                       │
│         │                                                       │
│         ├───────────────────────────────┐                       │
│         ▼                               ▼                       │
│  analysisStateProvider          chatProviders                   │
│         │                               │                       │
│         ▼                               ▼                       │
│  presentation layer             presentation layer              │
│                                                                  │
│  ─────────────────────────────────────────────────────────────  │
│                                                                  │
│  authRepositoryProvider                                          │
│         │                                                       │
│         ▼                                                       │
│  authStateChangesProvider (StreamProvider)                      │
│         │                                                       │
│         ▼                                                       │
│  currentUserProvider ◀──────── isPremiumUserProvider            │
│         │                       │                               │
│         ▼                       │                               │
│  authNotifierProvider ◀─────────┘                               │
│         │                                                       │
│         ▼                                                       │
│  presentation layer (screens/widgets)                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 6. Platform Channels Architecture

### 6.1 Unified Accessibility Interface

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                      PLATFORM CHANNELS ARCHITECTURE                           │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  ┌───────────────────────────────────────────────────────────────────────┐   │
│  │                 NativeAccessibilityService (Flutter)                   │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐  │   │
│  │  │ + enableAccessibilityService(): Future<bool>                    │  │   │
│  │  │ + hasAccessibilityPermission(): Future<bool>                    │  │   │
│  │  │ + extractScreenText(): Future<String?>                          │  │   │
│  │  │ + showOverlay(): Future<void>                                   │  │   │
│  │  │ + hideOverlay(): Future<void>                                   │  │   │
│  │  │ + textStream: Stream<String>                                    │  │   │
│  │  │ + eventStream: Stream<Map<String, dynamic>>                     │  │   │
│  │  │ + startMonitoring(): Future<bool>                               │  │   │
│  │  │ + stopMonitoring(): Future<void>                                │  │   │
│  │  │ + getForegroundWindowTitle(): Future<String?>                   │  │   │
│  │  └─────────────────────────────────────────────────────────────────┘  │   │
│  └───────────────────────────────────────────────────────────────────────┘   │
│                                        │                                      │
│           ┌────────────────────────────┼────────────────────────────┐        │
│           │                            │                            │        │
│           ▼                            ▼                            ▼        │
│  ┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐ │
│  │    Android      │         │      iOS        │         │    Desktop      │ │
│  │ legalease_      │         │ legalease_ios_  │         │ legalease_      │ │
│  │ android_        │         │ keyboard        │         │ windows_access  │ │
│  │ accessibility   │         │                 │         │ or              │ │
│  │                 │         │                 │         │ legalease_      │ │
│  │ MethodChannel   │         │ MethodChannel   │         │ macos_access    │ │
│  │ EventChannel    │         │                 │         │                 │ │
│  └────────┬────────┘         └────────┬────────┘         └────────┬────────┘ │
│           │                           │                           │          │
│           ▼                           ▼                           ▼          │
│  ┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐ │
│  │   Kotlin/Java   │         │     Swift       │         │   C++/Swift     │ │
│  │ Accessibility   │         │ Keyboard        │         │ UI Automation/  │ │
│  │ Service         │         │ Extension       │         │ AXUIElement     │ │
│  └─────────────────┘         └─────────────────┘         └─────────────────┘ │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 6.2 Channel Definitions

| Platform | Channel Name | Type | Purpose |
|----------|-------------|------|---------|
| Android | `legalease_android_accessibility` | MethodChannel | Accessibility service control |
| Android | `legalease_text_stream` | EventChannel | Real-time text extraction |
| Android | `legalease_event_stream` | EventChannel | System events |
| iOS | `legalease_ios_keyboard` | MethodChannel | Keyboard extension communication |
| Windows | `legalease_windows_accessibility` | MethodChannel | UI Automation control |
| Windows | `legalease_windows_accessibility_events` | EventChannel | Window change events |
| macOS | `legalease_macos_accessibility` | MethodChannel | Accessibility API |
| macOS | `legalease_macos_accessibility_events` | EventChannel | Focus change events |
| Desktop | `legalease_desktop_overlay` | MethodChannel | Overlay window control |

### 6.3 Platform-Specific Implementations

#### Android Channel
```dart
static const MethodChannel _androidChannel = 
    MethodChannel('legalease_android_accessibility');
static const EventChannel _textStreamChannel = 
    EventChannel('legalease_text_stream');

Future<bool> enableAccessibilityService() async {
  if (Platform.isAndroid) {
    return await _androidChannel.invokeMethod('enableAccessibility');
  }
  return false;
}

Stream<String> get textStream =>
    _textStreamChannel.receiveBroadcastStream().map((event) => event as String);
```

#### iOS Channel
```dart
static const MethodChannel _channel = MethodChannel('legalease_ios_keyboard');

Future<bool> isKeyboardEnabled() async {
  if (!Platform.isIOS) return false;
  return await _channel.invokeMethod('isKeyboardEnabled') ?? false;
}

Future<String?> getSharedText() async {
  if (!Platform.isIOS) return null;
  return await _channel.invokeMethod('getSharedText');
}
```

#### Windows/macOS Channel
```dart
Stream<Map<String, dynamic>> get windowChangeStream {
  if (Platform.isWindows) {
    return _windowsChannel.windowChangeStream;
  }
  if (Platform.isMacOS) {
    return _macosChannel.windowChangeStream;
  }
  return const Stream.empty();
}
```

---

## 7. Native Platform Implementations

### 7.1 Android Implementation

```
┌─────────────────────────────────────────────────────────────────┐
│                    ANDROID NATIVE LAYER                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    MainActivity.kt                         │  │
│  │  - FlutterFragment host                                   │  │
│  │  - Platform channel message handler                       │  │
│  │  - Permission request coordination                        │  │
│  └───────────────────────────────┬───────────────────────────┘  │
│                                  │                               │
│           ┌──────────────────────┴──────────────────────┐       │
│           │                                             │       │
│           ▼                                             ▼       │
│  ┌─────────────────────────┐    ┌─────────────────────────┐    │
│  │ LegalEaseAccessibility  │    │    OverlayService       │    │
│  │ Service.kt              │    │    (Kotlin)             │    │
│  ├─────────────────────────┤    ├─────────────────────────┤    │
│  │ - AccessibilityService  │    │ - Service (foreground)  │    │
│  │ - onAccessibilityEvent  │    │ - SYSTEM_ALERT_WINDOW   │    │
│  │ - getRootInActiveWindow │    │ - WindowManager         │    │
│  │ - AccessibilityNodeInfo │    │ - Floating overlay UI   │    │
│  │ - traverseAndExtract    │    │ - Drag/resize support   │    │
│  └─────────────────────────┘    └─────────────────────────┘    │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                  AndroidManifest.xml                       │  │
│  │  <service                                                  │  │
│  │    android:name=".LegalEaseAccessibilityService"          │  │
│  │    android:permission="android.permission.BIND_ACCESSIBILITY"> │
│  │    <intent-filter>                                         │  │
│  │      <action android:name="android.accessibilityservice.  │  │
│  │               AccessibilityService" />                     │  │
│  │    </intent-filter>                                        │  │
│  │  </service>                                                │  │
│  │  <service android:name=".OverlayService"                   │  │
│  │    android:foregroundServiceType="dataSync" />             │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 7.2 iOS Implementation

```
┌─────────────────────────────────────────────────────────────────┐
│                      IOS NATIVE LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              Custom Keyboard Extension                      │  │
│  │  (KeyboardViewController.swift)                            │  │
│  ├───────────────────────────────────────────────────────────┤  │
│  │ - UIInputViewController subclass                           │  │
│  │ - Text monitoring via inputProxy                           │  │
│  │ - Share extension communication                            │  │
│  │ - Full access required for network calls                   │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │               Share Extension                              │  │
│  │  (ShareViewController.swift)                               │  │
│  ├───────────────────────────────────────────────────────────┤  │
│  │ - SLComposeServiceViewController                           │  │
│  │ - User-initiated text sharing                              │  │
│  │ - App group container for data transfer                    │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │               Container App                                │  │
│  │  (AppDelegate.swift)                                       │  │
│  ├───────────────────────────────────────────────────────────┤  │
│  │ - FlutterViewController host                               │  │
│  │ - Method channel handler                                   │  │
│  │ - App group shared data access                             │  │
│  │ - Keyboard status monitoring                               │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  iOS Constraints:                                                │
│  - No global accessibility API access                           │
│  - Keyboard extension limited to text input context             │
│  - Requires explicit user action (share/keyboard selection)     │
│  - Sandbox restrictions for inter-process communication         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 7.3 Desktop Implementation (Windows/macOS)

```
┌─────────────────────────────────────────────────────────────────┐
│                    DESKTOP NATIVE LAYER                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  WINDOWS (C++)                    macOS (Swift)                  │
│  ┌─────────────────────────┐     ┌─────────────────────────┐    │
│  │ WindowsAccessibility    │     │ MacosAccessibility      │    │
│  │ Plugin.cpp              │     │ Plugin.swift            │    │
│  ├─────────────────────────┤     ├─────────────────────────┤    │
│  │ - IUIAutomation         │     │ - AXUIElement API       │    │
│  │ - IUIAutomationElement  │     │ - AXObserver            │    │
│  │ - IUIAutomationTree     │     │ - NSWorkspace           │    │
│  │   Walker                │     │   notifications         │    │
│  │ - Window event hooks    │     │ - Accessibility         │    │
│  │ - Focus tracking        │     │   permissions           │    │
│  └─────────────────────────┘     └─────────────────────────┘    │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                Desktop Overlay (Common)                     │  │
│  │  (legalease_desktop_overlay channel)                        │  │
│  ├───────────────────────────────────────────────────────────┤  │
│  │ - Borderless topmost window                                │  │
│  │ - Transparent background                                   │  │
│  │ - Draggable positioning                                    │  │
│  │ - Summary display widget                                   │  │
│  │ - Quick action buttons                                     │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Shared Features:                                                │
│  - Window focus change detection                                │
│  - Active application monitoring                                │
│  - Text extraction from focused windows                         │
│  - T&C content pattern detection                                │
│  - Overlay positioning and display                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 8. Data Flow Diagrams

### 8.1 Document Analysis Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DOCUMENT ANALYSIS DATA FLOW                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  User          UI Layer         Domain         Data          External        │
│   │              │               │              │              │             │
│   ▼              ▼               ▼              ▼              ▼             │
│  ┌───┐      ┌─────────┐     ┌─────────┐   ┌─────────┐   ┌─────────┐        │
│  │Upload│───▶│Document│────▶│Analysis │──▶│OcrService│──▶│ML Kit   │        │
│  │Image │    │Upload  │     │State    │   │         │   │OCR      │        │
│  │      │    │Screen  │     │Notifier │   │         │   │         │        │
│  └───┘      └─────────┘     └────┬────┘   └────┬────┘   └─────────┘        │
│                                  │              │                           │
│                                  │   Text       │                           │
│                                  │   extracted  │                           │
│                                  │              │                           │
│                                  ▼              │                           │
│                            ┌───────────┐        │                           │
│                            │Processing │        │                           │
│                            │Step:      │        │                           │
│                            │extracting │        │                           │
│                            └─────┬─────┘        │                           │
│                                  │              │                           │
│                                  ▼              ▼                           │
│                            ┌─────────────────────────┐                      │
│                            │      AiService          │                      │
│                            └────────────┬────────────┘                      │
│                                         │                                   │
│                    ┌────────────────────┼────────────────────┐              │
│                    │                    │                    │              │
│                    ▼                    ▼                    ▼              │
│             ┌───────────┐        ┌───────────┐        ┌───────────┐        │
│             │ summarize │        │ translate │        │ detectRed │        │
│             │ Document  │        │ ToPlain   │        │ Flags     │        │
│             └─────┬─────┘        └─────┬─────┘        └─────┬─────┘        │
│                   │                    │                    │              │
│                   └────────────────────┴────────────────────┘              │
│                                        │                                   │
│                                        ▼                                   │
│                              ┌─────────────────┐                           │
│                              │ AI Provider API │                           │
│                              │ (Gemini/OpenAI/ │                           │
│                              │  Anthropic)     │                           │
│                              └────────┬────────┘                           │
│                                       │                                    │
│                                       ▼                                    │
│                              ┌─────────────────┐                           │
│                              │ AnalysisResult  │                           │
│                              │ - summary       │                           │
│                              │ - translation   │                           │
│                              │ - redFlags[]    │                           │
│                              └────────┬────────┘                           │
│                                       │                                    │
│                                       ▼                                    │
│                              ┌─────────────────┐                           │
│                              │ Result Screen   │                           │
│                              │ (Display)       │                           │
│                              └─────────────────┘                           │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.2 Auto T&C Scan Flow (Android)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     AUTO T&C SCAN DATA FLOW (ANDROID)                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  External App     Android Native         Flutter Layer      AI Service       │
│       │                 │                     │                 │            │
│       ▼                 ▼                     ▼                 ▼            │
│  ┌──────────┐     ┌──────────────┐    ┌──────────────┐   ┌──────────┐      │
│  │Browser/  │────▶│Accessibility │───▶│EventChannel  │──▶│Text Stream│      │
│  │App with  │     │Service       │    │textStream    │   │Listener  │      │
│  │T&C page  │     │              │    │              │   │          │      │
│  └──────────┘     │ onAccessibil │    └──────┬───────┘   └────┬─────┘      │
│                   │ ityEvent()   │           │                │            │
│                   │              │           │                │            │
│                   │ traverseNode │           │                │            │
│                   │ extractText()│           │                │            │
│                   └──────────────┘           │                │            │
│                                              │                │            │
│                                              ▼                ▼            │
│                                        ┌──────────────────────────┐        │
│                                        │   TcDetectorService      │        │
│                                        │   - Pattern matching     │        │
│                                        │   - T&C detection        │        │
│                                        └────────────┬─────────────┘        │
│                                                     │                       │
│                                    ┌────────────────┴────────────────┐     │
│                                    │ T&C Content Detected?           │     │
│                                    └────────────────┬────────────────┘     │
│                                                     │ Yes                   │
│                                                     ▼                       │
│                                        ┌──────────────────────────┐        │
│                                        │   Trigger AI Analysis    │        │
│                                        │   via AiService          │        │
│                                        └────────────┬─────────────┘        │
│                                                     │                       │
│                                                     ▼                       │
│                                        ┌──────────────────────────┐        │
│                                        │   Show Floating Overlay  │        │
│                                        │   via OverlayService     │        │
│                                        │   - Summary display      │        │
│                                        │   - Red flag alerts      │        │
│                                        └──────────────────────────┘        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.3 Chat with Document Context Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CHAT WITH DOCUMENT CONTEXT FLOW                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  User          Chat Screen       Chat Providers      AI Service             │
│   │                │                   │                 │                   │
│   ▼                ▼                   ▼                 ▼                   │
│  ┌───┐        ┌──────────┐      ┌───────────┐    ┌───────────┐             │
│  │Ask│───────▶│ChatInput │─────▶│ChatState  │───▶│AiService. │             │
│  │?  │        │Widget    │      │Notifier   │    │chatWith   │             │
│  └───┘        └──────────┘      └─────┬─────┘    │Context()  │             │
│                                      │          └─────┬─────┘             │
│                                      │                │                    │
│                                      │   ┌────────────┴────────────┐       │
│                                      │   │                         │       │
│                                      │   ▼                         ▼       │
│                                      │  ┌───────────┐       ┌───────────┐ │
│                                      │  │ Document  │       │ Persona   │ │
│                                      │  │ Context   │       │ System    │ │
│                                      │  │ (from     │       │ Prompt    │ │
│                                      │  │ analysis) │       │           │ │
│                                      │  └─────┬─────┘       └─────┬─────┘ │
│                                      │        │                   │       │
│                                      │        └─────────┬─────────┘       │
│                                      │                  │                 │
│                                      │                  ▼                 │
│                                      │         ┌────────────────┐         │
│                                      │         │ AI Provider    │         │
│                                      │         │ (chat completion)        │
│                                      │         └────────┬───────┘         │
│                                      │                  │                 │
│                                      │                  ▼                 │
│                                      │         ┌────────────────┐         │
│                                      │         │ Response       │         │
│                                      │         └────────┬───────┘         │
│                                      │                  │                 │
│                                      ▼                  ▼                 │
│                               ┌──────────────────────────────┐            │
│                               │  Chat Messages List Update   │            │
│                               │  - User message              │            │
│                               │  - Assistant response        │            │
│                               └──────────────────────────────┘            │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 9. Security Considerations

### 9.1 API Key Management

```
┌─────────────────────────────────────────────────────────────────┐
│                     API KEY MANAGEMENT                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Storage Strategy:                                               │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ 1. Environment Variables (Build Time)                     │  │
│  │    - String.fromEnvironment('GEMINI_API_KEY')             │  │
│  │    - Compiled into binary at build time                   │  │
│  │                                                           │  │
│  │ 2. Secure Storage (Runtime)                               │  │
│  │    - flutter_secure_storage for user-provided keys        │  │
│  │    - Encrypted at rest using platform keychain            │  │
│  │                                                           │  │
│  │ 3. Firebase Remote Config (Recommended for Production)    │  │
│  │    - Server-side key management                           │  │
│  │    - Dynamic key rotation                                 │  │
│  │    - Per-user key quotas                                  │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Key Exposure Prevention:                                        │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ - Never log API keys                                      │  │
│  │ - Use .env files (git-ignored)                            │  │
│  │ - ProGuard/R8 obfuscation for Android                     │  │
│  │ - Code stripping for unused providers                     │  │
│  │ - Certificate pinning for API calls                       │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 9.2 Data Privacy

| Data Type | Storage | Encryption | Retention |
|-----------|---------|------------|-----------|
| User credentials | Firebase Auth | Google-managed | Session-based |
| Documents | Firebase Storage | AES-256 | User-controlled |
| Analysis results | Firestore | Google-managed | 30 days default |
| API keys | Secure Storage | Platform keychain | Persistent |
| Personas | Firestore | Google-managed | User-controlled |
| Scan history | Local + Firestore | Encrypted | 90 days |

### 9.3 Platform Security

```
Android:
├── Accessibility Service
│   ├── Explicit user permission required
│   ├── Service declaration in manifest
│   └── User can revoke anytime in settings
├── Overlay Permission
│   ├── SYSTEM_ALERT_WINDOW permission
│   └── User approval via system settings
└── Data Isolation
    ├── App sandbox
    └── Encrypted shared preferences

iOS:
├── Keyboard Extension
│   ├── Requires Full Access for network
│   ├── Explicit user enable in settings
│   └── App group container for sharing
├── Sandbox Restrictions
│   ├── No global accessibility
│   └── Limited to keyboard context
└── Data Protection
    ├── Keychain for secrets
    └── App group shared container

Desktop:
├── Accessibility Permissions
│   ├── macOS: AXPrompt for accessibility
│   └── Windows: UI Automation (no prompt)
├── Process Isolation
│   └── Platform channels for IPC
└── Local Storage
    └── Encrypted local database
```

### 9.4 Network Security

```
┌─────────────────────────────────────────────────────────────────┐
│                     NETWORK SECURITY                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  TLS Configuration:                                              │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ - TLS 1.3 required for all API calls                      │  │
│  │ - Certificate pinning for AI provider APIs                │  │
│  │ - Public key pinning backup for continuity                │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Request Security:                                               │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ - Authorization: Bearer token (Firebase Auth)              │  │
│  │ - X-API-Key header for AI providers                       │  │
│  │ - Request signing for sensitive operations                │  │
│  │ - Rate limiting on client side                            │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Content Security:                                               │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ - No PII in request logs                                  │  │
│  │ - Document text sent only to AI APIs                      │  │
│  │ - Response caching with TTL                               │  │
│  │ - Input sanitization before API calls                     │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 10. Performance Considerations

### 10.1 AI API Optimization

```
┌─────────────────────────────────────────────────────────────────┐
│                    AI API PERFORMANCE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Request Optimization:                                           │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ - Token limit enforcement (max_tokens: 2048)              │  │
│  │ - Document chunking for large texts (>10k chars)          │  │
│  │ - Streaming responses for chat (when supported)           │  │
│  │ - Request timeout: 30 seconds                             │  │
│  │ - Retry with exponential backoff (3 attempts max)         │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Caching Strategy:                                               │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ - Response cache with document hash as key                │  │
│  │ - TTL: 1 hour for summaries                               │  │
│  │ - Cache invalidation on persona change                    │  │
│  │ - Memory cache for current session                        │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Parallel Processing:                                            │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ - Summary + Translation: Sequential (depends on text)     │  │
│  │ - Red flag detection: Parallel after summary              │  │
│  │ - Multiple document pages: Parallel OCR                   │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 10.2 UI Performance

| Optimization | Implementation |
|--------------|----------------|
| Lazy loading | ListView.builder for long lists |
| Image caching | CachedNetworkImage for document previews |
| State rebuilding | Provider select for granular updates |
| Animations | Hardware-accelerated (Impeller on iOS) |
| Text rendering | Pre-formatted rich text caching |

### 10.3 Memory Management

```dart
// AI Provider Disposal
class AiService {
  void dispose() {
    for (final provider in _providers.values) {
      provider.dispose();  // Close HTTP clients, release resources
    }
    _providers.clear();
    _currentProvider = null;
  }
}

// State Notifier Disposal
class AnalysisStateNotifier extends StateNotifier<AnalysisState> {
  @override
  void dispose() {
    // Cancel any ongoing operations
    super.dispose();
  }
}

// Riverpod Auto-Dispose
final providerAvailabilityProvider = FutureProvider.autoDispose<Map<AiProviderType, bool>>((ref) async {
  // Automatically disposed when no longer watched
});
```

### 10.4 Platform Channel Performance

```
┌─────────────────────────────────────────────────────────────────┐
│              PLATFORM CHANNEL PERFORMANCE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  EventChannel Optimization:                                      │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ - Debounce text stream events (100ms)                     │  │
│  │ - Batch window change events                              │  │
│  │ - Use binary messaging for large payloads                 │  │
│  │ - Avoid UI thread blocking in native code                 │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  Native Layer Optimization:                                      │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ Android:                                                   │  │
│  │ - Use coroutines for async operations                     │  │
│  │ - Cache accessibility tree traversal                      │  │
│  │ - Throttle overlay updates                                │  │
│  │                                                           │  │
│  │ iOS:                                                       │  │
│  │ - Use Grand Central Dispatch                              │  │
│  │ - Minimize keyboard extension work                        │  │
│  │ - Background URL sessions for API calls                   │  │
│  │                                                           │  │
│  │ Desktop:                                                   │  │
│  │ - Event coalescing for rapid changes                      │  │
│  │ - Background threads for UI Automation calls              │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 10.5 Startup Performance

```
┌─────────────────────────────────────────────────────────────────┐
│                    APP STARTUP SEQUENCE                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Timeline (Target: <2s to interactive)                          │
│                                                                  │
│  ┌─────────┐                                                    │
│  │ 0-200ms │ WidgetsFlutterBinding.ensureInitialized()         │
│  └────┬────┘                                                    │
│       │                                                         │
│  ┌────▼────┐                                                    │
│  │200-800ms│ Firebase.initializeApp()                           │
│  └────┬────┘   (Parallel: Load cached config)                   │
│       │                                                         │
│  ┌────▼────┐                                                    │
│  │800-1000 │ ProviderScope initialization                       │
│  │   ms    │ - Lazy providers don't load until watched          │
│  └────┬────┘                                                    │
│       │                                                         │
│  ┌────▼────┐                                                    │
│  │1-1.5s   │ MaterialApp.router build                           │
│  │         │ - Theme loaded from memory                         │
│  │         │ - Router config parsed                             │
│  └────┬────┘                                                    │
│       │                                                         │
│  ┌────▼────┐                                                    │
│  │1.5-2s   │ First frame rendered                               │
│  │         │ - Home screen visible                              │
│  │         │ - Auth state loading (async)                       │
│  └─────────┘                                                    │
│                                                                  │
│  Deferred Initialization:                                        │
│  - AI service: Initialize on first use                          │
│  - Subscription check: Background after UI ready                │
│  - Accessibility service: User-initiated                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Appendix: Key File References

| Component | File Path |
|-----------|-----------|
| App Entry | `lib/main.dart` |
| Root Widget | `lib/app.dart` |
| Router | `lib/core/router/app_router.dart` |
| AI Provider Interface | `lib/shared/services/ai/ai_provider.dart` |
| AI Service | `lib/shared/services/ai/ai_service.dart` |
| Gemini Provider | `lib/shared/services/ai/gemini_provider.dart` |
| OpenAI Provider | `lib/shared/services/ai/openai_provider.dart` |
| Anthropic Provider | `lib/shared/services/ai/anthropic_provider.dart` |
| Accessibility Channel | `lib/core/platform_channels/accessibility_channel.dart` |
| Auth Providers | `lib/features/auth/domain/providers/auth_providers.dart` |
| Document Scan Providers | `lib/features/document_scan/domain/providers/document_scan_providers.dart` |
| Subscription Providers | `lib/features/subscription/domain/providers/subscription_providers.dart` |
| Persona Model | `lib/shared/models/persona_model.dart` |
| AI Config Model | `lib/shared/models/ai_config_model.dart` |

---

**Document End**
