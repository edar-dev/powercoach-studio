import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/settings/settings_prefs_keys.dart';

/// Persists Hevy API key locally (coach account).
class HevySettingsStore {
  HevySettingsStore._();
  static final HevySettingsStore instance = HevySettingsStore._();

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(SettingsPrefsKeys.hevyApiKey)?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<void> setApiKey(String? key) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = key?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await prefs.remove(SettingsPrefsKeys.hevyApiKey);
    } else {
      await prefs.setString(SettingsPrefsKeys.hevyApiKey, trimmed);
    }
  }

  Future<bool> hasApiKey() async => (await getApiKey()) != null;
}
