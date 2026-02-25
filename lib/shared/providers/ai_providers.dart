import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/shared/models/ai_config_model.dart';
import 'package:legalease/shared/services/ai/ai_service.dart';
import 'package:legalease/shared/services/ai/ai_provider.dart';

final aiConfigProvider = Provider<AiConfig>((ref) {
  final geminiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final openaiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final anthropicKey = dotenv.env['ANTHROPIC_API_KEY'] ?? '';
  final defaultProviderStr = dotenv.env['DEFAULT_AI_PROVIDER'] ?? 'gemini';
  
  final defaultProvider = AiProviderType.values.firstWhere(
    (e) => e.name == defaultProviderStr.toLowerCase(),
    orElse: () => AiProviderType.gemini,
  );
  
  final apiKeys = <String, String>{};
  if (geminiKey.isNotEmpty) apiKeys['gemini'] = geminiKey;
  if (openaiKey.isNotEmpty) apiKeys['openai'] = openaiKey;
  if (anthropicKey.isNotEmpty) apiKeys['anthropic'] = anthropicKey;
  
  if (apiKeys.isEmpty) {
    debugPrint('[AiConfig] Warning: No API keys configured. Set keys in .env file.');
  }
  
  return AiConfig(
    defaultProvider: defaultProvider,
    apiKeys: apiKeys,
  );
});

final aiServiceProvider = StateNotifierProvider<AiServiceProvider, AiService?>((ref) {
  final config = ref.watch(aiConfigProvider);
  final notifier = AiServiceProvider();
  notifier.initialize(config);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

final currentAiProviderProvider = Provider<AiProvider?>((ref) {
  final service = ref.watch(aiServiceProvider);
  if (service == null) return null;
  
  ref.listen<AiService?>(aiServiceProvider, (_, service) {
    if (service != null) {
      ref.read(selectedProviderTypeProvider.notifier).state = service.currentProviderType;
    }
  });
  
  return service.provider;
});

final selectedProviderTypeProvider = StateProvider<AiProviderType>((ref) {
  final config = ref.watch(aiConfigProvider);
  return config.defaultProvider;
});

final availableProvidersProvider = Provider<List<AiProviderType>>((ref) {
  final service = ref.watch(aiServiceProvider);
  return service?.availableProviders ?? [];
});

final providerAvailabilityProvider = FutureProvider<Map<AiProviderType, bool>>((ref) async {
  final service = ref.watch(aiServiceProvider);
  if (service == null) return {};
  return await service.checkProviderAvailability();
});

final geminiProviderProvider = Provider<AiProvider?>((ref) {
  final service = ref.watch(aiServiceProvider);
  if (service == null || !service.isProviderConfigured(AiProviderType.gemini)) {
    return null;
  }
  return service.getProvider(AiProviderType.gemini);
});

final openAiProviderProvider = Provider<AiProvider?>((ref) {
  final service = ref.watch(aiServiceProvider);
  if (service == null || !service.isProviderConfigured(AiProviderType.openai)) {
    return null;
  }
  return service.getProvider(AiProviderType.openai);
});

final anthropicProviderProvider = Provider<AiProvider?>((ref) {
  final service = ref.watch(aiServiceProvider);
  if (service == null || !service.isProviderConfigured(AiProviderType.anthropic)) {
    return null;
  }
  return service.getProvider(AiProviderType.anthropic);
});

final aiProviderModelsProvider = Provider<List<String>>((ref) {
  final selectedType = ref.watch(selectedProviderTypeProvider);
  return AiConfig.getModelsForProvider(selectedType);
});

class AiConfigNotifier extends StateNotifier<AiConfig> {
  AiConfigNotifier() : super(const AiConfig());

  void setDefaultProvider(AiProviderType provider) {
    state = state.copyWith(defaultProvider: provider);
  }

  void setApiKey(AiProviderType provider, String apiKey) {
    final newApiKeys = Map<String, String>.from(state.apiKeys);
    newApiKeys[provider.name] = apiKey;
    state = state.copyWith(apiKeys: newApiKeys);
  }

  void setDefaultModel(AiProviderType provider, String model) {
    final newModels = Map<String, String>.from(state.defaultModels);
    newModels[provider.name] = model;
    state = state.copyWith(defaultModels: newModels);
  }

  void setProviderSetting(String key, dynamic value) {
    final newSettings = Map<String, dynamic>.from(state.providerSettings);
    newSettings[key] = value;
    state = state.copyWith(providerSettings: newSettings);
  }

  void updateConfig(AiConfig newConfig) {
    state = newConfig;
  }

  void clearApiKeys() {
    state = state.copyWith(apiKeys: {});
  }
}

final aiConfigNotifierProvider = StateNotifierProvider<AiConfigNotifier, AiConfig>((ref) {
  return AiConfigNotifier();
});

class AiServiceNotifier extends StateNotifier<AsyncValue<AiService>> {
  final Ref _ref;

  AiServiceNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> initialize() async {
    state = const AsyncValue.loading();
    try {
      final config = _ref.read(aiConfigNotifierProvider);
      final service = AiService(config: config);
      state = AsyncValue.data(service);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void switchProvider(AiProviderType type) {
    state.whenData((service) {
      service.setCurrentProvider(type);
      _ref.read(selectedProviderTypeProvider.notifier).state = type;
    });
  }

  Future<void> reinitializeWithConfig(AiConfig config) async {
    _ref.read(aiConfigNotifierProvider.notifier).updateConfig(config);
    await initialize();
  }
}

final aiServiceNotifierProvider = StateNotifierProvider.autoDispose<AiServiceNotifier, AsyncValue<AiService>>((ref) {
  final notifier = AiServiceNotifier(ref);
  notifier.initialize();
  return notifier;
});
