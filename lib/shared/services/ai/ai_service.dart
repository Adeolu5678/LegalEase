import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/shared/models/ai_config_model.dart';
import 'package:legalease/shared/models/document_model.dart';
import 'package:legalease/shared/models/persona_model.dart';
import 'package:legalease/shared/services/ai/ai_provider.dart';
import 'package:legalease/shared/services/ai/gemini_provider.dart';
import 'package:legalease/shared/services/ai/openai_provider.dart';
import 'package:legalease/shared/services/ai/anthropic_provider.dart';

class AiService {
  final AiConfig _config;
  final Map<AiProviderType, AiProvider> _providers;
  AiProvider? _currentProvider;

  AiService({
    required AiConfig config,
  })  : _config = config,
        _providers = {} {
    _initializeProviders();
  }

  void _initializeProviders() {
    final geminiKey = _config.getApiKey(AiProviderType.gemini);
    if (geminiKey != null && geminiKey.isNotEmpty) {
      _providers[AiProviderType.gemini] = GeminiProvider(
        apiKey: geminiKey,
        modelId: _config.getDefaultModel(AiProviderType.gemini) ?? 'gemini-pro',
      );
    }

    final openaiKey = _config.getApiKey(AiProviderType.openai);
    if (openaiKey != null && openaiKey.isNotEmpty) {
      _providers[AiProviderType.openai] = OpenAiProvider(
        apiKey: openaiKey,
        modelId: _config.getDefaultModel(AiProviderType.openai) ?? 'gpt-4-turbo',
      );
    }

    final anthropicKey = _config.getApiKey(AiProviderType.anthropic);
    if (anthropicKey != null && anthropicKey.isNotEmpty) {
      _providers[AiProviderType.anthropic] = AnthropicProvider(
        apiKey: anthropicKey,
        modelId: _config.getDefaultModel(AiProviderType.anthropic) ?? 'claude-3-sonnet-20240229',
      );
    }
  }

  AiProvider get provider {
    _currentProvider ??= getProvider(_config.defaultProvider);
    return _currentProvider!;
  }

  AiProvider getProvider(AiProviderType type) {
    final provider = _providers[type];
    if (provider == null) {
      throw StateError('AI provider $type is not configured. Please add an API key.');
    }
    return provider;
  }

  void setCurrentProvider(AiProviderType type) {
    _currentProvider = getProvider(type);
  }

  AiProviderType get currentProviderType {
    if (_currentProvider == null) return _config.defaultProvider;
    return _providers.entries
        .firstWhere((e) => e.value == _currentProvider,
            orElse: () => _providers.entries.first)
        .key;
  }

  List<AiProviderType> get availableProviders => _providers.keys.toList();

  bool isProviderConfigured(AiProviderType type) {
    return _providers.containsKey(type);
  }

  Future<Map<AiProviderType, bool>> checkProviderAvailability() async {
    final results = <AiProviderType, bool>{};
    for (final entry in _providers.entries) {
      results[entry.key] = await entry.value.isAvailable();
    }
    return results;
  }

  Future<String> summarizeDocument(String documentText, {Persona? persona}) async {
    return await provider.summarizeDocument(documentText, persona: persona);
  }

  Future<String> translateToPlainEnglish(String legaleseText, {Persona? persona}) async {
    return await provider.translateToPlainEnglish(legaleseText, persona: persona);
  }

  Future<List<RedFlag>> detectRedFlags(String documentText, {Persona? persona}) async {
    return await provider.detectRedFlags(documentText, persona: persona);
  }

  Future<String> chatWithContext({
    required String documentText,
    required String userQuery,
    List<Map<String, String>>? conversationHistory,
    Persona? persona,
  }) async {
    return await provider.chatWithContext(
      documentText: documentText,
      userQuery: userQuery,
      conversationHistory: conversationHistory,
      persona: persona,
    );
  }

  Future<String> generateText({
    required String prompt,
    String? persona,
    int? maxTokens,
  }) async {
    return await provider.generateText(
      prompt: prompt,
      persona: persona,
      maxTokens: maxTokens,
    );
  }

  Future<List<String>> getSuggestedQuestions({
    required String documentText,
    String? documentType,
    int maxQuestions = 5,
  }) async {
    return await provider.getSuggestedQuestions(
      documentText: documentText,
      documentType: documentType,
      maxQuestions: maxQuestions,
    );
  }

  void dispose() {
    for (final provider in _providers.values) {
      provider.dispose();
    }
    _providers.clear();
    _currentProvider = null;
  }
}

class AiServiceProvider extends StateNotifier<AiService?> {
  AiServiceProvider() : super(null);

  void initialize(AiConfig config) {
    state?.dispose();
    state = AiService(config: config);
  }

  void switchProvider(AiProviderType type) {
    state?.setCurrentProvider(type);
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}
