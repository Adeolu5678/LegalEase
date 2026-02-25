import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/persona/domain/providers/persona_providers.dart';
import 'package:legalease/features/subscription/domain/providers/subscription_providers.dart';
import 'package:legalease/shared/models/persona_model.dart';

enum SettingsScreenStatus {
  initial,
  loading,
  loaded,
  error,
}

class SettingsScreenState {
  final SettingsScreenStatus status;
  final List<Persona> personas;
  final Persona? activePersona;
  final String? errorMessage;
  final bool isPremiumUser;

  const SettingsScreenState({
    this.status = SettingsScreenStatus.initial,
    this.personas = const [],
    this.activePersona,
    this.errorMessage,
    this.isPremiumUser = false,
  });

  SettingsScreenState copyWith({
    SettingsScreenStatus? status,
    List<Persona>? personas,
    Persona? activePersona,
    String? errorMessage,
    bool? isPremiumUser,
  }) {
    return SettingsScreenState(
      status: status ?? this.status,
      personas: personas ?? this.personas,
      activePersona: activePersona ?? this.activePersona,
      errorMessage: errorMessage,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
    );
  }

  List<Persona> get defaultPersonas => personas.where((p) => p.isDefault).toList();
  List<Persona> get customPersonas => personas.where((p) => !p.isDefault).toList();
}

class SettingsScreenViewModel extends StateNotifier<SettingsScreenState> {
  final Ref _ref;

  SettingsScreenViewModel(this._ref) : super(const SettingsScreenState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(status: SettingsScreenStatus.loading);

    try {
      final personasAsync = _ref.read(personasProvider);
      final activePersona = _ref.read(activePersonaProvider);

      personasAsync.when(
        data: (personas) {
          state = state.copyWith(
            status: SettingsScreenStatus.loaded,
            personas: personas,
            activePersona: activePersona,
          );
        },
        loading: () {
          state = state.copyWith(status: SettingsScreenStatus.loading);
        },
        error: (error, stack) {
          state = state.copyWith(
            status: SettingsScreenStatus.error,
            errorMessage: error.toString(),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: SettingsScreenStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> setActivePersona(Persona persona) async {
    if (persona.isPremium && !state.isPremiumUser) {
      return;
    }

    await _ref.read(activePersonaProvider.notifier).setActivePersona(persona);
    state = state.copyWith(activePersona: persona);
  }

  Future<void> refresh() async {
    _ref.invalidate(personasProvider);
    await _loadData();
  }

  void setPremiumUser(bool isPremium) {
    state = state.copyWith(isPremiumUser: isPremium);
  }
}

final settingsScreenViewModelProvider =
    StateNotifierProvider<SettingsScreenViewModel, SettingsScreenState>((ref) {
  final isPremium = ref.watch(isPremiumUserProvider);
  return SettingsScreenViewModel(ref)..setPremiumUser(isPremium);
});
