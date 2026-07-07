import 'dart:convert';

import '../../../core/constants/workout_plan_template_scope.dart';
import '../data/workout_plan_api_model.dart';
import '../data/workout_routine_model.dart';
import 'session_execution.dart';

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

String dateOnlyIso(DateTime value) => dateOnly(value).toIso8601String();

/// Sort key: routine `startDate` from [WorkoutPlanApiModel.planData], else [updatedAt].
DateTime workoutPlanSortKey(WorkoutPlanApiModel plan) {
  try {
    final decoded = jsonDecode(plan.planData);
    if (decoded is Map<String, dynamic>) {
      final sd = decoded['startDate'];
      if (sd != null) {
        final d = DateTime.tryParse(sd.toString());
        if (d != null) {
          return dateOnly(d);
        }
      }
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

/// Deep-clone [planData] JSON string; throws [FormatException] if not valid JSON.
String cloneWorkoutPlanDataJson(String planData) {
  try {
    final decoded = jsonDecode(planData);
    if (decoded is Map<String, dynamic>) {
      decoded.remove('archivedAt');
      decoded.remove('completedAt');
      return jsonEncode(decoded);
    }
    return jsonEncode(decoded);
  } catch (_) {
    throw const FormatException('invalid_workout_plan_data');
  }
}

/// Parses [WorkoutPlanApiModel.planData] into [WorkoutRoutine].
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
