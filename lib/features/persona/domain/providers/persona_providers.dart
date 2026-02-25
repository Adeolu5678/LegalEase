import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/shared/models/persona_model.dart';
import 'package:legalease/shared/providers/ai_providers.dart';
import 'package:legalease/features/persona/domain/repositories/persona_repository.dart';
import 'package:legalease/features/persona/data/repositories/firebase_persona_repository.dart';
import 'package:legalease/features/persona/domain/services/persona_service.dart';
import 'package:legalease/features/auth/domain/providers/auth_providers.dart';

/// Provider for the PersonaRepository implementation
final personaRepositoryProvider = Provider<PersonaRepository>((ref) {
  return FirebasePersonaRepository();
});

/// Provider for PersonaService instance
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

/// FutureProvider that loads all personas for the current user
/// Includes both user-created personas and default templates
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

/// StateNotifier for managing the currently selected/active persona
class ActivePersonaNotifier extends StateNotifier<Persona?> {
  final Ref _ref;

  ActivePersonaNotifier(this._ref) : super(null);

  /// Sets the active persona
  Future<void> setActivePersona(Persona persona) async {
    final currentUser = _ref.read(currentUserProvider);
    if (currentUser == null) return;

    final repository = _ref.read(personaRepositoryProvider);

    if (!persona.isDefault) {
      await repository.setActivePersona(currentUser.id, persona.id);
    }

    state = persona;
  }

  /// Clears the active persona selection
  Future<void> clearActivePersona() async {
    final currentUser = _ref.read(currentUserProvider);
    if (currentUser == null) return;

    final repository = _ref.read(personaRepositoryProvider);
    await repository.clearActivePersona(currentUser.id);

    state = null;
  }

  /// Loads the active persona for a given user from storage
  Future<void> loadActivePersona(String userId) async {
    final service = _ref.read(personaServiceProvider);
    if (service == null) {
      state = null;
      return;
    }
    final activePersona = await service.getActivePersonaWithFallback(userId);
    state = activePersona;
  }
}

/// Provider for the ActivePersonaNotifier
final activePersonaProvider =
    StateNotifierProvider<ActivePersonaNotifier, Persona?>((ref) {
  return ActivePersonaNotifier(ref);
});

/// Provider for built-in/default persona templates
final defaultPersonasProvider = Provider<List<Persona>>((ref) {
  return Persona.defaultTemplates;
});

/// Provider that checks if a persona requires premium subscription
/// Returns true if the persona is marked as premium
final isPremiumPersonaProvider = Provider.family<bool, Persona>((ref, persona) {
  return persona.isPremium;
});

/// Provider that filters personas by premium status
final premiumPersonasProvider = Provider<List<Persona>>((ref) {
  final personas = ref.watch(personasProvider);
  return personas.when(
    data: (list) => list.where((p) => p.isPremium).toList(),
    loading: () => [],
    error: (error, stack) => [],
  );
});

/// Provider that returns free (non-premium) personas
final freePersonasProvider = Provider<List<Persona>>((ref) {
  final personas = ref.watch(personasProvider);
  return personas.when(
    data: (list) => list.where((p) => !p.isPremium).toList(),
    loading: () => [],
    error: (error, stack) => [],
  );
});

/// Stream provider that watches personas for real-time updates
final watchPersonasProvider = StreamProvider<List<Persona>>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return Stream.value(Persona.defaultTemplates);
  }

  final repository = ref.watch(personaRepositoryProvider);
  return repository.watchPersonas(currentUser.id);
});

/// Stream provider that watches the active persona for real-time updates
final watchActivePersonaProvider = StreamProvider<Persona?>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) {
    return Stream.value(null);
  }

  final repository = ref.watch(personaRepositoryProvider);
  return repository.watchActivePersona(currentUser.id);
});
