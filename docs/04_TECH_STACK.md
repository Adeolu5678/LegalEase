# LegalEase - Technology Stack Document

## Table of Contents
1. [Executive Summary](#1-executive-summary)
2. [Frontend Stack](#2-frontend-stack)
3. [Backend Stack](#3-backend-stack)
4. [AI & OCR Integration](#4-ai--ocr-integration)
5. [Platform-Specific Implementations](#5-platform-specific-implementations)
6. [Database & Storage](#6-database--storage)
7. [Deployment Strategy](#7-deployment-strategy)
8. [Third-Party Services & APIs](#8-third-party-services--apis)

---

## 1. Executive Summary

### Tech Stack Overview

LegalEase is a cross-platform AI legal assistant that requires a sophisticated hybrid architecture combining Flutter for UI, native platform code for accessibility features, and cloud services for AI processing.

| Layer | Technology | Purpose |
|-------|------------|---------|
| Frontend (Mobile/Web) | Flutter 3.x | Cross-platform UI, shared business logic |
| Frontend (Desktop) | Flutter + Native Modules | Windows/macOS with accessibility APIs |
| Backend | Firebase + Cloud Functions | Serverless architecture, authentication, API gateway |
| AI Engine | Google Gemini API | Summarization, chat, persona management, generation |
| OCR | Google ML Kit | Physical document text extraction |
| Android Native | Kotlin/Java | AccessibilityService, overlay UI |
| iOS Native | Swift | Custom Keyboard Extension, Safari Web Extension |
| Desktop Native | C++/Rust + Platform APIs | UI Automation (Windows), Accessibility (macOS) |
| Database | Cloud Firestore + Firebase Storage | User data, documents, session management |

### Architecture Diagram (High-Level)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CLIENT LAYER                                    │
├─────────────────┬─────────────────┬─────────────────┬───────────────────────┤
│   Android App   │    iOS App      │   Desktop App   │      Web App          │
│  (Flutter +     │  (Flutter +     │  (Flutter +     │    (Flutter Web)      │
│   Kotlin Native)│   Swift Native) │   Native APIs)  │                       │
└────────┬────────┴────────┬────────┴────────┬────────┴──────────┬────────────┘
         │                 │                 │                    │
         └─────────────────┴─────────────────┴────────────────────┘
                                    │
                          ┌─────────▼─────────┐
                          │   Platform Channels│
                          │   (MethodChannel)  │
                          └─────────┬─────────┘
                                    │
┌───────────────────────────────────▼───────────────────────────────────────────┐
│                              BACKEND LAYER                                    │
├─────────────────────┬─────────────────────┬──────────────────────────────────┤
│  Firebase Auth      │  Cloud Functions    │  Firebase Storage                │
│  (Authentication)   │  (API Gateway)      │  (Document Storage)              │
└─────────────────────┴──────────┬──────────┴──────────────────────────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │   Cloud Firestore       │
                    │   (NoSQL Database)      │
                    └────────────┬────────────┘
                                 │
┌────────────────────────────────▼──────────────────────────────────────────────┐
│                            AI/ML LAYER                                        │
├─────────────────────────────────┬─────────────────────────────────────────────┤
│     Google Gemini API           │        Google ML Kit                        │
│  - Document Summarization       │   - On-device OCR                           │
│  - Persona Management           │   - Text Recognition                        │
│  - Chat/Q&A                     │   - Document Scanning                       │
│  - Text Generation              │                                             │
└─────────────────────────────────┴─────────────────────────────────────────────┘
```

---

## 2. Frontend Stack

### 2.1 Flutter Framework

**Version:** Flutter 3.19+ (stable channel)

**Justification:**
- Single codebase for Android, iOS, Web, and Desktop platforms
- Native performance through AOT compilation
- Hot reload for rapid development iteration
- Strong typing with Dart language
- Excellent accessibility support built-in
- Large ecosystem of packages
- Direct integration with Firebase services

### 2.2 Flutter Package Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.4.0 | State management |
| `go_router` | ^13.0.0 | Declarative routing |
| `firebase_core` | ^2.24.0 | Firebase initialization |
| `firebase_auth` | ^4.16.0 | User authentication |
| `cloud_firestore` | ^4.14.0 | Database operations |
| `firebase_storage` | ^11.6.0 | File storage |
| `google_generative_ai` | ^0.2.0 | Gemini API client |
| `google_mlkit_text_recognition` | ^0.11.0 | OCR functionality |
| `image_picker` | ^1.0.7 | Camera/gallery access |
| `file_picker` | ^6.1.1 | Document file selection |
| `flutter_markdown` | ^0.6.18+3 | Markdown rendering |
| `syncfusion_flutter_pdf` | ^24.1.41 | PDF parsing |
| `permission_handler` | ^11.3.0 | Runtime permissions |
| `flutter_animate` | ^4.3.0 | Animations |
| `freezed` | ^2.4.5 | Immutable data classes |
| `json_serializable` | ^6.7.1 | JSON serialization |

### 2.3 Platform Channels Architecture

Flutter communicates with native platform code through **Platform Channels** (MethodChannel, EventChannel).

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter (Dart)                           │
│  ┌─────────────────────────────────────────────────────┐    │
│  │           Platform Channel Service                   │    │
│  │  - MethodChannel('legalease_android_accessibility') │    │
│  │  - MethodChannel('legalease_ios_keyboard')          │    │
│  │  - EventChannel('legalease_text_stream')            │    │
│  └──────────────────────┬──────────────────────────────┘    │
└─────────────────────────┼───────────────────────────────────┘
                          │
         ┌────────────────┼────────────────┐
         │                │                │
         ▼                ▼                ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│   Android   │  │    iOS      │  │   Desktop   │
│   (Kotlin)  │  │   (Swift)   │  │   (C++/Rust)│
└─────────────┘  └─────────────┘  └─────────────┘
```

**Dart Platform Channel Interface:**

```dart
class NativeAccessibilityService {
  static const MethodChannel _androidChannel = 
      MethodChannel('legalease_android_accessibility');
  static const MethodChannel _iosChannel = 
      MethodChannel('legalease_ios_keyboard');
  static const EventChannel _textStreamChannel = 
      EventChannel('legalease_text_stream');

  Future<bool> enableAccessibilityService() async {
    if (Platform.isAndroid) {
      return await _androidChannel.invokeMethod('enableAccessibility');
    }
    return false;
  }

  Future<String?> extractScreenText() async {
    if (Platform.isAndroid) {
      return await _androidChannel.invokeMethod('extractScreenText');
    }
    return null;
  }

  Stream<String> get textStream =>
      _textStreamChannel.receiveBroadcastStream().map((event) => event as String);
}
```

### 2.4 Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── platform_channels/
├── features/
│   ├── auth/
│   ├── document_scan/
│   ├── tc_scanner/
│   ├── writing_assistant/
│   ├── chat/
│   └── settings/
├── shared/
│   ├── widgets/
│   ├── models/
│   └── services/
└── l10n/
    └── app_localizations.dart

android/
├── app/src/main/kotlin/com/legalease/
│   ├── MainActivity.kt
│   ├── accessibility/
│   │   ├── LegalEaseAccessibilityService.kt
│   │   └── AccessibilityNodeParser.kt
│   ├── overlay/
│   │   ├── OverlayService.kt
│   │   └── FloatingButtonView.kt
│   └── channels/
│       └── AccessibilityMethodChannel.kt

ios/
├── Runner/
│   ├── AppDelegate.swift
│   └── KeyboardExtension/
│       ├── KeyboardViewController.swift
│       └── LegalEaseKeyboard.swift

windows/
├── runner/
│   └── accessibility/
│       └── UIAutomationBridge.cpp

macos/
├── Runner/
│   └── accessibility/
│       └── AccessibilityBridge.swift
```

---

## 3. Backend Stack

### 3.1 Firebase Suite (Recommended)

**Justification for Firebase:**
- Native Flutter integration with official SDKs
- Serverless architecture reduces operational complexity
- Real-time database sync for chat and document collaboration
- Built-in authentication with multiple providers
- Automatic scaling without infrastructure management
- Generous free tier for MVP development
- Integrated analytics and crash reporting

### 3.2 Backend Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         FIREBASE BACKEND                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    Firebase Authentication                          │    │
│  │  - Email/Password                                                    │    │
│  │  - Google Sign-In                                                    │    │
│  │  - Apple Sign-In (iOS requirement)                                   │    │
│  │  - Anonymous (for freemium trial)                                    │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    Cloud Functions (Node.js 20)                      │    │
│  │                                                                      │    │
│  │  /functions                                                          │    │
│  │  ├── src/                                                           │    │
│  │  │   ├── gemini/                                                    │    │
│  │  │   │   ├── summarizeDocument.ts                                   │    │
│  │  │   │   ├── chatWithDocument.ts                                    │    │
│  │  │   │   ├── generatePersonaResponse.ts                             │    │
│  │  │   │   └── flagRisks.ts                                           │    │
│  │  │   ├── auth/                                                      │    │
│  │  │   │   ├── onUserCreate.ts                                        │    │
│  │  │   │   └── manageSubscription.ts                                  │    │
│  │  │   └── documents/                                                 │    │
│  │  │       ├── processUpload.ts                                       │    │
│  │  │       └── extractText.ts                                         │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    Cloud Firestore (NoSQL)                          │    │
│  │                                                                      │    │
│  │  /collections                                                        │    │
│  │  ├── users/                 # User profiles & settings              │    │
│  │  ├── documents/             # Uploaded document metadata            │    │
│  │  ├── chat_sessions/         # Chat history                          │    │
│  │  ├── personas/              # Custom AI personas (premium)          │    │
│  │  └── subscriptions/         # Subscription status                   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    Firebase Storage                                  │    │
│  │  - /documents/{userId}/{documentId}.pdf                             │    │
│  │  - /scans/{userId}/{scanId}.jpg                                     │    │
│  │  - /exports/{userId}/{exportId}.pdf                                 │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    Firebase Extensions                              │    │
│  │  - Stripe Payments (subscription management)                        │    │
│  │  - Firebase Remote Config (feature flags)                           │    │
│  │  - Firebase A/B Testing (experimentation)                           │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.3 Alternative Backend Options

| Option | Pros | Cons | Recommendation |
|--------|------|------|----------------|
| **Firebase (Recommended)** | Native Flutter SDK, serverless, real-time, quick setup | Vendor lock-in, limited complex queries | ✅ Primary choice |
| **Supabase** | PostgreSQL, open-source, REST API | Less Flutter-native, newer ecosystem | Consider for future |
| **Custom Node.js + MongoDB** | Full control, flexible schema | More operational overhead, scaling complexity | Not recommended for MVP |
| **Appwrite** | Self-hosted, open-source | Requires hosting, smaller community | Consider for enterprise |

### 3.4 Cloud Functions API Endpoints

| Endpoint | Method | Purpose | Auth |
|----------|--------|---------|------|
| `/api/v1/documents/summarize` | POST | Summarize uploaded document | Required |
| `/api/v1/documents/flag-risks` | POST | Extract red flags from text | Required |
| `/api/v1/chat/message` | POST | Send message to document chat | Required |
| `/api/v1/personas/create` | POST | Create custom persona | Premium |
| `/api/v1/personas/apply` | POST | Apply persona to generation | Premium |
| `/api/v1/writing/suggest` | POST | Get writing suggestions | Required |
| `/api/v1/tc/analyze` | POST | Analyze T&C text from overlay | Required |

---

## 4. AI & OCR Integration

### 4.1 Google Gemini API Integration

**Model Selection:**

| Model | Use Case | Context Window | Rate Limit |
|-------|----------|----------------|------------|
| `gemini-1.5-pro` | Document analysis, complex reasoning | 1M tokens | 2 RPM (free), 60 RPM (paid) |
| `gemini-1.5-flash` | Chat, quick responses, writing suggestions | 1M tokens | 15 RPM (free), 1000 RPM (paid) |
| `gemini-1.0-pro` | Simple Q&A, fallback | 32K tokens | 15 RPM (free) |

**Recommended Configuration:**

```dart
class GeminiService {
  final GenerativeModel _proModel;
  final GenerativeModel _flashModel;

  GeminiService()
      : _proModel = GenerativeModel(
          model: 'gemini-1.5-pro',
          apiKey: Environment.geminiApiKey,
          generationConfig: GenerationConfig(
            temperature: 0.3,  // Lower for factual legal analysis
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 8192,
          ),
          safetySettings: [
            SafetySetting(
              HarmCategory.harassment,
              HarmBlockThreshold.medium,
            ),
            SafetySetting(
              HarmCategory.dangerousContent,
              HarmBlockThreshold.medium,
            ),
          ],
        ),
      _flashModel = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: Environment.geminiApiKey,
          generationConfig: GenerationConfig(
            temperature: 0.5,
            maxOutputTokens: 2048,
          ),
        );

  Future<SummarizationResult> summarizeDocument(String documentText) async {
    final prompt = '''You are a legal document analyzer. Analyze the following 
    document and provide:
    1. A plain English summary
    2. Key terms and obligations
    3. Potential red flags (hidden clauses, unfair terms)
    4. Recommended actions

    Document:
    $documentText''';

    final response = await _proModel.generateContent([Content.text(prompt)]);
    return SummarizationResult.fromResponse(response);
  }
}
```

### 4.2 Gemini System Prompts

**Legal Document Analyzer Prompt:**

```
You are LegalEase, an expert legal document analyzer designed to help 
non-lawyers understand complex legal documents.

Your responsibilities:
1. Translate legalese into clear, plain English
2. Identify and highlight "red flags" - hidden clauses, one-sided terms, 
   potential liabilities
3. Explain the practical implications of key provisions
4. Suggest questions the user should ask before signing

Guidelines:
- Be thorough but accessible
- Use formatting (bullet points, bold text) for readability
- Always note uncertainty or areas requiring professional legal advice
- Never provide binding legal advice; frame as analysis and suggestions
- If the document appears to be a standard consumer contract, highlight 
  any deviations from typical terms
```

**Persona-Based Response Generation:**

```
You are adopting the following persona for this interaction:

Persona Name: {{persona_name}}
Tone: {{tone}}
Communication Style: {{style}}
Language Complexity: {{complexity_level}}

Examples of this persona's writing style:
{{example_outputs}}

Apply this persona when:
- Generating draft contract language
- Suggesting text rewrites
- Providing negotiation scripts
- Responding to user questions
```

### 4.3 Google ML Kit OCR Integration

**Implementation Strategy:**

```dart
class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<OCRResult> processDocumentImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    
    final RecognizedText recognizedText = 
        await _textRecognizer.processImage(inputImage);
    
    String fullText = recognizedText.text;
    
    List<TextBlock> blocks = recognizedText.blocks;
    List<TextElement> elements = [];
    
    for (TextBlock block in blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          elements.add(element);
        }
      }
    }
    
    return OCRResult(
      fullText: fullText,
      blocks: blocks,
      confidence: _calculateConfidence(elements),
      boundingBoxes: elements.map((e) => e.boundingBox).toList(),
    );
  }

  void dispose() {
    _textRecognizer.close();
  }
}
```

**OCR Pipeline Flow:**

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Camera/   │────▶│    Image    │────▶│    ML Kit   │────▶│    Gemini   │
│   Gallery   │     │  Preprocess │     │     OCR     │     │    API      │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
                          │                    │                    │
                          ▼                    ▼                    ▼
                   - Resize/rotate     - Text extraction    - Summarization
                   - Enhance contrast  - Block detection    - Risk flagging
                   - Correct skew      - Confidence score   - Q&A preparation
```

### 4.4 Token Management & Cost Optimization

| Strategy | Description |
|----------|-------------|
| **Chunking** | Split large documents into 10K token chunks for processing |
| **Caching** | Cache summaries and analyses in Firestore to avoid re-processing |
| **Smart Routing** | Use Flash model for simple queries, Pro for complex analysis |
| **Context Compression** | Summarize document context for follow-up questions |
| **On-device Preprocessing** | Extract text locally with ML Kit before API calls |

---

## 5. Platform-Specific Implementations

### 5.1 Android Native Implementation

**Required Components:**

| Component | Purpose | API Level |
|-----------|---------|-----------|
| `AccessibilityService` | Read screen content from other apps | API 18+ |
| `SYSTEM_ALERT_WINDOW` | Display floating overlay UI | API 23+ |
| `Foreground Service` | Keep service alive in background | API 24+ |
| `Notification Channel` | Service status indication | API 26+ |

**AndroidManifest.xml Permissions:**

```xml
<manifest>
    <!-- Accessibility Service -->
    <uses-permission android:name="android.permission.BIND_ACCESSIBILITY_SERVICE" />
    
    <!-- Overlay Permission -->
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    
    <!-- Foreground Service -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />
    
    <!-- Internet -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <!-- Camera for document scanning -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    
    <application>
        <service
            android:name=".accessibility.LegalEaseAccessibilityService"
            android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"
            android:exported="true">
            <intent-filter>
                <action android:name="android.accessibilityservice.AccessibilityService" />
            </intent-filter>
            <meta-data
                android:name="android.accessibilityservice"
                android:resource="@xml/accessibility_service_config" />
        </service>
        
        <service
            android:name=".overlay.OverlayService"
            android:foregroundServiceType="specialUse" />
    </application>
</manifest>
```

**Accessibility Service Configuration (res/xml/accessibility_service_config.xml):**

```xml
<accessibility-service
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:description="@string/accessibility_service_description"
    android:accessibilityEventTypes="typeViewTextChanged|typeViewFocused|typeWindowStateChanged"
    android:accessibilityFeedbackType="feedbackGeneric"
    android:canRetrieveWindowContent="true"
    android:notificationTimeout="100"
    android:settingsActivity="com.legalease.MainActivity" />
```

**AccessibilityService Implementation:**

```kotlin
class LegalEaseAccessibilityService : AccessibilityService() {
    
    private var isScanningEnabled = false
    private val scope = CoroutineScope(Dispatchers.Default)
    
    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (!isScanningEnabled) return
        
        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                val packageName = event.packageName?.toString()
                if (isLikelyTcScreen(packageName)) {
                    showFloatingButton()
                }
            }
            AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED -> {
                // Real-time typing detection for writing assistant
                if (event.source?.isEditable == true) {
                    val text = event.text?.toString() ?: return
                    analyzeTextForSuggestions(text)
                }
            }
        }
    }
    
    private fun extractAllText(rootNode: AccessibilityNodeInfo?): String {
        if (rootNode == null) return ""
        
        val textBuilder = StringBuilder()
        
        fun traverseNode(node: AccessibilityNodeInfo) {
            if (node.text != null) {
                textBuilder.append(node.text).append("\n")
            }
            
            for (i in 0 until node.childCount) {
                node.getChild(i)?.let { traverseNode(it) }
            }
        }
        
        traverseNode(rootNode)
        return textBuilder.toString()
    }
    
    private fun isLikelyTcScreen(packageName: String?): Boolean {
        // Heuristics to detect T&C screens
        val rootNode = rootInActiveWindow ?: return false
        
        val keywords = listOf(
            "terms and conditions", "privacy policy", "end user license",
            "eula", "terms of service", "user agreement"
        )
        
        val pageText = extractAllText(rootNode).lowercase()
        return keywords.any { pageText.contains(it) }
    }
    
    private fun showFloatingButton() {
        val intent = Intent(this, OverlayService::class.java).apply {
            action = OverlayService.ACTION_SHOW_BUTTON
        }
        startService(intent)
    }
    
    fun enableScanning() {
        isScanningEnabled = true
    }
    
    fun disableScanning() {
        isScanningEnabled = false
    }
    
    override fun onInterrupt() {}
    
    companion object {
        var instance: LegalEaseAccessibilityService? = null
    }
}
```

**Overlay Service Implementation:**

```kotlin
class OverlayService : Service() {
    
    private var windowManager: WindowManager? = null
    private var floatingView: View? = null
    private var summaryView: View? = null
    
    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        startForeground(NOTIFICATION_ID, createNotification())
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_SHOW_BUTTON -> showFloatingButton()
            ACTION_SHOW_SUMMARY -> showSummaryView(intent.getStringExtra("summary"))
            ACTION_HIDE -> hideAll()
        }
        return START_STICKY
    }
    
    private fun showFloatingButton() {
        if (floatingView != null || !hasOverlayPermission()) return
        
        floatingView = LayoutInflater.from(this)
            .inflate(R.layout.floating_scan_button, null)
        
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.END
            x = 32
            y = 200
        }
        
        floatingView?.findViewById<ImageView>(R.id.btn_scan)?.setOnClickListener {
            onScanButtonClicked()
        }
        
        // Draggable implementation
        floatingView?.setOnTouchListener(FloatingTouchListener(windowManager!!, params))
        
        windowManager?.addView(floatingView, params)
    }
    
    private fun onScanButtonClicked() {
        val text = LegalEaseAccessibilityService.instance?.let {
            it.extractAllText(it.rootInActiveWindow)
        } ?: return
        
        // Send to Gemini API for analysis
        scope.launch {
            val summary = GeminiApiClient.analyzeTc(text)
            showSummaryView(summary)
        }
    }
    
    private fun showSummaryView(summary: String?) {
        // Display summary in overlay
    }
    
    companion object {
        const val ACTION_SHOW_BUTTON = "show_button"
        const val ACTION_SHOW_SUMMARY = "show_summary"
        const val ACTION_HIDE = "hide"
    }
}
```

### 5.2 iOS Native Implementation

**iOS Architecture Constraints:**

Apple's sandboxing restrictions prevent global accessibility scanning. Alternative approaches:

| Approach | Capability | Limitation |
|----------|------------|------------|
| Custom Keyboard Extension | Can read text in any text field | Cannot read static text/labels |
| Safari Web Extension | Can read/modify web content | Safari only, not other browsers |
| Share Sheet Extension | User-initiated text sharing | Requires manual action |
| UIPasteboard | Read copied text | Requires user to copy |

**Recommended iOS Strategy:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         iOS IMPLEMENTATION STRATEGY                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    Primary: Custom Keyboard Extension               │    │
│  │                                                                      │    │
│  │  - Replaces system keyboard in any app                              │    │
│  │  - Real-time text analysis as user types                            │    │
│  │  - Inline suggestions above keyboard                                │    │
│  │  - "Analyze" button for writing assistance                          │    │
│  │                                                                      │    │
│  │  Limitations:                                                        │    │
│  │  - Cannot read non-editable text (T&C screens)                      │    │
│  │  - Requires "Allow Full Access" for network requests                │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    Secondary: Safari Web Extension                  │    │
│  │                                                                      │    │
│  │  - Injects into Safari browser                                      │    │
│  │  - Can read and modify DOM content                                  │    │
│  │  - Detect T&C pages and offer analysis                              │    │
│  │  - Works for web-based T&C scanning                                 │    │
│  │                                                                      │    │
│  │  Limitations:                                                        │    │
│  │  - Safari only (not Chrome, Firefox, in-app browsers)               │    │
│  │  - Requires user to enable in Safari settings                       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    Tertiary: Share Sheet Extension                  │    │
│  │                                                                      │    │
│  │  - User selects text → Share → LegalEase                            │    │
│  │  - Works with any selectable text                                   │    │
│  │  - Falls back when other methods unavailable                        │    │
│  │                                                                      │    │
│  │  Limitations:                                                        │    │
│  │  - Requires manual user action                                      │    │
│  │  - Not real-time                                                    │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Custom Keyboard Extension Structure:**

```
ios/
├── Runner/
│   └── ...
├── KeyboardExtension/
│   ├── KeyboardViewController.swift
│   ├── LegalEaseKeyboardView.swift
│   ├── KeyboardLayoutManager.swift
│   ├── TextAnalyzer.swift
│   └── Info.plist
├── SafariExtension/
│   ├── SafariExtensionHandler.swift
│   ├── SafariExtensionViewController.swift
│   ├── content.js
│   ├── styles.css
│   └── Info.plist
└── ShareExtension/
    ├── ShareViewController.swift
    └── Info.plist
```

**Keyboard Extension Implementation:**

```swift
class KeyboardViewController: UIInputViewController {
    
    private var keyboardView: LegalEaseKeyboardView!
    private var textAnalyzer: TextAnalyzer!
    private var suggestionsView: SuggestionsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardView = LegalEaseKeyboardView(delegate: self)
        textAnalyzer = TextAnalyzer()
        suggestionsView = SuggestionsView()
        
        view.addSubview(keyboardView)
        view.addSubview(suggestionsView)
        
        setupConstraints()
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        guard let proxy = textDocumentProxy else { return }
        
        let currentText = proxy.documentContextBeforeInput ?? ""
        
        // Analyze text for legal suggestions
        Task { @MainActor in
            if let suggestions = await textAnalyzer.analyze(currentText) {
                suggestionsView.display(suggestions)
            }
        }
    }
    
    func insertSuggestion(_ suggestion: String) {
        textDocumentProxy.insertText(suggestion)
    }
    
    func analyzeFullText() {
        guard hasFullAccess else {
            showFullAccessRequiredAlert()
            return
        }
        
        let fullText = textDocumentProxy.documentContextBeforeInput ?? ""
        
        Task { @MainActor in
            let analysis = await GeminiAPIClient.analyzeWriting(fullText)
            displayAnalysisResults(analysis)
        }
    }
}
```

**Safari Web Extension (content.js):**

```javascript
// Detect T&C pages
const tcPatterns = [
    /terms.{0,20}(and|&).{0,20}conditions/i,
    /privacy.{0,20}policy/i,
    /end.{0,20}user.{0,20}license/i,
    /user.{0,20}agreement/i,
    /eula/i,
    /terms.{0,20}of.{0,20}service/i
];

function isTcPage() {
    const pageText = document.body.innerText;
    const pageTitle = document.title;
    
    return tcPatterns.some(pattern => 
        pattern.test(pageText) || pattern.test(pageTitle)
    );
}

function extractPageText() {
    // Get main content, exclude navigation, footers, etc.
    const mainContent = document.querySelector('main, article, .content, #content, .terms');
    return mainContent ? mainContent.innerText : document.body.innerText;
}

if (isTcPage()) {
    // Inject floating button
    const button = document.createElement('div');
    button.id = 'legalease-scan-btn';
    button.innerHTML = `
        <img src="${browser.runtime.getURL('icons/icon48.png')}" />
        <span>Scan with LegalEase</span>
    `;
    button.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        z-index: 999999;
        background: #4F46E5;
        color: white;
        padding: 10px 16px;
        border-radius: 24px;
        cursor: pointer;
        font-family: -apple-system, sans-serif;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        display: flex;
        align-items: center;
        gap: 8px;
    `;
    
    button.addEventListener('click', async () => {
        const text = extractPageText();
        button.innerHTML = '<span>Analyzing...</span>';
        
        const response = await browser.runtime.sendMessage({
            action: 'analyzeTc',
            text: text
        });
        
        displaySummary(response.summary);
    });
    
    document.body.appendChild(button);
}
```

### 5.3 Desktop Implementation

**Windows Implementation (UI Automation):**

```cpp
// UIAutomationBridge.cpp
#include <windows.h>
#include <uiautomation.h>

class UIAutomationBridge {
private:
    IUIAutomation* automation;
    IUIAutomationElement* rootElement;
    
public:
    UIAutomationBridge() {
        CoInitialize(NULL);
        CoCreateInstance(
            __uuidof(CUIAutomation),
            NULL,
            CLSCTX_INPROC_SERVER,
            __uuidof(IUIAutomation),
            (void**)&automation
        );
        automation->GetRootElement(&rootElement);
    }
    
    std::wstring GetFocusedText() {
        IUIAutomationElement* focusedElement;
        automation->GetFocusedElement(&focusedElement);
        
        BSTR name;
        focusedElement->get_CurrentName(&name);
        
        // Get text pattern
        IUIAutomationTextPattern* textPattern;
        focusedElement->GetCurrentPattern(
            UIA_TextPatternId,
            (IUnknown**)&textPattern
        );
        
        if (textPattern) {
            IUIAutomationTextRange* textRange;
            textPattern->get_DocumentRange(&textRange);
            
            BSTR text;
            textRange->GetText(-1, &text);
            return std::wstring(text);
        }
        
        return std::wstring(name);
    }
    
    std::wstring GetAllWindowText(HWND hwnd) {
        // Walk window tree and extract all text
        // ...
    }
    
    ~UIAutomationBridge() {
        if (rootElement) rootElement->Release();
        if (automation) automation->Release();
        CoUninitialize();
    }
};
```

**macOS Implementation (Accessibility API):**

```swift
// AccessibilityBridge.swift
import Cocoa
import ApplicationServices

class AccessibilityBridge {
    
    static func requestAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    static func getFocusedElementText() -> String? {
        guard let focusedApp = NSWorkspace.shared.frontmostApplication else { return nil }
        
        let pid = focusedApp.processIdentifier
        let app = AXUIElementCreateApplication(pid)
        
        var focusedElement: CFTypeRef?
        AXUIElementCopyAttributeValue(app, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        
        guard let element = focusedElement else { return nil }
        
        var value: CFTypeRef?
        AXUIElementCopyAttributeValue(element as! AXUIElement, kAXValueAttribute as CFString, &value)
        
        return value as? String
    }
    
    static func getAllWindowText() -> String {
        var allText = ""
        
        guard let focusedApp = NSWorkspace.shared.frontmostApplication else { return "" }
        let pid = focusedApp.processIdentifier
        let app = AXUIElementCreateApplication(pid)
        
        var window: CFTypeRef?
        AXUIElementCopyAttributeValue(app, kAXFocusedWindowAttribute as CFString, &window)
        
        if let windowElement = window {
            traverseElement(windowElement as! AXUIElement, &allText)
        }
        
        return allText
    }
    
    private static func traverseElement(_ element: AXUIElement, _ textCollector: inout String) {
        var value: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXValueAttribute as CFString, &value)
        
        if let text = value as? String, !text.isEmpty {
            textCollector += text + "\n"
        }
        
        var children: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &children)
        
        if let childArray = children as? [AXUIElement] {
            for child in childArray {
                traverseElement(child, &textCollector)
            }
        }
    }
}
```

**Desktop Overlay Architecture:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DESKTOP APPLICATION                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    Flutter Desktop App                               │    │
│  │                                                                      │    │
│  │  - Main UI for document management                                  │    │
│  │  - Settings and configuration                                        │    │
│  │  - Chat interface                                                    │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    Native Accessibility Monitor                      │    │
│  │                                                                      │    │
│  │  Windows: UI Automation API                                         │    │
│  │  macOS: Accessibility API                                            │    │
│  │                                                                      │    │
│  │  - Monitors active text fields                                      │    │
│  │  - Extracts text in real-time                                       │    │
│  │  - Sends to Gemini for analysis                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    Overlay Window (Always on Top)                   │    │
│  │                                                                      │    │
│  │  - Displays suggestions as user types                               │    │
│  │  - Highlights problematic text                                      │    │
│  │  - Quick actions for rewrites                                       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Database & Storage

### 6.1 Cloud Firestore Schema

**Collections Structure:**

```
firestore/
│
├── users/{userId}
│   ├── email: string
│   ├── displayName: string
│   ├── createdAt: timestamp
│   ├── subscriptionTier: 'free' | 'premium'
│   ├── subscriptionId: string | null
│   ├── settings: {
│   │   ├── defaultPersonaId: string | null
│   │   ├── notificationsEnabled: boolean
│   │   ├── theme: 'light' | 'dark' | 'system'
│   │   └── language: string
│   └── usage: {
│       ├── documentsProcessed: number
│       ├── tokensUsed: number
│       └── periodStart: timestamp
│   }
│
├── documents/{documentId}
│   ├── userId: string
│   ├── fileName: string
│   ├── fileType: 'pdf' | 'image' | 'text'
│   ├── storagePath: string
│   ├── extractedText: string
│   ├── summary: string
│   ├── redFlags: array<{
│   │   ├── severity: 'low' | 'medium' | 'high'
│   │   ├── clause: string
│   │   ├── explanation: string
│   │   └── recommendation: string
│   ├── createdAt: timestamp
│   └── metadata: {
│       ├── pageCount: number
│       ├── wordCount: number
│       └── language: string
│   }
│
├── chat_sessions/{sessionId}
│   ├── userId: string
│   ├── documentId: string | null
│   ├── title: string
│   ├── createdAt: timestamp
│   ├── updatedAt: timestamp
│   └── messages (subcollection): {
│       ├── role: 'user' | 'assistant'
│       ├── content: string
│       └── timestamp: timestamp
│   }
│
├── personas/{personaId}
│   ├── userId: string
│   ├── name: string
│   ├── description: string
│   ├── tone: 'formal' | 'casual' | 'assertive' | 'polite'
│   ├── communicationStyle: string
│   ├── languageComplexity: 'simple' | 'moderate' | 'advanced'
│   ├── systemPrompt: string
│   ├── exampleOutputs: array<string>
│   ├── isDefault: boolean
│   └── createdAt: timestamp
│
├── tc_scans/{scanId}
│   ├── userId: string
│   ├── sourceApp: string
│   ├── sourceUrl: string | null
│   ├── extractedText: string
│   ├── summary: string
│   ├── riskLevel: 'low' | 'medium' | 'high'
│   ├── keyPoints: array<string>
│   ├── createdAt: timestamp
│   └── platform: 'android' | 'ios_safari' | 'desktop'
│
└── writing_suggestions/{suggestionId}
    ├── userId: string
    ├── context: string
    ├── originalText: string
    ├── suggestions: array<{
    │   ├── type: 'rewrite' | 'tone' | 'correction'
    │   ├── text: string
    │   └── explanation: string
    ├── personaId: string | null
    └── createdAt: timestamp
```

### 6.2 Firebase Storage Structure

```
storage/
│
├── documents/
│   └── {userId}/
│       └── {documentId}/
│           ├── original.pdf
│           └── thumbnail.jpg
│
├── scans/
│   └── {userId}/
│       └── {scanId}.jpg
│
├── exports/
│   └── {userId}/
│       └── {exportId}.pdf
│
└── temp/
    └── {userId}/
        └── uploads/
            └── {tempId}
```

### 6.3 Data Security Rules

```javascript
// Firestore Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isPremium() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.subscriptionTier == 'premium';
    }
    
    match /users/{userId} {
      allow read: if isOwner(userId);
      allow create: if isOwner(userId);
      allow update: if isOwner(userId);
    }
    
    match /documents/{documentId} {
      allow read: if isOwner(resource.data.userId);
      allow create: if isAuthenticated();
      allow update, delete: if isOwner(resource.data.userId);
    }
    
    match /chat_sessions/{sessionId} {
      allow read, write: if isOwner(resource.data.userId);
    }
    
    match /personas/{personaId} {
      allow read: if isOwner(resource.data.userId);
      allow create: if isAuthenticated();
      allow update, delete: if isOwner(resource.data.userId);
      
      // Premium users can create more personas
      allow create: if isPremium() || 
        (isAuthenticated() && 
         resource.data.userId == request.auth.uid);
    }
    
    match /tc_scans/{scanId} {
      allow read, write: if isOwner(resource.data.userId);
    }
    
    match /writing_suggestions/{suggestionId} {
      allow read, write: if isOwner(resource.data.userId);
    }
  }
}

// Storage Rules
service firebase.storage {
  match /b/{bucket}/o {
    
    match /documents/{userId}/{documentId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /scans/{userId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /exports/{userId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /temp/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 6.4 Data Retention & Cleanup

| Data Type | Retention Period | Cleanup Method |
|-----------|------------------|----------------|
| User Documents | 90 days inactive | Cloud Function scheduled job |
| Chat Sessions | 180 days | User-configurable deletion |
| TC Scans | 30 days | Auto-delete after processing |
| Writing Suggestions | 7 days | Auto-delete |
| Temp Files | 24 hours | Cloud Function cleanup |

---

## 7. Deployment Strategy

### 7.1 CI/CD Pipeline

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CI/CD PIPELINE                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌───────────┐  │
│  │    Push     │────▶│    Build    │────▶│    Test     │────▶│   Deploy  │  │
│  │   (GitHub)  │     │   (Actions) │     │   (Actions) │     │  (Firebase)│  │
│  └─────────────┘     └─────────────┘     └─────────────┘     └───────────┘  │
│                                                                              │
│  Branches:                                                                   │
│  ┌─────────────────┬─────────────────┬─────────────────────────────────┐    │
│  │     Branch      │   Environment   │          Deployment             │    │
│  ├─────────────────┼─────────────────┼─────────────────────────────────┤    │
│  │  feature/*      │  None (PR)      │  PR preview (Firebase Hosting) │    │
│  │  develop        │  Staging        │  Auto-deploy to staging        │    │
│  │  main           │  Production     │  Manual approval required      │    │
│  └─────────────────┴─────────────────┴─────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.2 GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml
name: LegalEase CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage

  build-android:
    needs: analyze
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: android-release
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    needs: analyze
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build ios --release --no-codesign
      - uses: actions/upload-artifact@v4
        with:
          name: ios-release
          path: build/ios/iphoneos/

  deploy-firebase:
    needs: [build-android, build-ios]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: w9jds/firebase-action@master
        with:
          args: deploy --only functions,firestore,storage
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}

  deploy-play-store:
    needs: deploy-firebase
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT }}
          packageName: com.legalease.app
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal
```

### 7.3 Environment Configuration

| Environment | Firebase Project | Purpose |
|-------------|------------------|---------|
| Development | `legalease-dev` | Local development, testing |
| Staging | `legalease-staging` | QA testing, beta users |
| Production | `legalease-prod` | Live users |

### 7.4 Release Strategy

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         RELEASE CHANNELS                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Android:                                                                    │
│  ┌─────────────────┬─────────────────────────────────────────────────────┐  │
│  │    Channel      │                    Description                     │  │
│  ├─────────────────┼─────────────────────────────────────────────────────┤  │
│  │  Internal Test  │  Dev team testing (Firebase App Distribution)      │  │
│  │  Closed Test    │  Beta testers, selected users (Play Store)         │  │
│  │  Open Test      │  Public beta (Play Store)                          │  │
│  │  Production     │  All users (Play Store)                            │  │
│  └─────────────────┴─────────────────────────────────────────────────────┘  │
│                                                                              │
│  iOS:                                                                        │
│  ┌─────────────────┬─────────────────────────────────────────────────────┐  │
│  │    Channel      │                    Description                     │  │
│  ├─────────────────┼─────────────────────────────────────────────────────┤  │
│  │  Development    │  Dev team (Firebase App Distribution)              │  │
│  │  TestFlight     │  Beta testers                                      │  │
│  │  App Store      │  All users                                         │  │
│  └─────────────────┴─────────────────────────────────────────────────────┘  │
│                                                                              │
│  Desktop:                                                                    │
│  ┌─────────────────┬─────────────────────────────────────────────────────┐  │
│  │    Channel      │                    Description                     │  │
│  ├─────────────────┼─────────────────────────────────────────────────────┤  │
│  │  GitHub Releases│  Direct download, auto-update                      │  │
│  │  Microsoft Store│  Windows distribution [REQUIRES CLARIFICATION]     │  │
│  │  Mac App Store  │  macOS distribution [REQUIRES CLARIFICATION]       │  │
│  └─────────────────┴─────────────────────────────────────────────────────┘  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 8. Third-Party Services & APIs

### 8.1 Core Services

| Service | Purpose | Pricing Tier | Cost Estimate |
|---------|---------|--------------|---------------|
| **Google Gemini API** | AI text processing | Free tier + Pay-as-you-go | Free: 60 req/min (Flash), 2 req/min (Pro) |
| **Google ML Kit** | On-device OCR | Free | No cost (on-device) |
| **Firebase** | Backend services | Spark (Free) / Blaze (Pay-as-you-go) | Free tier sufficient for MVP |
| **Stripe** | Payment processing | Pay-as-you-go | 2.9% + $0.30 per transaction |

### 8.2 Optional/Enhancement Services

| Service | Purpose | When to Consider |
|---------|---------|------------------|
| **Google Cloud Vision API** | Advanced OCR for poor quality scans | If ML Kit insufficient |
| **Algolia** | Fast document search | If search becomes slow with scale |
| **Sentry** | Error tracking & monitoring | Production deployment |
| **Mixpanel** | Product analytics | Growth phase |
| **Intercom** | Customer support chat | Post-launch |
| **RevenueCat** | Subscription management | If Stripe integration becomes complex |

### 8.3 API Rate Limits & Quotas

| API | Free Tier Limit | Paid Tier | Optimization Strategy |
|-----|-----------------|-----------|----------------------|
| Gemini Pro | 2 RPM, 32K tokens/day | $3.50/1M input tokens | Use Flash for most operations |
| Gemini Flash | 15 RPM, 60 requests/day | $0.35/1M input tokens | Primary model for chat |
| Firebase Auth | 10K verifications/month | $0.005/verification | N/A |
| Firestore | 50K reads, 20K writes/day | $0.06/100K reads | Cache aggressively |
| Firebase Storage | 5GB/month | $0.026/GB | Compress images |

### 8.4 Security & Compliance

| Requirement | Implementation |
|-------------|----------------|
| **Data Encryption** | Firebase auto-encrypts at rest; TLS in transit |
| **API Key Protection** | Store in Firebase Remote Config; rotate regularly |
| **User Data Privacy** | GDPR-compliant data handling; user deletion endpoints |
| **Accessibility Data** | Process on-device when possible; don't store screen content |
| **Payment Security** | Stripe handles PCI compliance; never store card data |

### 8.5 Integration Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         THIRD-PARTY INTEGRATIONS                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                      Client Application                               │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                   │                                          │
│           ┌───────────────────────┼───────────────────────┐                 │
│           │                       │                       │                  │
│           ▼                       ▼                       ▼                  │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         │
│  │  Firebase SDK   │    │   Gemini SDK    │    │    ML Kit       │         │
│  │  (Auth, DB,     │    │  (Direct Call   │    │  (On-Device)    │         │
│  │   Storage)      │    │   for Web,      │    │                 │         │
│  │                 │    │   Proxy via     │    │                 │         │
│  │                 │    │   CF for Mobile)│    │                 │         │
│  └────────┬────────┘    └────────┬────────┘    └─────────────────┘         │
│           │                      │                                          │
│           ▼                      ▼                                          │
│  ┌─────────────────┐    ┌─────────────────┐                                │
│  │ Firebase Cloud   │    │ Google Cloud    │                                │
│  │ Functions        │◄───│ Gemini API      │                                │
│  │                  │    │                 │                                │
│  │ - API Proxy      │    └─────────────────┘                                │
│  │ - Webhooks       │                                                       │
│  └────────┬────────┘                                                       │
│           │                                                                 │
│           ▼                                                                 │
│  ┌─────────────────┐                                                       │
│  │    Stripe       │                                                       │
│  │  (Subscriptions)│                                                       │
│  │                 │                                                       │
│  │ - Firebase      │                                                       │
│  │   Extension     │                                                       │
│  └─────────────────┘                                                       │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Summary & Recommendations

### Technology Stack Summary

| Component | Technology | Status |
|-----------|------------|--------|
| Frontend Framework | Flutter 3.19+ | ✅ Confirmed |
| Android Native | Kotlin + AccessibilityService | ✅ Confirmed |
| iOS Native | Swift + Custom Keyboard + Safari Extension | ✅ Confirmed |
| Desktop | Flutter + Native Accessibility APIs | ✅ Confirmed |
| Backend | Firebase (Auth, Firestore, Functions, Storage) | ✅ Recommended |
| AI Engine | Google Gemini API | ✅ Confirmed |
| OCR | Google ML Kit | ✅ Confirmed |
| Payments | Stripe (via Firebase Extension) | ✅ Recommended |
| CI/CD | GitHub Actions + Firebase CLI | ✅ Recommended |

### Items Requiring Clarification

| Item | Question | Impact |
|------|----------|--------|
| Desktop Distribution | Microsoft Store / Mac App Store vs. direct download? | Affects signing, auto-update implementation |
| User Limits | Expected concurrent users at launch? | Affects Firebase tier selection |
| Document Size | Maximum document size to support? | Affects chunking strategy, storage costs |
| Language Support | Languages beyond English at launch? | Affects Gemini prompts, localization |
| Enterprise Features | B2B/team features required? | Affects authentication, data isolation |
| Offline Support | Required offline functionality? | Affects data caching strategy |

---

*Document Version: 1.0*  
*Last Updated: February 2026*  
*Author: Technology Architecture Team*
