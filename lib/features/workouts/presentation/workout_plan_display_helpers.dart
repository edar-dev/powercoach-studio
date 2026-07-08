import '../../../l10n/app_localizations.dart';
import '../domain/workout_plan_list_helpers.dart';

String formatPlanUpdatedAt(AppLocalizations l10n, DateTime updatedAt) {
  final now = DateTime.now();
  final diff = now.difference(updatedAt);
  if (diff.inDays > 0) return l10n.updatedDaysAgo(diff.inDays);
  if (diff.inHours > 0) return l10n.updatedHoursAgo(diff.inHours);
  if (diff.inMinutes > 0) return l10n.updatedMinutesAgo(diff.inMinutes);
  return l10n.updatedJustNow;
}

String workoutPlanFilterLabel(AppLocalizations l10n, WorkoutPlanFilter filter) {
  switch (filter) {
    case WorkoutPlanFilter.all:
      return l10n.customerWorkoutsFilterAll;
    case WorkoutPlanFilter.active:
      return l10n.customerWorkoutsFilterActive;
    case WorkoutPlanFilter.archived:
      return l10n.customerWorkoutsFilterArchived;
    case WorkoutPlanFilter.scheduled:
      return l10n.customerWorkoutsFilterScheduled;
    case WorkoutPlanFilter.unscheduled:
      return l10n.customerWorkoutsFilterUnscheduled;
    case WorkoutPlanFilter.ended:
      return l10n.customerWorkoutsFilterEnded;
    case WorkoutPlanFilter.stale:
      return l10n.customerWorkoutsFilterStale;
  }
}

String workoutPlanSortLabel(AppLocalizations l10n, WorkoutPlanSort sort) {
  switch (sort) {
    case WorkoutPlanSort.startDateDesc:
      return l10n.customerWorkoutsSortStartDateDesc;
    case WorkoutPlanSort.startDateAsc:
      return l10n.customerWorkoutsSortStartDateAsc;
    case WorkoutPlanSort.updatedDesc:
      return l10n.customerWorkoutsSortUpdatedDesc;
    case WorkoutPlanSort.updatedAsc:
      return l10n.customerWorkoutsSortUpdatedAsc;
    case WorkoutPlanSort.nameAsc:
      return l10n.customerWorkoutsSortNameAsc;
    case WorkoutPlanSort.nameDesc:
      return l10n.customerWorkoutsSortNameDesc;
  }
}
