import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/settings/settings_prefs_keys.dart';

class PinnedExercisesStore {
  PinnedExercisesStore._();

  static final PinnedExercisesStore instance = PinnedExercisesStore._();

  Future<Set<String>> getPinnedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(SettingsPrefsKeys.pinnedExerciseIdsJson);
    if (raw == null || raw.isEmpty) return <String>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <String>{};
      return decoded
          .map((e) => e?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> toggle(String exerciseId) async {
    if (exerciseId.trim().isEmpty) return;
    final ids = await getPinnedIds();
    if (!ids.remove(exerciseId)) {
      ids.add(exerciseId);
    }
    await _save(ids);
  }

  Future<void> _save(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      SettingsPrefsKeys.pinnedExerciseIdsJson,
      jsonEncode(ids.toList()),
    );
  }
}
