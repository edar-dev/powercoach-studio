import 'package:shared_preferences/shared_preferences.dart';

import '../settings/settings_prefs_keys.dart';

/// User decision for web product analytics + session replay.
enum AnalyticsConsent {
  granted,
  denied,
}

/// Persists analytics consent (SharedPreferences → localStorage on web).
class AnalyticsConsentStore {
  AnalyticsConsentStore._();

  static final AnalyticsConsentStore instance = AnalyticsConsentStore._();

  static const _grantedValue = 'granted';
  static const _deniedValue = 'denied';

  /// `null` when the user has not chosen yet.
  Future<AnalyticsConsent?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(SettingsPrefsKeys.analyticsConsent)?.trim();
    return switch (raw) {
      _grantedValue => AnalyticsConsent.granted,
      _deniedValue => AnalyticsConsent.denied,
      _ => null,
    };
  }

  Future<void> set(AnalyticsConsent consent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      SettingsPrefsKeys.analyticsConsent,
      consent == AnalyticsConsent.granted ? _grantedValue : _deniedValue,
    );
  }

  /// Test-only: clear stored decision.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SettingsPrefsKeys.analyticsConsent);
  }
}
