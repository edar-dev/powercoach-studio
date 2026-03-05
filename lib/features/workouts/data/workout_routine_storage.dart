import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'workout_routine_model.dart';

const String _keyRoutine = 'workout_routine_draft';

/// Persists [WorkoutRoutine] as JSON in SharedPreferences.
class WorkoutRoutineStorage {
  static Future<WorkoutRoutine> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyRoutine);
    if (jsonStr == null || jsonStr.isEmpty) {
      return WorkoutRoutine(
        name: 'Hypertrophy Phase 1',
        mobilityItems: WorkoutRoutine.defaultMobilityItems(),
        weeks: WorkoutRoutine.defaultWeeks(),
      );
    }
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return WorkoutRoutine.fromJson(map);
    } catch (_) {
      return WorkoutRoutine(
        name: 'Hypertrophy Phase 1',
        mobilityItems: WorkoutRoutine.defaultMobilityItems(),
        weeks: WorkoutRoutine.defaultWeeks(),
      );
    }
  }

  static Future<void> save(WorkoutRoutine routine) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRoutine, jsonEncode(routine.toJson()));
  }
}
