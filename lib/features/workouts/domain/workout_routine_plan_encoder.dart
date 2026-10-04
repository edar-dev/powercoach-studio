import 'dart:convert';

import '../data/workout_routine_model.dart';

/// Normalizes [raw] planData (JSON [String] or [Map]) into a mutable map.
///
/// Returns `null` when [raw] is null, empty, invalid JSON, or not an object.
Map<String, dynamic>? normalizePlanDataToMap(dynamic raw) {
  if (raw == null) return null;
  if (raw is Map) {
    return Map<String, dynamic>.from(raw);
  }
  if (raw is String) {
    if (raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
  return null;
}

/// Builds planData as a nested JSON [Map], preserving lifecycle markers from
/// [existingPlanData] (legacy JSON [String] or already-normalized [Map]).
Map<String, dynamic> buildWorkoutRoutinePlanData(
  WorkoutRoutine routine, {
  dynamic existingPlanData,
}) {
  final encoded = Map<String, dynamic>.from(routine.toJson());
  final existing = normalizePlanDataToMap(existingPlanData);
  if (existing != null) {
    if (existing.containsKey('archivedAt')) {
      encoded['archivedAt'] = existing['archivedAt'];
    }
    if (existing.containsKey('completedAt')) {
      encoded['completedAt'] = existing['completedAt'];
    }
  }
  return encoded;
}

/// Encodes [routine] as a planData JSON string (legacy callers / tests).
///
/// Prefer [buildWorkoutRoutinePlanData] for entity payload writes.
String encodeWorkoutRoutinePlanData(
  WorkoutRoutine routine, {
  dynamic existingPlanData,
}) {
  return jsonEncode(
    buildWorkoutRoutinePlanData(routine, existingPlanData: existingPlanData),
  );
}
