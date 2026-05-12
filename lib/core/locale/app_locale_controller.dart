import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../settings/settings_prefs_keys.dart';

class AppLocaleController extends ChangeNotifier {
  AppLocaleController._();

  static final AppLocaleController instance = AppLocaleController._();

  Locale _locale = const Locale('it');
  bool _loaded = false;

  Locale get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(SettingsPrefsKeys.appLocaleCode) ?? 'it';
    _locale = _normalizeLocale(code);
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    final next = _normalizeLocale(locale.languageCode);
    if (_locale == next && _loaded) return;
    _locale = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SettingsPrefsKeys.appLocaleCode, next.languageCode);
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
