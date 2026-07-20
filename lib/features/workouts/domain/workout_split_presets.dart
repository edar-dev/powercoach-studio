import '../data/workout_routine_model.dart';
import 'day_scheduled_weekday.dart';

/// Common training split templates for the new-plan wizard.
enum WorkoutSplitPreset {
  fullBody,
  upperLower,
  pushPullLegs,
}

/// Builds an empty [WorkoutRoutine] skeleton with named weeks and days.
WorkoutRoutine buildWorkoutRoutineSkeleton({
  required String planName,
  required int weekCount,
  required int daysPerWeek,
  required WorkoutSplitPreset preset,
}) {
  final trimmedName = planName.trim();
  final base = WorkoutRoutine.empty().copyWith(
    name: trimmedName,
  );

  final weeks = <Week>[];
  for (var weekIndex = 0; weekIndex < weekCount; weekIndex++) {
    final weekId = 'w_${weekIndex + 1}';
    final dayNames = _dayNamesForPreset(
      preset: preset,
      daysPerWeek: daysPerWeek,
      weekIndex: weekIndex,
    );
    final days = <Day>[];
    for (var dayIndex = 0; dayIndex < daysPerWeek; dayIndex++) {
      days.add(
        Day(
          id: '${weekId}_d${dayIndex + 1}',
          name: dayNames[dayIndex],
          exercises: const [],
          scheduledWeekday: inferredScheduledWeekday(dayIndex),
        ),
      );
    }
    weeks.add(
      Week(
        id: weekId,
        name: 'Settimana ${weekIndex + 1}',
        days: days,
      ),
    );
  }

  return base.copyWith(weeks: weeks);
}

List<String> _dayNamesForPreset({
  required WorkoutSplitPreset preset,
  required int daysPerWeek,
  required int weekIndex,
}) {
  return switch (preset) {
    WorkoutSplitPreset.fullBody => List.generate(
      daysPerWeek,
      (index) => 'Full body ${String.fromCharCode(65 + (index % 26))}',
    ),
    WorkoutSplitPreset.upperLower => List.generate(
      daysPerWeek,
      (index) => index.isEven ? 'Upper' : 'Lower',
    ),
    WorkoutSplitPreset.pushPullLegs => List.generate(
      daysPerWeek,
      (index) {
        final cycle = ['Push', 'Pull', 'Legs'];
        return '${cycle[index % 3]} ${weekIndex + 1}';
      },
    ),
  };
}
