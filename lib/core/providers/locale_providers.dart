import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _localeKey = 'selected_locale';

class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs) : super(_loadLocale(_prefs));

  static Locale _loadLocale(SharedPreferences prefs) {
    final savedLocale = prefs.getString(_localeKey);
    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      if (parts.length == 1) {
        return Locale(parts[0]);
      } else if (parts.length >= 2) {
        return Locale(parts[0], parts[1]);
      }
    }
    return const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_localeKey, locale.toString());
    state = locale;
  }

  Future<void> resetToSystemDefault() async {
    await _prefs.remove(_localeKey);
    state = const Locale('en');
  }
}

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.when(
    data: (prefs) => LocaleNotifier(prefs),
    loading: () => LocaleNotifier(null as SharedPreferences),
    error: (_, __) => LocaleNotifier(null as SharedPreferences),
  );
});

final supportedLocalesProvider = Provider<List<Locale>>((ref) {
  return const [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('pt'),
  ];
});

final localeNameProvider = Provider.family<String, Locale>((ref, locale) {
  switch (locale.languageCode) {
    case 'en':
      return 'English';
    case 'es':
      return 'Español';
    case 'fr':
      return 'Français';
    case 'de':
      return 'Deutsch';
    case 'pt':
      return 'Português';
    default:
      return locale.languageCode.toUpperCase();
  }
});
