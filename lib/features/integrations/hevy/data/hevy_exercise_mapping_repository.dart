import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/settings/settings_prefs_keys.dart';

/// Manual PowerCoach exercise → Hevy template id overrides.
class HevyExerciseMappingRepository {
  Future<Map<String, String>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(SettingsPrefsKeys.hevyExerciseMappingsJson);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return {};
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveMapping(String powercoachKey, String hevyTemplateId) async {
    final all = await loadAll();
    all[powercoachKey] = hevyTemplateId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SettingsPrefsKeys.hevyExerciseMappingsJson, jsonEncode(all));
  }

  Future<void> saveAll(Map<String, String> mappings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SettingsPrefsKeys.hevyExerciseMappingsJson, jsonEncode(mappings));
  }
}
