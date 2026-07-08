import '../data/workout_plan_api_model.dart';
import '../data/workout_routine_model.dart';
import '../domain/day_scheduled_weekday.dart';
import '../domain/workout_plan_list_helpers.dart';
import '../domain/workout_plan_query_helpers.dart';

/// Week/day selection resolved from a deep-link query (`?week=&day=`).
class WorkoutBuilderWeekDaySelection {
  const WorkoutBuilderWeekDaySelection(this.weekIndex, this.dayIndex);

  final int weekIndex;
  final int dayIndex;

  @override
  bool operator ==(Object other) {
    return other is WorkoutBuilderWeekDaySelection &&
        other.weekIndex == weekIndex &&
        other.dayIndex == dayIndex;
  }

  @override
  int get hashCode => Object.hash(weekIndex, dayIndex);
}

/// Normalized plan payload for editor-mode initial render.
class WorkoutBuilderEditorPlanSnapshot {
  const WorkoutBuilderEditorPlanSnapshot({
    required this.routine,
    required this.weekIndex,
    required this.dayIndex,
    required this.planId,
    required this.initialWeekNumber,
    this.phase = '',
    this.tags = '',
    this.notes = '',
    required this.planCompleted,
    required this.planArchived,
  });

  final WorkoutRoutine routine;
  final int weekIndex;
  final int dayIndex;
  final String planId;
  final int initialWeekNumber;
  final String phase;
  final String tags;
  final String notes;
  final bool planCompleted;
  final bool planArchived;
}

/// Resolves deep-link week/day indices against [routine], or null when invalid.
WorkoutBuilderWeekDaySelection? resolveWorkoutBuilderDeepLinkSelection(
  WorkoutRoutine routine, {
  int? pendingWeekIndex,
  int? pendingDayIndex,
}) {
  final week = pendingWeekIndex;
  final day = pendingDayIndex;
  if (week == null || day == null) {
    return null;
  }
  if (week < 0 || week >= routine.weeks.length) {
    return null;
  }
  final days = routine.weeks[week].days;
  if (day < 0 || day >= days.length) {
    return WorkoutBuilderWeekDaySelection(week, 0);
  }
  return WorkoutBuilderWeekDaySelection(week, day);
}

WorkoutBuilderEditorPlanSnapshot buildEditorPlanSnapshot(
  WorkoutPlanApiModel plan, {
  int? pendingWeekIndex,
  int? pendingDayIndex,
}) {
  final routine = hydrateScheduledWeekdays(planDataToRoutine(plan.planData));
  final selection = resolveWorkoutBuilderDeepLinkSelection(
        routine,
        pendingWeekIndex: pendingWeekIndex,
        pendingDayIndex: pendingDayIndex,
      ) ??
      const WorkoutBuilderWeekDaySelection(0, 0);
  return WorkoutBuilderEditorPlanSnapshot(
    routine: routine,
    weekIndex: selection.weekIndex,
    dayIndex: selection.dayIndex,
    planId: plan.id,
    initialWeekNumber: plan.initialWeekNumber,
    phase: plan.phase ?? '',
    tags: plan.tags ?? '',
    notes: plan.notes ?? '',
    planCompleted: completedAtForPlan(plan) != null,
    planArchived: isArchivedPlan(plan),
  );
}
