# LegalEase API Reference

Complete API documentation for the LegalEase Dart/Flutter codebase.

## Table of Contents

1. [AI Services](#1-ai-services)
   - [AiProvider (Abstract)](#aiprovider-abstract)
   - [GeminiProvider](#geminiprovider)
   - [OpenAiProvider](#openaiprovider)
   - [AnthropicProvider](#anthropicprovider)
   - [AiService](#aiservice)
   - [AiConfig](#aiconfig)
2. [Riverpod Providers](#2-riverpod-providers)
   - [AI Providers](#ai-providers)
   - [Auth Providers](#auth-providers)
   - [Subscription Providers](#subscription-providers)
   - [Persona Providers](#persona-providers)
   - [Chat Providers](#chat-providers)
   - [Document Scan Providers](#document-scan-providers)
   - [TC Scanner Providers](#tc-scanner-providers)
3. [Platform Channels](#3-platform-channels)
   - [NativeAccessibilityService](#nativeaccessibilityservice)
   - [WindowsAccessibilityChannel](#windowsaccessibilitychannel)
   - [MacosAccessibilityChannel](#macosaccessibilitychannel)
   - [DesktopOverlayChannel](#desktopoverlaychannel)
4. [Document Scan Feature](#4-document-scan-feature)
   - [OcrService](#ocrservice)
   - [DocumentProcessor](#documentprocessor)
   - [Analysis Models](#analysis-models)
   - [Document Scan Providers](#document-scan-providers-1)
5. [T&C Scanner Feature](#5-tc-scanner-feature)
   - [TcDetectorService](#tcdetectorservice)
   - [TC Scanner Providers](#tc-scanner-providers-1)
6. [Chat Feature](#6-chat-feature)
   - [ChatMessage](#chatmessage)
   - [ChatSession](#chatsession)
   - [Chat Providers](#chat-providers-1)
7. [Persona Feature](#7-persona-feature)
   - [Persona Model](#persona-model)
   - [PersonaRepository](#personarepository)
   - [PersonaService](#personaservice)
   - [Persona Providers](#persona-providers-1)
8. [Subscription Feature](#8-subscription-feature)
   - [Subscription Models](#subscription-models)
   - [SubscriptionRepository](#subscriptionrepository)
   - [SubscriptionService](#subscriptionservice)
   - [Subscription Providers](#subscription-providers-1)
9. [Auth Feature](#9-auth-feature)
   - [UserEntity](#userentity)
   - [AuthRepository](#authrepository)
   - [Auth Providers](#auth-providers-1)
10. [Shared Models](#10-shared-models)
    - [DocumentModel](#documentmodel)
    - [RedFlag](#redflag)
11. [Export Feature (v1.2.0)](#11-export-feature-v120)
    - [ExportService](#exportservice)
    - [Export Providers](#export-providers)
12. [Legal Dictionary Feature (v1.2.0)](#12-legal-dictionary-feature-v120)
    - [LegalTerm](#legalterm)
    - [DictionaryService](#dictionaryservice)
    - [Dictionary Providers](#dictionary-providers)
13. [Reminders Feature (v1.2.0)](#13-reminders-feature-v120)
    - [Reminder](#reminder)
    - [ReminderService](#reminderservice)
    - [Reminder Providers](#reminder-providers)
14. [Voice Input Feature (v1.2.0)](#14-voice-input-feature-v120)
    - [Voice Input Integration](#voice-input-integration)

---

## 1. AI Services

### AiProvider (Abstract)

Abstract interface defining the contract for AI provider implementations.

**Location:** `lib/shared/services/ai/ai_provider.dart`

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
  Future<bool> isAvailable();
  Future<void> initialize();
  void dispose();
}
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `name` | `String` | Display name of the AI provider |
| `modelId` | `String` | Current model identifier (get/set) |

#### Methods

##### summarizeDocument

Summarizes a legal document.

```dart
Future<String> summarizeDocument(String documentText, {Persona? persona})
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `documentText` | `String` | Yes | The full text of the document to summarize |
| `persona` | `Persona?` | No | Optional persona for customized response style |

**Returns:** `Future<String>` - Structured summary of the document

**Example:**
```dart
final summary = await provider.summarizeDocument(
  documentText,
  persona: Persona.friendlyAdvisor(),
);
```

---

##### translateToPlainEnglish

Converts legal jargon to plain English.

```dart
Future<String> translateToPlainEnglish(String legaleseText, {Persona? persona})
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `legaleseText` | `String` | Yes | Legal text to translate |
| `persona` | `Persona?` | No | Optional persona for translation style |

**Returns:** `Future<String>` - Plain English translation

---

##### detectRedFlags

Analyzes document for potential red flags and risky clauses.

```dart
Future<List<RedFlag>> detectRedFlags(String documentText, {Persona? persona})
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `documentText` | `String` | Yes | Document text to analyze |
| `persona` | `Persona?` | No | Optional persona for analysis style |

**Returns:** `Future<List<RedFlag>>` - List of detected red flags

**Example:**
```dart
final redFlags = await provider.detectRedFlags(
  contractText,
  persona: Persona.corporateCounsel(),
);

for (final flag in redFlags) {
  print('${flag.severity}: ${flag.originalText}');
  print('Explanation: ${flag.explanation}');
}
```

---

##### chatWithContext

Conducts a contextual chat about a document.

```dart
Future<String> chatWithContext({
  required String documentText,
  required String userQuery,
  List<Map<String, String>>? conversationHistory,
  Persona? persona,
})
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `documentText` | `String` | Yes | Document context for the conversation |
| `userQuery` | `String` | Yes | User's question or message |
| `conversationHistory` | `List<Map<String, String>>?` | No | Previous messages in format `{'role': 'user/assistant', 'content': '...'}` |
| `persona` | `Persona?` | No | Optional persona for response style |

**Returns:** `Future<String>` - AI response to the query

---

##### generateText

Generates text from a prompt.

```dart
Future<String> generateText({
  required String prompt,
  String? persona,
  int? maxTokens,
})
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `prompt` | `String` | Yes | The prompt to generate from |
| `persona` | `String?` | No | Optional persona description |
| `maxTokens` | `int?` | No | Maximum tokens to generate (default: 2048) |

**Returns:** `Future<String>` - Generated text

---

##### isAvailable

Checks if the provider is properly configured and available.

```dart
Future<bool> isAvailable()
```

**Returns:** `Future<bool>` - Whether the provider is available

---

##### initialize

Initializes the provider with necessary setup.

```dart
Future<void> initialize()
```

**Throws:** `StateError` if API key is not configured

---

##### dispose

Releases resources used by the provider.

```dart
void dispose()
```

---

### GeminiProvider

Implementation of `AiProvider` for Google Gemini.

**Location:** `lib/shared/services/ai/gemini_provider.dart`

```dart
class GeminiProvider implements AiProvider {
  GeminiProvider({
    required String apiKey,
    String modelId = 'gemini-pro',
  });
}
```

#### Constructor Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `apiKey` | `String` | Yes | - | Google AI API key |
| `modelId` | `String` | No | `'gemini-pro'` | Model identifier |

#### Available Models

- `gemini-pro`
- `gemini-pro-vision`
- `gemini-1.5-pro`
- `gemini-1.5-flash`

**Example:**
```dart
final provider = GeminiProvider(
  apiKey: 'your-api-key',
  modelId: 'gemini-1.5-pro',
);

await provider.initialize();
final isAvailable = await provider.isAvailable();
```

---

### OpenAiProvider

Implementation of `AiProvider` for OpenAI.

**Location:** `lib/shared/services/ai/openai_provider.dart`

```dart
class OpenAiProvider implements AiProvider {
  OpenAiProvider({
    required String apiKey,
    String modelId = 'gpt-4-turbo',
    http.Client? client,
  });
}
```

#### Constructor Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `apiKey` | `String` | Yes | - | OpenAI API key |
| `modelId` | `String` | No | `'gpt-4-turbo'` | Model identifier |
| `client` | `http.Client?` | No | `http.Client()` | HTTP client for testing |

#### Available Models

- `gpt-4`
- `gpt-4-turbo`
- `gpt-4o`
- `gpt-3.5-turbo`

**Throws:** `Exception` with OpenAI API error details on failure

**Example:**
```dart
final provider = OpenAiProvider(
  apiKey: 'your-api-key',
  modelId: 'gpt-4o',
);

final response = await provider.chatWithContext(
  documentText: contractText,
  userQuery: 'What are my obligations?',
);
```

---

### AnthropicProvider

Implementation of `AiProvider` for Anthropic Claude.

**Location:** `lib/shared/services/ai/anthropic_provider.dart`

```dart
class AnthropicProvider implements AiProvider {
  AnthropicProvider({
    required String apiKey,
    String modelId = 'claude-3-sonnet-20240229',
    http.Client? client,
  });
}
```

#### Constructor Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `apiKey` | `String` | Yes | - | Anthropic API key |
| `modelId` | `String` | No | `'claude-3-sonnet-20240229'` | Model identifier |
| `client` | `http.Client?` | No | `http.Client()` | HTTP client for testing |

#### Available Models

- `claude-3-opus-20240229`
- `claude-3-sonnet-20240229`
- `claude-3-haiku-20240307`
- `claude-3-5-sonnet-20241022`

**Example:**
```dart
final provider = AnthropicProvider(
  apiKey: 'your-api-key',
  modelId: 'claude-3-opus-20240229',
);

final redFlags = await provider.detectRedFlags(termsText);
```

---

### AiService

Central service managing AI providers and operations.

**Location:** `lib/shared/services/ai/ai_service.dart`

```dart
class AiService {
  AiService({required AiConfig config});
  
  AiProvider get provider;
  AiProvider getProvider(AiProviderType type);
  void setCurrentProvider(AiProviderType type);
  AiProviderType get currentProviderType;
  List<AiProviderType> get availableProviders;
  bool isProviderConfigured(AiProviderType type);
  Future<Map<AiProviderType, bool>> checkProviderAvailability();
  
  // Delegates to current provider
  Future<String> summarizeDocument(String documentText, {Persona? persona});
  Future<String> translateToPlainEnglish(String legaleseText, {Persona? persona});
  Future<List<RedFlag>> detectRedFlags(String documentText, {Persona? persona});
  Future<String> chatWithContext({...});
  Future<String> generateText({...});
  
  void dispose();
}
```

#### Constructor

```dart
AiService({required AiConfig config})
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `config` | `AiConfig` | Yes | Configuration containing API keys and settings |

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `provider` | `AiProvider` | Current active provider |
| `currentProviderType` | `AiProviderType` | Type of current provider |
| `availableProviders` | `List<AiProviderType>` | List of configured providers |

#### Methods

##### getProvider

Gets a specific provider by type.

```dart
AiProvider getProvider(AiProviderType type)
```

**Throws:** `StateError` if provider is not configured

---

##### setCurrentProvider

Switches the active provider.

```dart
void setCurrentProvider(AiProviderType type)
```

---

##### checkProviderAvailability

Checks availability of all configured providers.

```dart
Future<Map<AiProviderType, bool>> checkProviderAvailability()
```

**Returns:** Map of provider types to their availability status

**Example:**
```dart
final service = AiService(config: aiConfig);

// Switch providers
service.setCurrentProvider(AiProviderType.openai);

// Check all providers
final availability = await service.checkProviderAvailability();
print('Gemini available: ${availability[AiProviderType.gemini]}');

// Use current provider
final summary = await service.summarizeDocument(documentText);
```

---

### AiServiceProvider

StateNotifier for managing AiService lifecycle.

```dart
class AiServiceProvider extends StateNotifier<AiService?> {
  AiServiceProvider();
  
  void initialize(AiConfig config);
  void switchProvider(AiProviderType type);
  
  @override
  void dispose();
}
```

---

### AiConfig

Configuration model for AI services.

**Location:** `lib/shared/models/ai_config_model.dart`

```dart
enum AiProviderType {
  gemini,
  openai,
  anthropic,
}

class AiConfig {
  const AiConfig({
    this.defaultProvider = AiProviderType.gemini,
    this.apiKeys = const {},
    this.defaultModels = const {},
    this.providerSettings = const {},
  });
  
  final AiProviderType defaultProvider;
  final Map<String, String> apiKeys;
  final Map<String, String> defaultModels;
  final Map<String, dynamic> providerSettings;
  
  String? getApiKey(AiProviderType provider);
  String? getDefaultModel(AiProviderType provider);
  
  AiConfig copyWith({...});
  Map<String, dynamic> toJson();
  factory AiConfig.fromJson(Map<String, dynamic> json);
  
  static List<String> getModelsForProvider(AiProviderType provider);
}
```

#### Constructor

```dart
const AiConfig({
  AiProviderType defaultProvider = AiProviderType.gemini,
  Map<String, String> apiKeys = const {},
  Map<String, String> defaultModels = const {},
  Map<String, dynamic> providerSettings = const {},
})
```

#### Methods

##### getApiKey

```dart
String? getApiKey(AiProviderType provider)
```

Returns the API key for the specified provider.

##### getDefaultModel

```dart
String? getDefaultModel(AiProviderType provider)
```

Returns the default model ID for the specified provider.

##### getModelsForProvider (Static)

```dart
static List<String> getModelsForProvider(AiProviderType provider)
```

Returns list of supported models for a provider.

**Example:**
```dart
final config = AiConfig(
  defaultProvider: AiProviderType.gemini,
  apiKeys: {
    'gemini': 'your-gemini-key',
    'openai': 'your-openai-key',
  },
  defaultModels: {
    'gemini': 'gemini-1.5-pro',
    'openai': 'gpt-4o',
  },
);

final geminiKey = config.getApiKey(AiProviderType.gemini);
final models = AiConfig.getModelsForProvider(AiProviderType.openai);
```

---

## 2. Riverpod Providers

### AI Providers

**Location:** `lib/shared/providers/ai_providers.dart`

#### aiConfigProvider

```dart
final aiConfigProvider = Provider<AiConfig>((ref) {
  return const AiConfig();
});
```

Provides the AI configuration.

---

#### aiServiceProvider

```dart
final aiServiceProvider = StateNotifierProvider<AiServiceProvider, AiService?>((ref) {
  final config = ref.watch(aiConfigProvider);
  final notifier = AiServiceProvider();
  notifier.initialize(config);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});
```

Provides the initialized AiService instance.

---

#### currentAiProviderProvider

```dart
final currentAiProviderProvider = Provider<AiProvider?>((ref) {
  final service = ref.watch(aiServiceProvider);
  if (service == null) return null;
  return service.provider;
});
```

Provides the current active AI provider.

---

#### selectedProviderTypeProvider

```dart
final selectedProviderTypeProvider = StateProvider<AiProviderType>((ref) {
  final config = ref.watch(aiConfigProvider);
  return config.defaultProvider;
});
```

State provider for the currently selected provider type.

---

#### availableProvidersProvider

```dart
final availableProvidersProvider = Provider<List<AiProviderType>>((ref) {
  final service = ref.watch(aiServiceProvider);
  return service?.availableProviders ?? [];
});
```

Returns list of configured provider types.

---

#### providerAvailabilityProvider

```dart
final providerAvailabilityProvider = FutureProvider<Map<AiProviderType, bool>>((ref) async {
  final service = ref.watch(aiServiceProvider);
  if (service == null) return {};
  return await service.checkProviderAvailability();
});
```

Async provider checking availability of all providers.

---

#### aiServiceNotifierProvider

```dart
final aiServiceNotifierProvider = StateNotifierProvider<AiServiceNotifier, AsyncValue<AiService>>((ref) {
  final notifier = AiServiceNotifier(ref);
  notifier.initialize();
  return notifier;
});
```

StateNotifier for AI service with async state management.

**AiServiceNotifier Methods:**
```dart
class AiServiceNotifier extends StateNotifier<AsyncValue<AiService>> {
  Future<void> initialize();
  void switchProvider(AiProviderType type);
  Future<void> reinitializeWithConfig(AiConfig config);
}
```

---

#### AiConfigNotifier

```dart
class AiConfigNotifier extends StateNotifier<AiConfig> {
  void setDefaultProvider(AiProviderType provider);
  void setApiKey(AiProviderType provider, String apiKey);
  void setDefaultModel(AiProviderType provider, String model);
  void setProviderSetting(String key, dynamic value);
  void updateConfig(AiConfig newConfig);
  void clearApiKeys();
}

final aiConfigNotifierProvider = StateNotifierProvider<AiConfigNotifier, AiConfig>((ref) {
  return AiConfigNotifier();
});
```

**Example:**
```dart
// In a widget
final config = ref.watch(aiConfigNotifierProvider);
final notifier = ref.read(aiConfigNotifierProvider.notifier);

notifier.setApiKey(AiProviderType.gemini, 'new-api-key');
notifier.setDefaultModel(AiProviderType.gemini, 'gemini-1.5-pro');
```

---

### Auth Providers

**Location:** `lib/features/auth/domain/providers/auth_providers.dart`

#### authRepositoryProvider

```dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});
```

---

#### authStateChangesProvider

```dart
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});
```

Stream of Firebase auth state changes.

---

#### currentUserProvider

```dart
final currentUserProvider = Provider<UserEntity?>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return null;
  
  final isPremium = ref.watch(isPremiumUserProvider);
  
  return UserEntity(
    id: user.uid,
    email: user.email,
    displayName: user.displayName,
    photoUrl: user.photoURL,
    isAnonymous: user.isAnonymous,
    isPremium: isPremium,
    createdAt: user.metadata.creationTime ?? DateTime.now(),
  );
});
```

Provides the current user as a `UserEntity`.

---

#### isAuthenticatedProvider

```dart
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateChangesProvider).value != null;
});
```

Returns whether a user is currently authenticated.

---

#### authNotifierProvider

```dart
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  return AuthNotifier(ref);
});
```

StateNotifier for authentication operations.

**AuthNotifier Methods:**
```dart
class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> createUserWithEmailAndPassword(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<void> signInAnonymously();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> deleteAccount();
}
```

**Example:**
```dart
// Sign in
await ref.read(authNotifierProvider.notifier).signInWithEmailAndPassword(
  'user@example.com',
  'password',
);

// Check auth state
if (ref.watch(isAuthenticatedProvider)) {
  final user = ref.watch(currentUserProvider);
  print('Logged in as: ${user?.email}');
}

// Sign out
await ref.read(authNotifierProvider.notifier).signOut();
```

---

### Subscription Providers

**Location:** `lib/features/subscription/domain/providers/subscription_providers.dart`

#### subscriptionConfigProvider

```dart
final subscriptionConfigProvider = Provider<String>((ref) {
  const apiKey = String.fromEnvironment('REVENUECAT_API_KEY', defaultValue: '');
  return apiKey;
});
```

Provides RevenueCat API key from environment.

---

#### subscriptionRepositoryProvider

```dart
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final apiKey = ref.watch(subscriptionConfigProvider);
  return RevenueCatSubscriptionRepository(apiKey: apiKey);
});
```

---

#### subscriptionServiceProvider

```dart
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return SubscriptionService(repository: repository);
});
```

---

#### subscriptionScreenViewModelProvider

```dart
final subscriptionScreenViewModelProvider =
    StateNotifierProvider<SubscriptionScreenViewModel, SubscriptionScreenData>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return SubscriptionScreenViewModel(ref, service);
});
```

ViewModel for subscription screen with state management.

**SubscriptionScreenViewModel Methods:**
```dart
class SubscriptionScreenViewModel extends StateNotifier<SubscriptionScreenData> {
  void togglePlanType(bool isYearly);
  void selectPlan(SubscriptionPlan plan);
  Future<bool> purchaseSubscription();
  Future<bool> restorePurchases();
  Future<void> retry();
}
```

---

#### isPremiumUserProvider

```dart
final isPremiumUserProvider = Provider<bool>((ref) {
  final data = ref.watch(subscriptionScreenViewModelProvider);
  return data.isPremiumUser;
});
```

Returns whether the current user has premium access.

---

#### currentSubscriptionProvider

```dart
final currentSubscriptionProvider = FutureProvider<Subscription?>((ref) async {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getCurrentSubscription();
});
```

**Example:**
```dart
// Check premium status
if (ref.watch(isPremiumUserProvider)) {
  // Show premium features
}

// Purchase subscription
final success = await ref.read(subscriptionScreenViewModelProvider.notifier)
    .purchaseSubscription();

// Restore purchases
final restored = await ref.read(subscriptionScreenViewModelProvider.notifier)
    .restorePurchases();
```

---

### Persona Providers

**Location:** `lib/features/persona/domain/providers/persona_providers.dart`

#### personaRepositoryProvider

```dart
final personaRepositoryProvider = Provider<PersonaRepository>((ref) {
  return FirebasePersonaRepository();
});
```

---

#### personaServiceProvider

```dart
final personaServiceProvider = Provider<PersonaService?>((ref) {
  final repository = ref.watch(personaRepositoryProvider);
  final aiServiceAsync = ref.watch(aiServiceNotifierProvider);
  
  return aiServiceAsync.when(
    data: (aiService) => PersonaService(
      repository: repository,
      aiService: aiService,
    ),
    loading: () => null,
    error: (_, __) => null,
  );
});
```

---

#### personasProvider

```dart
final personasProvider = FutureProvider<List<Persona>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return Persona.defaultTemplates;
  }
  
  final service = ref.watch(personaServiceProvider);
  if (service == null) {
    return Persona.defaultTemplates;
  }
  return service.getUserPersonas(currentUser.id);
});
```

Returns all personas including user-created and default templates.

---

#### activePersonaProvider

```dart
final activePersonaProvider =
    StateNotifierProvider<ActivePersonaNotifier, Persona?>((ref) {
  return ActivePersonaNotifier(ref);
});
```

Manages the currently active persona.

**ActivePersonaNotifier Methods:**
```dart
class ActivePersonaNotifier extends StateNotifier<Persona?> {
  Future<void> setActivePersona(Persona persona);
  Future<void> clearActivePersona();
  Future<void> loadActivePersona(String userId);
}
```

---

#### defaultPersonasProvider

```dart
final defaultPersonasProvider = Provider<List<Persona>>((ref) {
  return Persona.defaultTemplates;
});
```

---

#### isPremiumPersonaProvider

```dart
final isPremiumPersonaProvider = Provider.family<bool, Persona>((ref, persona) {
  return persona.isPremium;
});
```

Family provider to check if a specific persona requires premium.

---

#### premiumPersonasProvider / freePersonasProvider

```dart
final premiumPersonasProvider = Provider<List<Persona>>((ref) {...});
final freePersonasProvider = Provider<List<Persona>>((ref) {...});
```

---

#### watchPersonasProvider / watchActivePersonaProvider

```dart
final watchPersonasProvider = StreamProvider<List<Persona>>((ref) {...});
final watchActivePersonaProvider = StreamProvider<Persona?>((ref) {...});
```

Stream providers for real-time persona updates.

**Example:**
```dart
// Get all personas
final personasAsync = ref.watch(personasProvider);
personasAsync.when(
  data: (personas) {
    for (final p in personas) {
      print('${p.name} - Premium: ${p.isPremium}');
    }
  },
  loading: () => showLoading(),
  error: (e, _) => showError(e),
);

// Set active persona
await ref.read(activePersonaProvider.notifier)
    .setActivePersona(Persona.corporateCounsel());

// Watch for changes
ref.listen<Persona?>(activePersonaProvider, (previous, next) {
  print('Persona changed from ${previous?.name} to ${next?.name}');
});
```

---

### Chat Providers

**Location:** `lib/features/chat/domain/providers/chat_providers.dart`

#### chatSessionProvider

```dart
final chatSessionProvider = StateNotifierProvider<ChatSessionNotifier, ChatSession>((ref) {
  return ChatSessionNotifier(ref);
});
```

**ChatSessionNotifier Methods:**
```dart
class ChatSessionNotifier extends StateNotifier<ChatSession> {
  void initializeSession({
    required String documentId,
    required String documentContext,
  });
  
  Future<void> sendMessage(String userMessage);
  void clearSession();
  void saveToHistory();
}
```

---

#### chatHistoryProvider

```dart
final chatHistoryProvider = StateProvider<List<ChatSession>>((ref) => []);
```

---

#### isAssistantTypingProvider

```dart
final isAssistantTypingProvider = StateProvider<bool>((ref) => false);
```

**Example:**
```dart
// Initialize chat session
ref.read(chatSessionProvider.notifier).initializeSession(
  documentId: 'doc-123',
  documentContext: documentText,
);

// Send message
await ref.read(chatSessionProvider.notifier).sendMessage(
  'What are the key obligations in this contract?',
);

// Watch typing state
final isTyping = ref.watch(isAssistantTypingProvider);

// Watch messages
final session = ref.watch(chatSessionProvider);
for (final msg in session.messages) {
  print('${msg.role}: ${msg.content}');
}
```

---

### Document Scan Providers

**Location:** `lib/features/document_scan/domain/providers/document_scan_providers.dart`

#### documentScanOcrServiceProvider

```dart
final documentScanOcrServiceProvider = Provider<OcrService>((ref) {
  return OcrService();
});
```

---

#### currentDocumentFileProvider

```dart
final currentDocumentFileProvider = StateProvider<File?>((ref) => null);
```

---

#### analysisStateProvider

```dart
final analysisStateProvider = StateNotifierProvider<AnalysisStateNotifier, AnalysisState>((ref) {
  return AnalysisStateNotifier(ref);
});
```

**AnalysisStateNotifier Methods:**
```dart
class AnalysisStateNotifier extends StateNotifier<AnalysisState> {
  Future<void> analyzeDocument(File document);
  Future<void> analyzeFromCamera();
  Future<void> analyzeFromGallery();
  void clearResult();
  void retry();
}
```

---

#### currentAnalysisResultProvider

```dart
final currentAnalysisResultProvider = Provider<AnalysisResult?>((ref) {
  final state = ref.watch(analysisStateProvider);
  return state.result;
});
```

---

#### processingStepProvider

```dart
final processingStepProvider = StateProvider<ProcessingStep>((ref) => ProcessingStep.idle);

enum ProcessingStep {
  idle,
  extractingText,
  analyzingDocument,
  detectingRedFlags,
  generatingSummary,
  completed,
  error,
}
```

---

#### analysisHistoryProvider

```dart
final analysisHistoryProvider = StateProvider<List<AnalysisResult>>((ref) => []);
```

**Example:**
```dart
// Start analysis
await ref.read(analysisStateProvider.notifier).analyzeDocument(file);

// Watch progress
final state = ref.watch(analysisStateProvider);
if (state.isProcessing) {
  print('Step: ${state.currentStep}');
  print('Progress: ${state.progress * 100}%');
}

// Get result
final result = ref.watch(currentAnalysisResultProvider);
if (result != null) {
  print('Summary: ${result.summary}');
  print('Red flags: ${result.redFlags.length}');
}
```

---

### TC Scanner Providers

**Location:** `lib/features/tc_scanner/domain/providers/tc_scanner_providers.dart`

#### tcDetectorServiceProvider

```dart
final tcDetectorServiceProvider = Provider<TcDetectorService>((ref) {
  final accessibilityService = NativeAccessibilityService();
  return TcDetectorService(accessibilityService);
});
```

---

#### isMonitoringProvider

```dart
final isMonitoringProvider = StateProvider<bool>((ref) => false);
```

---

#### tcDetectedProvider

```dart
final tcDetectedProvider = StateProvider<TcDetectionResult?>((ref) => null);
```

---

#### hasAccessibilityPermissionProvider

```dart
final hasAccessibilityPermissionProvider = FutureProvider<bool>((ref) async {
  final detector = ref.watch(tcDetectorServiceProvider);
  return await detector.hasAccessibilityPermission();
});
```

---

#### hasOverlayPermissionProvider

```dart
final hasOverlayPermissionProvider = FutureProvider<bool>((ref) async {
  final detector = ref.watch(tcDetectorServiceProvider);
  return await detector.hasOverlayPermission();
});
```

---

#### tcScannerNotifierProvider

```dart
final tcScannerNotifierProvider = StateNotifierProvider<TcScannerNotifier, TcScannerState>((ref) {
  return TcScannerNotifier(ref);
});
```

**TcScannerNotifier Methods:**
```dart
class TcScannerNotifier extends StateNotifier<TcScannerState> {
  Future<void> startScanning();
  Future<void> stopScanning();
  Future<void> analyzeDetectedContent();
  Future<void> showOverlay();
  Future<void> hideOverlay();
  void clearDetectedContent();
  void dismissError();
}
```

**Example:**
```dart
// Start monitoring
await ref.read(tcScannerNotifierProvider.notifier).startScanning();

// Watch for detections
ref.listen<TcScannerState>(tcScannerNotifierProvider, (prev, state) {
  if (state.detectedContent != null) {
    print('TC detected: ${state.detectedContent!.content}');
  }
});

// Analyze detected content
await ref.read(tcScannerNotifierProvider.notifier).analyzeDetectedContent();
```

---

## 3. Platform Channels

### NativeAccessibilityService

Cross-platform accessibility service for screen text extraction.

**Location:** `lib/core/platform_channels/accessibility_channel.dart`

```dart
class NativeAccessibilityService {
  Future<bool> enableAccessibilityService();
  Future<bool> hasAccessibilityPermission();
  Future<String?> extractScreenText();
  Future<void> showOverlay();
  Future<void> hideOverlay();
  Stream<String> get textStream;
  Stream<Map<String, dynamic>> get eventStream;
  Future<bool> isKeyboardEnabled();
  Future<void> openKeyboardSettings();
  Future<Map<String, dynamic>?> getKeyboardSharedData();
  Future<bool> hasOverlayPermission();
  Future<void> requestOverlayPermission();
  Future<void> openAccessibilitySettings();
  Future<bool> startMonitoring();
  Future<void> stopMonitoring();
  Future<String?> getForegroundWindowTitle();
  Stream<Map<String, dynamic>> get windowChangeStream;
  Stream<Map<String, dynamic>> get tcContentStream;
  
  WindowsAccessibilityChannel get windowsChannel;
  MacosAccessibilityChannel get macosChannel;
}
```

#### Methods

##### enableAccessibilityService

```dart
Future<bool> enableAccessibilityService()
```

Enables accessibility service for the current platform.

**Returns:** `Future<bool>` - Whether enabling was successful

**Platform Behavior:**
- **Android:** Invokes accessibility service enablement
- **iOS:** Opens keyboard settings for custom keyboard enablement
- **Windows:** Returns `true` (no setup required)
- **macOS:** Requests accessibility permission

---

##### hasAccessibilityPermission

```dart
Future<bool> hasAccessibilityPermission()
```

Checks if accessibility permissions are granted.

---

##### extractScreenText

```dart
Future<String?> extractScreenText()
```

Extracts text content from the current screen.

**Returns:** `Future<String?>` - Extracted text or null if unavailable

---

##### startMonitoring / stopMonitoring

```dart
Future<bool> startMonitoring()
Future<void> stopMonitoring()
```

Starts/stops window change monitoring (Windows/macOS only).

---

##### getForegroundWindowTitle

```dart
Future<String?> getForegroundWindowTitle()
```

Gets the title of the foreground window (Windows/macOS only).

---

##### Event Streams

```dart
Stream<String> get textStream        // Android: continuous text updates
Stream<Map<String, dynamic>> get eventStream  // Android: accessibility events
Stream<Map<String, dynamic>> get windowChangeStream  // Desktop: window changes
Stream<Map<String, dynamic>> get tcContentStream  // Desktop: detected TC content
```

**Example:**
```dart
final service = NativeAccessibilityService();

// Check permissions
if (!await service.hasAccessibilityPermission()) {
  await service.enableAccessibilityService();
}

// Extract text
final text = await service.extractScreenText();
print('Screen text: $text');

// Monitor window changes (desktop)
await service.startMonitoring();
service.windowChangeStream.listen((event) {
  print('Window changed: ${event['windowTitle']}');
});
```

---

### WindowsAccessibilityChannel

Windows-specific accessibility implementation.

**Location:** `lib/core/platform_channels/windows_accessibility_channel.dart`

```dart
class WindowsAccessibilityChannel {
  static final WindowsAccessibilityChannel _instance = WindowsAccessibilityChannel._internal();
  factory WindowsAccessibilityChannel() => _instance;
  
  Future<bool> isAvailable();
  Future<bool> startMonitoring();
  Future<void> stopMonitoring();
  Future<String?> getForegroundWindowTitle();
  Future<String?> extractScreenText();
  Future<bool> showOverlay({String? title, String? content});
  Future<void> hideOverlay();
  Stream<Map<String, dynamic>> get windowChangeStream;
  Stream<Map<String, dynamic>> get tcContentStream;
  Future<void> dispose();
}
```

**Channel Names:**
- Method Channel: `legalease_windows_accessibility`
- Event Channel: `legalease_windows_accessibility_events`

**Example:**
```dart
final channel = WindowsAccessibilityChannel();

if (await channel.isAvailable()) {
  await channel.startMonitoring();
  
  channel.windowChangeStream.listen((event) {
    final title = event['windowTitle'];
    final process = event['processName'];
    print('Active: $title ($process)');
  });
  
  channel.tcContentStream.listen((event) {
    final text = event['text'];
    print('TC Content: $text');
  });
}
```

---

### MacosAccessibilityChannel

macOS-specific accessibility implementation.

**Location:** `lib/core/platform_channels/macos_accessibility_channel.dart`

```dart
class MacosAccessibilityChannel {
  static final MacosAccessibilityChannel _instance = MacosAccessibilityChannel._internal();
  factory MacosAccessibilityChannel() => _instance;
  
  Future<bool> isAccessibilityEnabled();
  Future<bool> requestAccessibilityPermission();
  Future<String?> extractScreenText();
  Future<String?> getFocusedApplicationName();
  Future<bool> startMonitoring();
  Future<void> stopMonitoring();
  Stream<Map<String, dynamic>> get windowChangeStream;
  Stream<Map<String, dynamic>> get tcContentStream;
  Future<void> dispose();
}
```

**Channel Names:**
- Method Channel: `legalease_macos_accessibility`
- Event Channel: `legalease_macos_accessibility_events`

**Example:**
```dart
final channel = MacosAccessibilityChannel();

// Check and request permissions
if (!await channel.isAccessibilityEnabled()) {
  final granted = await channel.requestAccessibilityPermission();
  if (!granted) {
    print('Accessibility permission denied');
    return;
  }
}

// Extract text
final text = await channel.extractScreenText();

// Get focused app
final appName = await channel.getFocusedApplicationName();
print('Focused app: $appName');
```

---

### DesktopOverlayChannel

Desktop overlay window management.

**Location:** `lib/core/platform_channels/desktop_overlay_channel.dart`

```dart
class DesktopOverlayChannel {
  static final DesktopOverlayChannel _instance = DesktopOverlayChannel._internal();
  factory DesktopOverlayChannel() => _instance;
  
  Future<bool> showOverlay();
  Future<bool> hideOverlay();
  Future<bool> setPosition(double x, double y);
  Future<bool> setSize(double width, double height);
  Future<bool> setAlwaysOnTop(bool alwaysOnTop);
  Future<bool> minimize();
  Future<bool> expand();
  Future<bool> isOverlayVisible();
  Future<void> updateContent(String text);
  Future<Map<String, double>?> getPosition();
  Future<Map<String, double>?> getSize();
  Stream<Map<String, dynamic>> get selectionEventStream;
  Stream<Map<String, dynamic>> get clipboardEventStream;
  Future<void> dispose();
}
```

**Channel Names:**
- Method Channel: `legalease_desktop_overlay`
- Event Channel: `legalease_desktop_overlay_events`

#### Methods

##### setPosition / setSize

```dart
Future<bool> setPosition(double x, double y)
Future<bool> setSize(double width, double height)
```

Sets overlay position and size.

---

##### setAlwaysOnTop

```dart
Future<bool> setAlwaysOnTop(bool alwaysOnTop)
```

Toggles always-on-top behavior.

---

##### minimize / expand

```dart
Future<bool> minimize()
Future<bool> expand()
```

Minimizes or expands the overlay.

---

##### updateContent

```dart
Future<void> updateContent(String text)
```

Updates the overlay's text content.

---

##### Event Streams

```dart
Stream<Map<String, dynamic>> get selectionEventStream  // Text selection events
Stream<Map<String, dynamic>> get clipboardEventStream  // Clipboard events
```

**Example:**
```dart
final overlay = DesktopOverlayChannel();

// Show overlay
await overlay.showOverlay();
await overlay.setSize(400, 300);
await overlay.setPosition(100, 100);

// Update content
await overlay.updateContent('Analysis complete!');

// Watch for selections
overlay.selectionEventStream.listen((event) {
  final text = event['selectedText'];
  print('User selected: $text');
});

// Hide when done
await overlay.hideOverlay();
```

---

## 4. Document Scan Feature

### OcrService

OCR text extraction service using Google ML Kit.

**Location:** `lib/features/document_scan/data/services/ocr_service.dart`

```dart
class OcrService {
  OcrService();
  OcrService.withScript(TextRecognitionScript script);
  
  Future<OcrResultModel> extractTextFromImage(File imageFile);
  Future<List<OcrResultModel>> extractTextFromImages(List<File> images);
  Future<MultiPageOcrResult> extractTextFromImagesCombined(List<File> images);
  String preprocessText(String rawText);
  Future<void> close();
  void dispose();
}
```

#### Constructors

```dart
OcrService()  // Uses Latin script by default
OcrService.withScript(TextRecognitionScript script)  // Custom script
```

#### Methods

##### extractTextFromImage

```dart
Future<OcrResultModel> extractTextFromImage(File imageFile)
```

Extracts text from a single image.

| Parameter | Type | Description |
|-----------|------|-------------|
| `imageFile` | `File` | Image file to process |

**Returns:** `Future<OcrResultModel>` - OCR result with text and metadata

**Throws:** `StateError` if service is disposed

---

##### extractTextFromImages

```dart
Future<List<OcrResultModel>> extractTextFromImages(List<File> images)
```

Extracts text from multiple images.

---

##### extractTextFromImagesCombined

```dart
Future<MultiPageOcrResult> extractTextFromImagesCombined(List<File> images)
```

Extracts and combines text from multiple images.

---

##### preprocessText

```dart
String preprocessText(String rawText)
```

Cleans and normalizes OCR text:
- Normalizes line endings
- Removes excess whitespace
- Fixes hyphenated words broken across lines
- Trims output

**Example:**
```dart
final ocrService = OcrService();

// Single image
final result = await ocrService.extractTextFromImage(imageFile);
print('Text: ${result.text}');
print('Confidence: ${result.confidence}');
print('Word count: ${result.wordCount}');

// Multiple pages
final multiResult = await ocrService.extractTextFromImagesCombined(images);
print('Total pages: ${multiResult.totalPages}');
print('Combined text: ${multiResult.combinedText}');

// Clean up
await ocrService.close();
```

---

### DocumentProcessor

PDF processing and document structure analysis.

**Location:** `lib/features/document_scan/data/services/document_processor.dart`

```dart
class DocumentProcessor {
  Future<List<File>> pdfToImages(File pdfFile, {int dpi = 200});
  Future<List<File>> extractPdfPages(File pdfFile);
  DocumentType detectDocumentType(String text);
  Future<StructuredDocument> structureDocument(String rawText);
  Future<String> extractTextFromPdf(File pdfFile);
  bool isPdfFile(File file);
  bool isImageFile(File file);
  String cleanExtractedText(String text);
}
```

#### Constants

```dart
static const int _defaultDpi = 200;
static const int _maxPageCount = 50;
```

#### Methods

##### pdfToImages

```dart
Future<List<File>> pdfToImages(File pdfFile, {int dpi = 200})
```

Converts PDF pages to image files.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `pdfFile` | `File` | - | PDF file to convert |
| `dpi` | `int` | `200` | Resolution for rendering |

**Returns:** `Future<List<File>>` - List of image files (max 50 pages)

---

##### detectDocumentType

```dart
DocumentType detectDocumentType(String text)
```

Detects the type of legal document based on keyword scoring.

**Returns:** `DocumentType` - Detected type or `DocumentType.other`

---

##### structureDocument

```dart
Future<StructuredDocument> structureDocument(String rawText)
```

Extracts structure from document text including:
- Document type
- Title
- Sections with headings and content
- Metadata (dates, parties)

---

##### extractTextFromPdf

```dart
Future<String> extractTextFromPdf(File pdfFile)
```

Directly extracts text from PDF (no OCR).

---

##### isPdfFile / isImageFile

```dart
bool isPdfFile(File file)
bool isImageFile(File file)
```

Checks file type by extension.

**Example:**
```dart
final processor = DocumentProcessor();

// Process PDF
if (processor.isPdfFile(file)) {
  final pages = await processor.pdfToImages(file);
  final text = await processor.extractTextFromPdf(file);
}

// Detect document type
final docType = processor.detectDocumentType(text);
print('Type: ${docType.name}'); // e.g., 'contract', 'lease'

// Structure document
final structured = await processor.structureDocument(text);
print('Title: ${structured.title}');
for (final section in structured.sections) {
  print('Section: ${section.heading}');
}
```

---

### Analysis Models

#### OcrResultModel

**Location:** `lib/features/document_scan/data/models/ocr_result_model.dart`

```dart
class OcrResultModel {
  final String text;
  final List<OcrTextBlock> blocks;
  final Size imageSize;
  final Duration processingTime;
  final double confidence;
  final String? filePath;
  final int pageIndex;
  
  bool get isEmpty;
  bool get isNotEmpty;
  int get wordCount;
  int get characterCount;
  int get blockCount;
  String get preview;
  
  Map<String, dynamic> toJson();
  factory OcrResultModel.fromJson(Map<String, dynamic> json);
  OcrResultModel copyWith({...});
}
```

---

#### OcrTextBlock

```dart
class OcrTextBlock {
  final String text;
  final Rect boundingBox;
  final List<String> lines;
  final double confidence;
  
  Map<String, dynamic> toJson();
  factory OcrTextBlock.fromJson(Map<String, dynamic> json);
}
```

---

#### MultiPageOcrResult

```dart
class MultiPageOcrResult {
  final List<OcrResultModel> pages;
  final Duration totalProcessingTime;
  final double averageConfidence;
  
  String get combinedText;
  int get totalPages;
  int get totalWordCount;
  int get totalCharacterCount;
  bool get isEmpty;
  bool get isNotEmpty;
}
```

---

#### AnalysisResult

**Location:** `lib/features/document_scan/domain/models/analysis_result.dart`

```dart
enum AnalysisStatus { pending, processing, completed, failed }
enum RedFlagSeverity { critical, warning, info }
enum DocumentType {
  contract, lease, termsConditions, privacyPolicy, eula, nda, employment, other,
}

class AnalysisResult extends Equatable {
  final String documentId;
  final String originalText;
  final String plainEnglishTranslation;
  final String summary;
  final List<RedFlagItem> redFlags;
  final DocumentMetadata metadata;
  final AnalysisStatus status;
  final DateTime analyzedAt;
  final String? errorMessage;
  
  bool get isCompleted;
  bool get isFailed;
  bool get isProcessing;
  bool get isPending;
  bool get hasRedFlags;
  bool get hasCriticalFlags;
  bool get hasWarnings;
  int get criticalCount;
  int get warningCount;
  int get infoCount;
  
  Map<String, dynamic> toJson();
  factory AnalysisResult.fromJson(Map<String, dynamic> json);
  AnalysisResult copyWith({...});
}
```

---

#### RedFlagItem

```dart
class RedFlagItem extends Equatable {
  final String id;
  final String originalClause;
  final String explanation;
  final RedFlagSeverity severity;
  final int startIndex;
  final int endIndex;
  final double confidenceScore;
  
  bool get isCritical;
  bool get isWarning;
  bool get isInfo;
  int get length;
  String get severityLabel; // 'Critical', 'Warning', 'Info'
  ConfidenceLevel get confidenceLevel;
  String get confidenceLabel;
  
  factory RedFlagItem.fromRedFlag(Map<String, dynamic> json);
}
```

---

#### DocumentMetadata

```dart
class DocumentMetadata extends Equatable {
  final String? fileName;
  final int pageCount;
  final int wordCount;
  final int characterCount;
  final DocumentType type;
  final Duration processingTime;
  final double confidence;
  
  String get typeName;
  String get formattedProcessingTime;
}
```

---

### Document Scan Providers

See [Document Scan Providers](#document-scan-providers) section.

---

## 5. T&C Scanner Feature

### TcDetectorService

Service for detecting Terms & Conditions content on screen.

**Location:** `lib/features/tc_scanner/data/services/tc_detector_service.dart`

```dart
class TcDetectorService {
  TcDetectorService(NativeAccessibilityService accessibilityService);
  
  final List<String> tcKeywords;
  
  Future<void> startMonitoring();
  Stream<TcDetectionResult> get onTcDetected;
  Future<void> stopMonitoring();
  Future<void> showOverlay();
  Future<void> hideOverlay();
  Future<bool> hasAccessibilityPermission();
  Future<bool> hasOverlayPermission();
  void dispose();
}
```

#### Properties

```dart
final List<String> tcKeywords = [
  'terms and conditions',
  'terms of service',
  'terms of use',
  'privacy policy',
  'eula',
  'end user license agreement',
  'user agreement',
  'legal notice',
  'cookie policy',
  'data protection',
  'disclaimer',
];
```

#### Methods

##### startMonitoring

```dart
Future<void> startMonitoring()
```

Starts monitoring for T&C content. Platform-specific behavior:
- **Android:** Listens to text and event streams
- **Windows/macOS:** Starts window change monitoring

---

##### onTcDetected Stream

```dart
Stream<TcDetectionResult> get onTcDetected
```

Broadcast stream emitting detection results with 5-second cooldown.

---

##### stopMonitoring

```dart
Future<void> stopMonitoring()
```

Stops all monitoring subscriptions.

---

#### TcDetectionResult

```dart
class TcDetectionResult {
  final String content;
  final String? sourcePackage;
  final DateTime detectedAt;
  final String? windowTitle;
}
```

**Example:**
```dart
final detector = TcDetectorService(NativeAccessibilityService());

// Check permissions
if (!await detector.hasAccessibilityPermission()) {
  // Request permissions...
}

// Start monitoring
await detector.startMonitoring();

// Listen for detections
detector.onTcDetected.listen((result) {
  print('TC detected at ${result.detectedAt}');
  print('Content: ${result.content}');
  print('Source: ${result.sourcePackage ?? result.windowTitle}');
});

// Stop when done
await detector.stopMonitoring();
detector.dispose();
```

---

### TC Scanner Providers

See [TC Scanner Providers](#tc-scanner-providers) section.

---

## 6. Chat Feature

### ChatMessage

Message model for chat conversations.

**Location:** `lib/features/chat/domain/models/chat_message.dart`

```dart
enum MessageRole { user, assistant }

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isError;
  final bool isLoading;
  
  bool get isUser;
  bool get isAssistant;
  
  ChatMessage copyWith({...});
  Map<String, dynamic> toJson();
  factory ChatMessage.fromJson(Map<String, dynamic> json);
  
  factory ChatMessage.user(String content);
  factory ChatMessage.assistant(String content);
  factory ChatMessage.loading();
}
```

#### Factory Constructors

##### ChatMessage.user

```dart
factory ChatMessage.user(String content)
```

Creates a user message with auto-generated ID and timestamp.

---

##### ChatMessage.assistant

```dart
factory ChatMessage.assistant(String content)
```

Creates an assistant message with auto-generated ID and timestamp.

---

##### ChatMessage.loading

```dart
factory ChatMessage.loading()
```

Creates a loading placeholder message.

**Example:**
```dart
final userMsg = ChatMessage.user('What does this clause mean?');
final assistantMsg = ChatMessage.assistant('This clause indicates...');
final loadingMsg = ChatMessage.loading();

print(userMsg.isUser); // true
print(loadingMsg.isLoading); // true
```

---

### ChatSession

Session model for document-based chat.

```dart
class ChatSession extends Equatable {
  final String id;
  final String documentId;
  final String documentContext;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  
  int get messageCount;
  bool get isEmpty;
  bool get isNotEmpty;
  
  ChatSession copyWith({...});
}
```

**Example:**
```dart
final session = ChatSession(
  id: 'session-123',
  documentId: 'doc-456',
  documentContext: documentText,
  messages: [
    ChatMessage.user('Summarize this document'),
    ChatMessage.assistant('This document is a...'),
  ],
  createdAt: DateTime.now(),
);

print('Messages: ${session.messageCount}');
print('Last activity: ${session.lastMessageAt}');
```

---

### Chat Providers

See [Chat Providers](#chat-providers) section.

---

## 7. Persona Feature

### Persona Model

AI persona configuration model.

**Location:** `lib/shared/models/persona_model.dart`

```dart
enum PersonaTone {
  formal,
  casual,
  professional,
  friendly,
  assertive,
  diplomatic,
}

enum PersonaStyle {
  concise,
  detailed,
  technical,
  plainEnglish,
}

class Persona {
  final String id;
  final String? userId;
  final String name;
  final String description;
  final PersonaTone tone;
  final PersonaStyle style;
  final String language;
  final String systemPrompt;
  final bool isPremium;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  factory Persona.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  Persona copyWith({...});
  
  // Default persona factories
  factory Persona.corporateCounsel();
  factory Persona.friendlyAdvisor();
  factory Persona.assertiveAdvocate();
  factory Persona.technicalAnalyst();
  factory Persona.plainEnglishTranslator();
  
  static List<Persona> get defaultTemplates;
}
```

#### Default Personas

| Factory | Name | Tone | Style | Premium |
|---------|------|------|-------|---------|
| `corporateCounsel()` | Corporate Counsel | formal | detailed | Yes |
| `friendlyAdvisor()` | Friendly Advisor | friendly | plainEnglish | No |
| `assertiveAdvocate()` | Assertive Advocate | assertive | concise | Yes |
| `technicalAnalyst()` | Technical Analyst | formal | technical | Yes |
| `plainEnglishTranslator()` | Plain English Translator | friendly | plainEnglish | No |

**Example:**
```dart
// Use default persona
final persona = Persona.friendlyAdvisor();
print(persona.name); // 'Friendly Advisor'
print(persona.isPremium); // false

// Create custom persona
final custom = Persona(
  id: 'custom-1',
  name: 'My Custom Persona',
  description: 'A personalized legal advisor',
  tone: PersonaTone.professional,
  style: PersonaStyle.detailed,
  systemPrompt: 'You are a helpful legal assistant...',
  createdAt: DateTime.now(),
);

// Get all defaults
final defaults = Persona.defaultTemplates;
```

---

### PersonaRepository

Abstract repository interface for persona management.

**Location:** `lib/features/persona/domain/repositories/persona_repository.dart`

```dart
abstract class PersonaRepository {
  Future<List<Persona>> getPersonas(String userId);
  Future<Persona?> getPersona(String userId, String personaId);
  Future<Persona> createPersona(String userId, Persona persona);
  Future<Persona> updatePersona(String userId, Persona persona);
  Future<void> deletePersona(String userId, String personaId);
  Future<void> setActivePersona(String userId, String personaId);
  Future<Persona?> getActivePersona(String userId);
  Stream<Persona?> watchActivePersona(String userId);
  Future<void> clearActivePersona(String userId);
  Stream<List<Persona>> watchPersonas(String userId);
}

class PersonaException implements Exception {
  final String message;
  final String code;
}
```

---

### PersonaService

Service integrating personas with AI operations.

**Location:** `lib/features/persona/domain/services/persona_service.dart`

```dart
class PersonaService {
  PersonaService({
    required PersonaRepository repository,
    required AiService aiService,
  });
  
  Future<String> summarizeWithPersona(String documentText, Persona? persona);
  Future<String> translateWithPersona(String legaleseText, Persona? persona);
  Future<List<RedFlag>> detectRedFlagsWithPersona(String documentText, Persona? persona);
  Future<String> chatWithPersona({
    required String documentText,
    required String userQuery,
    Persona? persona,
    List<Map<String, String>>? history,
  });
  
  String buildPersonaPrompt(Persona persona);
  
  Future<List<Persona>> getUserPersonas(String userId);
  Future<Persona?> getActivePersonaWithFallback(String userId);
  Future<void> setActivePersona(String userId, String personaId);
  
  Future<Persona> createCustomPersona({
    required String userId,
    required String name,
    required String description,
    required String systemPrompt,
    PersonaTone tone = PersonaTone.professional,
    PersonaStyle style = PersonaStyle.detailed,
    String language = 'en',
    bool isPremium = false,
  });
  
  Future<Persona> updateCustomPersona(String userId, Persona persona);
  Future<void> deleteCustomPersona(String userId, String personaId);
  
  bool isPremiumPersona(Persona persona);
  List<Persona> getPremiumPersonas(List<Persona> personas);
  List<Persona> getFreePersonas(List<Persona> personas);
  
  Stream<Persona?> watchActivePersona(String userId);
}
```

#### Methods

##### buildPersonaPrompt

```dart
String buildPersonaPrompt(Persona persona)
```

Builds a comprehensive system prompt from persona configuration.

---

##### createCustomPersona

```dart
Future<Persona> createCustomPersona({
  required String userId,
  required String name,
  required String description,
  required String systemPrompt,
  PersonaTone tone = PersonaTone.professional,
  PersonaStyle style = PersonaStyle.detailed,
  String language = 'en',
  bool isPremium = false,
})
```

Creates a new custom persona for the user.

---

##### getActivePersonaWithFallback

```dart
Future<Persona?> getActivePersonaWithFallback(String userId)
```

Gets active persona, falling back to first default template if none set.

**Example:**
```dart
final service = PersonaService(repository: repo, aiService: ai);

// Summarize with persona
final summary = await service.summarizeWithPersona(
  documentText,
  Persona.corporateCounsel(),
);

// Create custom persona
final custom = await service.createCustomPersona(
  userId: 'user-123',
  name: 'Contract Specialist',
  description: 'Focuses on contract analysis',
  systemPrompt: 'You specialize in contract law...',
  tone: PersonaTone.formal,
  style: PersonaStyle.technical,
);

// Get all user personas
final personas = await service.getUserPersonas('user-123');
```

---

### Persona Providers

See [Persona Providers](#persona-providers) section.

---

## 8. Subscription Feature

### Subscription Models

**Location:** `lib/features/subscription/domain/models/subscription_models.dart`

#### SubscriptionTier

```dart
enum SubscriptionTier {
  free,
  premium,
}
```

---

#### SubscriptionStatus

```dart
enum SubscriptionStatus {
  inactive,
  active,
  expired,
  cancelled,
  inGracePeriod,
}
```

---

#### SubscriptionPlan

```dart
class SubscriptionPlan {
  final String id;
  final SubscriptionTier tier;
  final String name;
  final String description;
  final double price;
  final String currencyCode;
  final int durationMonths;
  final String productId;
  final bool isPopular;
  final List<String> features;
  
  factory SubscriptionPlan.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

---

#### Subscription

```dart
class Subscription {
  final String id;
  final String userId;
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final String planId;
  final String productId;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? cancelledAt;
  final bool willRenew;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  bool get isActive;  // status == active || status == inGracePeriod
  
  factory Subscription.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

---

#### SubscriptionOffering

```dart
class SubscriptionOffering {
  final String identifier;
  final String description;
  final SubscriptionPlan? monthlyPlan;
  final SubscriptionPlan? yearlyPlan;
  
  factory SubscriptionOffering.fromJson(Map<String, dynamic> json);
}
```

---

### SubscriptionRepository

Abstract repository for subscription operations.

**Location:** `lib/features/subscription/domain/repositories/subscription_repository.dart`

```dart
abstract class SubscriptionRepository {
  Stream<Subscription?> get subscriptionStream;
  Future<Subscription?> getCurrentSubscription();
  Future<List<SubscriptionPlan>> getAvailablePlans();
  Future<SubscriptionOffering?> getOfferings();
  Future<void> purchasePlan(String productId);
  Future<void> restorePurchases();
  Future<bool> isPremiumUser();
  Future<void> syncSubscriptionStatus();
}

class SubscriptionException implements Exception {
  final String message;
  final String code;
}
```

---

### SubscriptionService

High-level subscription management service.

**Location:** `lib/features/subscription/domain/services/subscription_service.dart`

```dart
class SubscriptionService {
  SubscriptionService({required SubscriptionRepository repository});
  
  Stream<SubscriptionStatus> get statusStream;
  
  Future<void> initialize(String revenueCatApiKey);
  Future<SubscriptionOffering?> getOfferings();
  Future<SubscriptionPurchaseResult> purchaseSubscription(SubscriptionPlan plan);
  Future<RestoreResult> restorePurchases();
  Future<bool> checkPremiumAccess();
  Future<void> handleDeepLink(String url);
  Future<Subscription?> getCurrentSubscription();
  Future<List<SubscriptionPlan>> getAvailablePlans();
  
  void dispose();
}
```

#### Result Types

##### SubscriptionPurchaseResult

```dart
class SubscriptionPurchaseResult {
  final bool success;
  final String? errorMessage;
  final String? errorCode;
  final Subscription? subscription;
  final bool userCancelled;
  
  factory SubscriptionPurchaseResult.success({Subscription? subscription});
  factory SubscriptionPurchaseResult.failure({...});
  factory SubscriptionPurchaseResult.cancelled();
}
```

---

##### RestoreResult

```dart
class RestoreResult {
  final bool success;
  final String? errorMessage;
  final List<Subscription> restoredSubscriptions;
  final bool hasRestoredPremium;
  
  factory RestoreResult.success({List<Subscription> restoredSubscriptions});
  factory RestoreResult.noPurchases();
  factory RestoreResult.failure({required String errorMessage});
}
```

**Example:**
```dart
final service = SubscriptionService(repository: repo);

// Initialize
await service.initialize('revenuecat-api-key');

// Watch status
service.statusStream.listen((status) {
  print('Subscription status: $status');
});

// Get offerings
final offering = await service.getOfferings();
if (offering?.yearlyPlan != null) {
  print('Yearly plan: ${offering!.yearlyPlan!.price}');
}

// Purchase
final result = await service.purchaseSubscription(plan);
if (result.success) {
  print('Purchased: ${result.subscription?.productId}');
} else if (result.userCancelled) {
  print('User cancelled');
} else {
  print('Error: ${result.errorMessage}');
}

// Restore
final restoreResult = await service.restorePurchases();
if (restoreResult.hasRestoredPremium) {
  print('Premium restored!');
}

// Check access
final hasPremium = await service.checkPremiumAccess();
```

---

### Subscription Providers

See [Subscription Providers](#subscription-providers) section.

---

## 9. Auth Feature

### UserEntity

User data model.

**Location:** `lib/features/auth/domain/entities/user_entity.dart`

```dart
class UserEntity {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;
  final bool isPremium;
  final DateTime createdAt;
  
  UserEntity copyWith({...});
  Map<String, dynamic> toJson();
  factory UserEntity.fromJson(Map<String, dynamic> json);
}
```

---

### AuthRepository

Abstract authentication repository.

**Location:** `lib/features/auth/data/repositories/auth_repository.dart`

```dart
abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  
  Future<UserCredential> signInWithEmailAndPassword(String email, String password);
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password);
  Future<UserCredential> signInWithGoogle();
  Future<UserCredential> signInWithApple();
  Future<UserCredential> signInAnonymously();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> deleteAccount();
}
```

---

### Auth Providers

See [Auth Providers](#auth-providers) section.

---

## 10. Shared Models

### DocumentModel

Core document model using Freezed.

**Location:** `lib/shared/models/document_model.dart`

```dart
enum DocumentType {
  contract,
  lease,
  termsConditions,
  privacyPolicy,
  eula,
  other,
}

@freezed
class DocumentModel with _$DocumentModel {
  const factory DocumentModel({
    required String id,
    required String userId,
    required String title,
    required DocumentType type,
    required String originalText,
    String? summary,
    List<RedFlag>? redFlags,
    String? plainEnglishTranslation,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _DocumentModel;
  
  factory DocumentModel.fromJson(Map<String, dynamic> json);
}
```

---

### RedFlag

Red flag model for document analysis.

```dart
@freezed
class RedFlag with _$RedFlag {
  const factory RedFlag({
    required String id,
    required String originalText,
    required String explanation,
    required String severity,
    required int startPosition,
    required int endPosition,
    @Default(0.8) double confidenceScore,
  }) = _RedFlag;
  
  factory RedFlag.fromJson(Map<String, dynamic> json);
}

// Extension for confidence level
extension RedFlagExtension on RedFlag {
  ConfidenceLevel get confidenceLevel {
    if (confidenceScore >= 0.85) return ConfidenceLevel.high;
    if (confidenceScore >= 0.65) return ConfidenceLevel.medium;
    return ConfidenceLevel.low;
  }
  
  String get confidenceLabel {
    switch (confidenceLevel) {
      case ConfidenceLevel.high: return 'High';
      case ConfidenceLevel.medium: return 'Medium';
      case ConfidenceLevel.low: return 'Low';
    }
  }
}

enum ConfidenceLevel {
  high,
  medium,
  low,
}
```

**Confidence Score Interpretation:**

| Score Range | Level | Interpretation |
|-------------|-------|----------------|
| 0.85 - 1.0 | High | Strong confidence in detection accuracy |
| 0.65 - 0.84 | Medium | Moderate confidence, recommend review |
| 0.0 - 0.64 | Low | Low confidence, may require manual verification |

---

## 11. Export Feature (v1.2.0)

### ExportService

Service for exporting document analyses to various formats.

**Location:** `lib/features/export/domain/services/export_service.dart`

```dart
class ExportService {
  Future<Uint8List> generatePdf(AnalysisResult result, {ExportOptions? options});
  Future<void> sharePdf(Uint8List pdfBytes, {String? subject});
  Future<void> savePdf(Uint8List pdfBytes, String fileName);
  Future<void> exportToCounsel({
    required AnalysisResult result,
    required String recipientEmail,
    String? customMessage,
  });
}

class ExportOptions {
  final bool includeSummary;
  final bool includeRedFlags;
  final bool includeTranslation;
  final bool includeOriginalText;
  final bool includeConfidenceScores;
  final bool includeSuggestedQuestions;
  
  const ExportOptions({
    this.includeSummary = true,
    this.includeRedFlags = true,
    this.includeTranslation = true,
    this.includeOriginalText = false,
    this.includeConfidenceScores = true,
    this.includeSuggestedQuestions = true,
  });
  
  static const ExportOptions full() => ExportOptions(includeOriginalText: true);
  static const ExportOptions summary() => ExportOptions(includeOriginalText: false);
}
```

#### Methods

##### generatePdf

```dart
Future<Uint8List> generatePdf(AnalysisResult result, {ExportOptions? options})
```

Generates a PDF from the analysis result with the specified options.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `result` | `AnalysisResult` | Yes | The analysis result to export |
| `options` | `ExportOptions?` | No | Export configuration (defaults to full) |

**Returns:** `Future<Uint8List>` - PDF file bytes

---

##### sharePdf

```dart
Future<void> sharePdf(Uint8List pdfBytes, {String? subject})
```

Shares the PDF using the system share sheet.

---

##### exportToCounsel

```dart
Future<void> exportToCounsel({
  required AnalysisResult result,
  required String recipientEmail,
  String? customMessage,
})
```

Opens email client with pre-formatted analysis for attorney review.

**Example:**
```dart
final exportService = ExportService();

// Generate PDF
final pdfBytes = await exportService.generatePdf(
  analysisResult,
  options: ExportOptions.full(),
);

// Share
await exportService.sharePdf(pdfBytes, subject: 'Legal Document Analysis');

// Export to counsel
await exportService.exportToCounsel(
  result: analysisResult,
  recipientEmail: 'attorney@lawfirm.com',
  customMessage: 'Please review this contract before signing.',
);
```

---

### Export Providers

**Location:** `lib/features/export/domain/providers/export_providers.dart`

#### exportServiceProvider

```dart
final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});
```

---

## 12. Legal Dictionary Feature (v1.2.0)

### LegalTerm

Legal terminology model.

**Location:** `lib/features/legal_dictionary/data/models/legal_term.dart`

```dart
enum LegalTermCategory {
  contracts,
  intellectualProperty,
  employment,
  realEstate,
  corporate,
  general,
}

enum TermRiskLevel {
  low,
  medium,
  high,
}

class LegalTerm extends Equatable {
  final String id;
  final String term;
  final String definition;
  final LegalTermCategory category;
  final String usage;
  final String example;
  final List<String> relatedTerms;
  final TermRiskLevel riskLevel;
  final bool isFavorite;
  
  String get categoryLabel;
  String get riskLevelLabel;
  
  factory LegalTerm.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  LegalTerm copyWith({...});
}
```

#### Category Labels

| Category | Label |
|----------|-------|
| `contracts` | Contracts |
| `intellectualProperty` | Intellectual Property |
| `employment` | Employment |
| `realEstate` | Real Estate |
| `corporate` | Corporate |
| `general` | General Legal |

---

### DictionaryService

Service for legal term lookup and management.

**Location:** `lib/features/legal_dictionary/domain/services/dictionary_service.dart`

```dart
class DictionaryService {
  Future<LegalTerm?> lookupTerm(String term);
  Future<List<LegalTerm>> searchTerms(String query);
  Future<List<LegalTerm>> getTermsByCategory(LegalTermCategory category);
  Future<List<LegalTerm>> getFavoriteTerms();
  Future<void> addToFavorites(String termId);
  Future<void> removeFromFavorites(String termId);
  Future<List<String>> getCategories();
  Future<LegalTerm?> getRandomTerm();
}
```

#### Methods

##### lookupTerm

```dart
Future<LegalTerm?> lookupTerm(String term)
```

Looks up a specific legal term by name.

---

##### searchTerms

```dart
Future<List<LegalTerm>> searchTerms(String query)
```

Searches for terms matching the query.

---

##### getTermsByCategory

```dart
Future<List<LegalTerm>> getTermsByCategory(LegalTermCategory category)
```

Gets all terms in a specific category.

**Example:**
```dart
final dictionary = DictionaryService();

// Look up a specific term
final indemnification = await dictionary.lookupTerm('indemnification');
print(indemnification?.definition);

// Search for terms
final results = await dictionary.searchTerms('liability');
for (final term in results) {
  print('${term.term}: ${term.definition}');
}

// Get by category
final contractTerms = await dictionary.getTermsByCategory(
  LegalTermCategory.contracts,
);

// Toggle favorite
await dictionary.addToFavorites('term-123');
final favorites = await dictionary.getFavoriteTerms();
```

---

### Dictionary Providers

**Location:** `lib/features/legal_dictionary/domain/providers/dictionary_providers.dart`

#### dictionaryServiceProvider

```dart
final dictionaryServiceProvider = Provider<DictionaryService>((ref) {
  return DictionaryService();
});
```

#### legalTermsByCategoryProvider

```dart
final legalTermsByCategoryProvider = FutureProvider.family<List<LegalTerm>, LegalTermCategory>((ref, category) async {
  final service = ref.watch(dictionaryServiceProvider);
  return service.getTermsByCategory(category);
});
```

#### favoriteTermsProvider

```dart
final favoriteTermsProvider = FutureProvider<List<LegalTerm>>((ref) async {
  final service = ref.watch(dictionaryServiceProvider);
  return service.getFavoriteTerms();
});
```

---

## 13. Reminders Feature (v1.2.0)

### Reminder

Contract deadline reminder model.

**Location:** `lib/features/reminders/data/models/reminder.dart`

```dart
enum ReminderType {
  contractExpiration,
  renewalDate,
  paymentDue,
  custom,
}

enum ReminderStatus {
  pending,
  notified,
  completed,
  dismissed,
}

class Reminder extends Equatable {
  final String id;
  final String userId;
  final String documentId;
  final String title;
  final String? description;
  final ReminderType type;
  final ReminderStatus status;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime? notifiedAt;
  final DateTime? completedAt;
  final List<int> notifyDaysBefore;
  final bool isRecurring;
  final int? recurringIntervalDays;
  
  bool get isOverdue;
  bool get isUpcoming;
  int get daysUntilDue;
  
  factory Reminder.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  Reminder copyWith({...});
}
```

---

### ReminderService

Service for managing contract deadline reminders.

**Location:** `lib/features/reminders/data/services/reminder_service.dart`

```dart
class ReminderService {
  Future<List<Reminder>> getReminders(String userId);
  Future<Reminder?> getReminder(String reminderId);
  Future<Reminder> createReminder({
    required String userId,
    required String documentId,
    required String title,
    String? description,
    required ReminderType type,
    required DateTime dueDate,
    List<int> notifyDaysBefore = const [1, 3, 7],
    bool isRecurring = false,
    int? recurringIntervalDays,
  });
  Future<Reminder> updateReminder(Reminder reminder);
  Future<void> deleteReminder(String reminderId);
  Future<void> markAsNotified(String reminderId);
  Future<void> markAsCompleted(String reminderId);
  Future<void> dismissReminder(String reminderId);
  Future<List<Reminder>> getUpcomingReminders(String userId, {int days = 30});
  Future<List<Reminder>> getOverdueReminders(String userId);
  Stream<List<Reminder>> watchReminders(String userId);
  
  Future<void> scheduleNotification(Reminder reminder);
  Future<void> cancelNotification(String reminderId);
}
```

#### Methods

##### createReminder

```dart
Future<Reminder> createReminder({
  required String userId,
  required String documentId,
  required String title,
  String? description,
  required ReminderType type,
  required DateTime dueDate,
  List<int> notifyDaysBefore = const [1, 3, 7],
  bool isRecurring = false,
  int? recurringIntervalDays,
})
```

Creates a new reminder with notification scheduling.

---

##### getUpcomingReminders

```dart
Future<List<Reminder>> getUpcomingReminders(String userId, {int days = 30})
```

Gets reminders due within the specified number of days.

---

##### watchReminders

```dart
Stream<List<Reminder>> watchReminders(String userId)
```

Real-time stream of user reminders.

**Example:**
```dart
final reminderService = ReminderService();

// Create reminder
final reminder = await reminderService.createReminder(
  userId: 'user-123',
  documentId: 'doc-456',
  title: 'Contract Renewal',
  description: 'Annual contract renewal deadline',
  type: ReminderType.renewalDate,
  dueDate: DateTime.now().add(Duration(days: 30)),
  notifyDaysBefore: [1, 7, 14],
);

// Watch reminders
reminderService.watchReminders('user-123').listen((reminders) {
  for (final r in reminders) {
    print('${r.title}: ${r.daysUntilDue} days');
  }
});

// Get upcoming
final upcoming = await reminderService.getUpcomingReminders('user-123');
```

---

### Reminder Providers

**Location:** `lib/features/reminders/domain/providers/reminder_providers.dart`

#### reminderServiceProvider

```dart
final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService();
});
```

#### remindersProvider

```dart
final remindersProvider = StreamProvider<List<Reminder>>((ref) {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return Stream.value([]);
  return ref.watch(reminderServiceProvider).watchReminders(userId);
});
```

#### upcomingRemindersProvider

```dart
final upcomingRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return [];
  return ref.watch(reminderServiceProvider).getUpcomingReminders(userId);
});
```

---

## 14. Voice Input Feature (v1.2.0)

### Voice Input Integration

Voice input is integrated into the chat feature using `speech_to_text`.

**Location:** `lib/features/chat/presentation/widgets/chat_input.dart`

```dart
class VoiceInputController {
  bool get isListening;
  bool get isAvailable;
  String get lastRecognizedWords;
  String get currentLocaleId;
  List<LocaleName> get locales;
  
  Future<void> initialize();
  Future<void> startListening({
    required void Function(String) onResult,
    void Function()? onSoundLevelChange,
    Duration listenFor = Duration.seconds(30),
    Duration pauseFor = Duration.seconds(3,
    String localeId = 'en_US',
  });
  Future<void> stopListening();
  Future<void> cancelListening();
  Future<List<LocaleName>> locales();
}
```

#### Usage in Chat

```dart
// In chat input widget
class ChatInput extends ConsumerStatefulWidget {
  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<ChatInput> {
  late final VoiceInputController _voiceController;
  bool _isVoiceMode = false;
  
  @override
  void initState() {
    super.initState();
    _voiceController = VoiceInputController();
    _voiceController.initialize();
  }
  
  Future<void> _startVoiceInput() async {
    setState(() => _isVoiceMode = true);
    await _voiceController.startListening(
      onResult: (text) {
        _textController.text = text;
      },
      pauseFor: Duration(seconds: 2),
    );
  }
  
  Future<void> _stopVoiceInput() async {
    await _voiceController.stopListening();
    setState(() => _isVoiceMode = false);
  }
}
```

---

## Cross-References

### Related APIs

| From | To | Relationship |
|------|-----|--------------|
| `AiService` | `AiProvider` | Uses providers |
| `AiService` | `AiConfig` | Uses configuration |
| `PersonaService` | `AiService` | Delegates AI calls |
| `PersonaService` | `PersonaRepository` | Uses repository |
| `SubscriptionService` | `SubscriptionRepository` | Uses repository |
| `TcDetectorService` | `NativeAccessibilityService` | Uses accessibility |
| `AnalysisStateNotifier` | `OcrService` | Uses OCR |
| `AnalysisStateNotifier` | `AiService` | Uses AI for analysis |
| `ChatSessionNotifier` | `AiService` | Uses AI for chat |
| `AuthNotifier` | `AuthRepository` | Uses repository |

### Feature Dependencies

```
Auth Feature
    └── Subscription Feature (isPremium status)

Persona Feature
    ├── Auth Feature (userId)
    ├── Subscription Feature (premium personas)
    └── AI Services (persona context)

Document Scan Feature
    └── AI Services (analysis)

TC Scanner Feature
    ├── Platform Channels (accessibility)
    └── AI Services (analysis)

Chat Feature
    ├── Document Scan Feature (document context)
    ├── AI Services (chat responses)
    └── Persona Feature (chat style)
```

---

## Error Handling

### Common Exceptions

| Exception | Source | Common Codes |
|-----------|--------|--------------|
| `StateError` | AiProvider | API key not configured, Service disposed |
| `Exception` | OpenAiProvider, AnthropicProvider | API errors |
| `SubscriptionException` | SubscriptionService | NOT_INITIALIZED, NETWORK_ERROR, PAYMENT_DECLINED |
| `PersonaException` | PersonaRepository | NOT_FOUND, UNAUTHORIZED |
| `PlatformException` | Platform Channels | Permission denied, Service unavailable |

### Best Practices

1. **Always check availability before AI operations:**
```dart
final isAvailable = await aiService.provider.isAvailable();
if (!isAvailable) {
  // Handle unavailable provider
}
```

2. **Check permissions before platform operations:**
```dart
if (!await accessibilityService.hasAccessibilityPermission()) {
  await accessibilityService.enableAccessibilityService();
}
```

3. **Handle async state with when:**
```dart
ref.watch(aiServiceNotifierProvider).when(
  data: (service) => /* use service */,
  loading: () => /* show loading */,
  error: (e, st) => /* show error */,
);
```

4. **Dispose services properly:**
```dart
@override
void dispose() {
  ocrService.close();
  aiService.dispose();
  super.dispose();
}
```

---

## Version

- API Version: 1.2.0
- Last Updated: 2026-02-25
- Flutter SDK: >=3.0.0
