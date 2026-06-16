import 'dart:convert';

import '../data/workout_routine_model.dart';

/// Encodes [routine] as plan JSON, preserving lifecycle markers from [existingPlanData].
String encodeWorkoutRoutinePlanData(
  WorkoutRoutine routine, {
  String? existingPlanData,
}) {
  final encoded = Map<String, dynamic>.from(routine.toJson());
  if (existingPlanData != null && existingPlanData.isNotEmpty) {
    try {
      final existing = jsonDecode(existingPlanData) as Map<String, dynamic>;
      if (existing.containsKey('archivedAt')) {
        encoded['archivedAt'] = existing['archivedAt'];
      }
      if (existing.containsKey('completedAt')) {
        encoded['completedAt'] = existing['completedAt'];
      }
    } catch (_) {}
  }
  return jsonEncode(encoded);
}
