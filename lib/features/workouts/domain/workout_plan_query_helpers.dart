import 'dart:convert';

import '../../../core/constants/workout_plan_template_scope.dart';
import '../data/workout_plan_api_model.dart';
import '../data/workout_routine_model.dart';
import 'session_execution.dart';
import 'workout_routine_plan_encoder.dart';

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

String dateOnlyIso(DateTime value) => dateOnly(value).toIso8601String();

/// Sort key: top-level / routine `startDate`, else [updatedAt].
DateTime workoutPlanSortKey(WorkoutPlanApiModel plan) {
  if (plan.startDate != null) {
    return dateOnly(plan.startDate!);
  }
  try {
    final start = plan.routine.startDate;
    if (start != null) {
      return dateOnly(start);
    }
  } catch (_) {}
  return plan.updatedAt;
}

void sortWorkoutPlansByStartDateDesc(List<WorkoutPlanApiModel> plans) {
  plans.sort(
    (a, b) => workoutPlanSortKey(b).compareTo(workoutPlanSortKey(a)),
  );
}

List<WorkoutPlanApiModel> mapAndSortWorkoutPlans(
  Iterable<Map<String, dynamic>> payloads, {
  bool excludeTemplateScope = false,
}) {
  final models = payloads.map(WorkoutPlanApiModel.fromJson).toList();
  if (excludeTemplateScope) {
    models.removeWhere((p) => p.customerId == kWorkoutPlanTemplateScopeId);
  }
  sortWorkoutPlansByStartDateDesc(models);
  return models;
}

/// Deep-clone [planData] (JSON [String] or [Map]); strips plan-level markers.
///
/// Throws [FormatException] if [planData] cannot be normalized to an object.
String cloneWorkoutPlanDataJson(dynamic planData) {
  final decoded = normalizePlanDataToMap(planData);
  if (decoded == null) {
    throw const FormatException('invalid_workout_plan_data');
  }
  stripPlanLevelMarkersFromPlanData(decoded);
  return jsonEncode(decoded);
}

/// Parses a planData JSON string into [WorkoutRoutine].
///
/// Prefer [WorkoutPlanApiModel.routine] when a model is available.
WorkoutRoutine planDataToRoutine(String planDataJson) {
  final map = jsonDecode(planDataJson) as Map<String, dynamic>;
  return WorkoutRoutine.fromJson(map);
}

/// Sorts session executions newest-first by completion/session date.
List<SessionExecution> sortSessionExecutionsNewestFirst(
  Iterable<SessionExecution> executions,
) {
  final list = executions.toList();
  list.sort((a, b) {
    final aDate = a.completedAt ?? a.sessionDate;
    final bDate = b.completedAt ?? b.sessionDate;
    return bDate.compareTo(aDate);
  });
  return list;
}
