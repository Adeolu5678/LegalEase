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

  const AiConfig({
    this.defaultProvider = AiProviderType.gemini,
    this.apiKeys = const {},
    this.defaultModels = const {},
    this.providerSettings = const {},
  });

  String? getApiKey(AiProviderType provider) {
    return apiKeys[provider.name];
  }

  String? getDefaultModel(AiProviderType provider) {
    return defaultModels[provider.name];
  }

  AiConfig copyWith({
    AiProviderType? defaultProvider,
    Map<String, String>? apiKeys,
    Map<String, String>? defaultModels,
    Map<String, dynamic>? providerSettings,
  }) {
    return AiConfig(
      defaultProvider: defaultProvider ?? this.defaultProvider,
      apiKeys: apiKeys ?? this.apiKeys,
      defaultModels: defaultModels ?? this.defaultModels,
      providerSettings: providerSettings ?? this.providerSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultProvider': defaultProvider.name,
      'apiKeys': apiKeys,
      'defaultModels': defaultModels,
      'providerSettings': providerSettings,
    };
  }

  factory AiConfig.fromJson(Map<String, dynamic> json) {
    return AiConfig(
      defaultProvider: AiProviderType.values.firstWhere(
        (e) => e.name == json['defaultProvider'],
        orElse: () => AiProviderType.gemini,
      ),
      apiKeys: Map<String, String>.from(json['apiKeys'] ?? {}),
      defaultModels: Map<String, String>.from(json['defaultModels'] ?? {}),
      providerSettings: Map<String, dynamic>.from(json['providerSettings'] ?? {}),
    );
  }

  static const geminiModels = [
    'gemini-pro',
    'gemini-pro-vision',
    'gemini-1.5-pro',
    'gemini-1.5-flash',
  ];

  static const openaiModels = [
    'gpt-4',
    'gpt-4-turbo',
    'gpt-4o',
    'gpt-3.5-turbo',
  ];

  static const anthropicModels = [
    'claude-3-opus-20240229',
    'claude-3-sonnet-20240229',
    'claude-3-haiku-20240307',
    'claude-3-5-sonnet-20241022',
  ];

  static List<String> getModelsForProvider(AiProviderType provider) {
    switch (provider) {
      case AiProviderType.gemini:
        return geminiModels;
      case AiProviderType.openai:
        return openaiModels;
      case AiProviderType.anthropic:
        return anthropicModels;
    }
  }
}
