import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/shared/models/ai_config_model.dart';
import 'package:legalease/shared/services/ai/ai_provider.dart';
import 'package:legalease/shared/services/ai/ai_service.dart';
import 'package:legalease/shared/providers/ai_providers.dart';
import 'package:legalease/features/auth/data/repositories/auth_repository.dart';
import 'package:legalease/features/auth/domain/providers/auth_providers.dart';
import 'package:legalease/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:legalease/features/subscription/domain/providers/subscription_providers.dart';
import 'package:legalease/features/persona/domain/repositories/persona_repository.dart';
import 'package:legalease/features/persona/domain/providers/persona_providers.dart';

class TestOverrides {
  static Override aiProviderOverride(AiProvider mockProvider) {
    return currentAiProviderProvider.overrideWith((ref) => mockProvider);
  }

  static Override authRepositoryOverride(AuthRepository mockRepo) {
    return authRepositoryProvider.overrideWith((ref) => mockRepo);
  }

  static Override subscriptionRepositoryOverride(SubscriptionRepository mockRepo) {
    return subscriptionRepositoryProvider.overrideWith((ref) => mockRepo);
  }

  static Override personaRepositoryOverride(PersonaRepository mockRepo) {
    return personaRepositoryProvider.overrideWith((ref) => mockRepo);
  }
}

AiConfig createTestAiConfig({
  String geminiKey = 'test-gemini-key',
  String openaiKey = 'test-openai-key',
  String anthropicKey = 'test-anthropic-key',
  AiProviderType defaultProvider = AiProviderType.gemini,
}) {
  return AiConfig(
    defaultProvider: defaultProvider,
    apiKeys: {
      'gemini': geminiKey,
      'openai': openaiKey,
      'anthropic': anthropicKey,
    },
    defaultModels: {
      'gemini': 'gemini-pro',
      'openai': 'gpt-4-turbo',
      'anthropic': 'claude-3-sonnet-20240229',
    },
  );
}

final testAiServiceProvider = Provider<AiService>((ref) {
  final config = createTestAiConfig();
  return AiService(config: config);
});

final testAiConfigProvider = Provider<AiConfig>((ref) {
  return createTestAiConfig();
});

final testAiServiceProviderOverride = aiServiceProvider.overrideWith((ref) {
  final config = ref.watch(testAiConfigProvider);
  final notifier = AiServiceProvider();
  notifier.initialize(config);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});
