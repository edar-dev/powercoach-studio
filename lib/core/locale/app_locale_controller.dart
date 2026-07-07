import 'package:flutter/material.dart';

import '../../features/settings/data/user_preferences_repository.dart';

class AppLocaleController extends ChangeNotifier {
  AppLocaleController._();

  static final AppLocaleController instance = AppLocaleController._();

  final UserPreferencesRepository _preferences =
      UserPreferencesRepository.instance;

  Locale _locale = const Locale('it');
  bool _loaded = false;

  Locale get locale => _locale;

  Future<void> load() async {
    final code = await _preferences.getLocaleCode();
    _locale = _normalizeLocale(code);
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    final next = _normalizeLocale(locale.languageCode);
    if (_locale == next && _loaded) return;
    _locale = next;
    await _preferences.setLocaleCode(next.languageCode);
    _loaded = true;
    notifyListeners();
  }

  Locale _normalizeLocale(String? code) {
    switch (code) {
      case 'en':
        return const Locale('en');
      case 'it':
      default:
        return const Locale('it');
    }
  }
}
