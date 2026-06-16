import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/settings/settings_prefs_keys.dart';

class RecentExercisesStore {
  RecentExercisesStore._();

  static final RecentExercisesStore instance = RecentExercisesStore._();
  static const int maxEntries = 20;

  Future<List<String>> getRecentIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(SettingsPrefsKeys.recentExerciseIdsJson);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .map((e) => e?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> recordUse(String exerciseId) async {
    if (exerciseId.trim().isEmpty) return;
    final ids = List<String>.from(await getRecentIds());
    ids.remove(exerciseId);
    ids.insert(0, exerciseId);
    if (ids.length > maxEntries) {
      ids.removeRange(maxEntries, ids.length);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      SettingsPrefsKeys.recentExerciseIdsJson,
      jsonEncode(ids),
    );
  }
}
