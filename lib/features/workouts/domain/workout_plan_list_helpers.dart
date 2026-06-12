import '../../dashboard/domain/dashboard_snapshot.dart';
import '../data/workout_plan_api_model.dart';
import '../data/workout_plan_repository.dart';

enum WorkoutPlanSort {
  startDateDesc,
  startDateAsc,
  updatedDesc,
  updatedAsc,
  nameAsc,
  nameDesc,
}

enum WorkoutPlanFilter {
  all,
  active,
  scheduled,
  unscheduled,
  ended,
  stale,
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime startDateForPlan(WorkoutPlanApiModel plan) {
  try {
    final routine = planDataToRoutine(plan.planData);
    if (routine.startDate != null) {
      return _dateOnly(routine.startDate!);
    }
  } catch (_) {}
  return _dateOnly(plan.updatedAt);
}

DateTime? endDateForPlan(WorkoutPlanApiModel plan) {
  try {
    final routine = planDataToRoutine(plan.planData);
    if (routine.endDate != null) {
      return _dateOnly(routine.endDate!);
    }
  } catch (_) {}
  return null;
}

bool hasScheduledStart(WorkoutPlanApiModel plan) {
  try {
    return planDataToRoutine(plan.planData).startDate != null;
  } catch (_) {
    return false;
  }
}

bool isActivePlan(WorkoutPlanApiModel plan, {DateTime? now}) {
  if (!hasScheduledStart(plan)) return false;
  final today = _dateOnly(now ?? DateTime.now());
  final start = startDateForPlan(plan);
  if (today.isBefore(start)) return false;
  final end = endDateForPlan(plan);
  if (end == null) return true;
  return !today.isAfter(end);
}

bool isEndedPlan(WorkoutPlanApiModel plan, {DateTime? now}) {
  final end = endDateForPlan(plan);
  if (end == null) return false;
  final today = _dateOnly(now ?? DateTime.now());
  return today.isAfter(end);
}

bool isStalePlan(
  WorkoutPlanApiModel plan, {
  int staleDays = kStalePlanDays,
  DateTime? now,
}) {
  final today = _dateOnly(now ?? DateTime.now());
  final threshold = today.subtract(Duration(days: staleDays));
  final updatedDay = _dateOnly(plan.updatedAt);
  return updatedDay.isBefore(threshold);
}

bool matchesWorkoutPlanFilter(
  WorkoutPlanApiModel plan,
  WorkoutPlanFilter filter, {
  int staleDays = kStalePlanDays,
  DateTime? now,
}) {
  switch (filter) {
    case WorkoutPlanFilter.all:
      return true;
    case WorkoutPlanFilter.active:
      return isActivePlan(plan, now: now);
    case WorkoutPlanFilter.scheduled:
      return hasScheduledStart(plan);
    case WorkoutPlanFilter.unscheduled:
      return !hasScheduledStart(plan);
    case WorkoutPlanFilter.ended:
      return isEndedPlan(plan, now: now);
    case WorkoutPlanFilter.stale:
      return isStalePlan(plan, staleDays: staleDays, now: now);
  }
}

List<WorkoutPlanApiModel> filterWorkoutPlans(
  List<WorkoutPlanApiModel> plans,
  WorkoutPlanFilter filter, {
  int staleDays = kStalePlanDays,
  DateTime? now,
}) {
  if (filter == WorkoutPlanFilter.all) return List<WorkoutPlanApiModel>.from(plans);
  return plans
      .where((p) => matchesWorkoutPlanFilter(p, filter, staleDays: staleDays, now: now))
      .toList();
}

List<WorkoutPlanApiModel> searchWorkoutPlans(
  List<WorkoutPlanApiModel> plans,
  String query,
) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return List<WorkoutPlanApiModel>.from(plans);
  return plans.where((plan) {
    if (plan.name.toLowerCase().contains(q)) return true;
    if ((plan.phase ?? '').toLowerCase().contains(q)) return true;
    if ((plan.tags ?? '').toLowerCase().contains(q)) return true;
    if ((plan.theme ?? '').toLowerCase().contains(q)) return true;
    return false;
  }).toList();
}

int _comparePlans(
  WorkoutPlanApiModel a,
  WorkoutPlanApiModel b,
  WorkoutPlanSort sort,
) {
  switch (sort) {
    case WorkoutPlanSort.startDateDesc:
      return startDateForPlan(b).compareTo(startDateForPlan(a));
    case WorkoutPlanSort.startDateAsc:
      return startDateForPlan(a).compareTo(startDateForPlan(b));
    case WorkoutPlanSort.updatedDesc:
      return b.updatedAt.compareTo(a.updatedAt);
    case WorkoutPlanSort.updatedAsc:
      return a.updatedAt.compareTo(b.updatedAt);
    case WorkoutPlanSort.nameAsc:
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    case WorkoutPlanSort.nameDesc:
      return b.name.toLowerCase().compareTo(a.name.toLowerCase());
  }
}

List<WorkoutPlanApiModel> sortWorkoutPlans(
  List<WorkoutPlanApiModel> plans,
  WorkoutPlanSort sort,
) {
  final sorted = List<WorkoutPlanApiModel>.from(plans);
  sorted.sort((a, b) => _comparePlans(a, b, sort));
  return sorted;
}

List<WorkoutPlanApiModel> applyWorkoutPlanListQuery({
  required List<WorkoutPlanApiModel> plans,
  WorkoutPlanFilter filter = WorkoutPlanFilter.all,
  WorkoutPlanSort sort = WorkoutPlanSort.startDateDesc,
  String searchQuery = '',
  int staleDays = kStalePlanDays,
  DateTime? now,
}) {
  var result = filterWorkoutPlans(plans, filter, staleDays: staleDays, now: now);
  result = searchWorkoutPlans(result, searchQuery);
  return sortWorkoutPlans(result, sort);
}
