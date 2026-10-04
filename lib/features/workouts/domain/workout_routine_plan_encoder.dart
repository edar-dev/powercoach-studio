import 'dart:convert';

import '../data/workout_routine_model.dart';

/// Plan-level markers that persist as top-level workoutPlan payload fields.
///
/// Kept out of the nested [planData] blob on write; legacy reads may still
/// find them inside planData until the next rewrite.
const kWorkoutPlanLevelMarkerKeys = <String>[
  'archivedAt',
  'completedAt',
  'startDate',
  'endDate',
  'currentWeek',
];

/// Removes plan-level lifecycle/schedule keys from a mutable planData map.
void stripPlanLevelMarkersFromPlanData(Map<String, dynamic> planData) {
  for (final key in kWorkoutPlanLevelMarkerKeys) {
    planData.remove(key);
  }
}

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

/// Builds planData as a nested JSON [Map] without plan-level markers.
///
/// Lifecycle/schedule markers are written at the entity payload top level by
/// [WorkoutPlanRepository]. [existingPlanData] is retained for call-site
/// compatibility and is ignored (markers are no longer merged into the blob).
Map<String, dynamic> buildWorkoutRoutinePlanData(
  WorkoutRoutine routine, {
  // Retained for call-site compatibility; no longer merged into planData.
  dynamic existingPlanData,
}) {
  final encoded = Map<String, dynamic>.from(routine.toJson());
  stripPlanLevelMarkersFromPlanData(encoded);
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
