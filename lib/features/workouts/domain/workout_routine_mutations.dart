import '../data/workout_routine_model.dart';
import 'day_scheduled_weekday.dart';

Exercise cloneExerciseForWeekCopy(Exercise exercise, String newWeekId) {
  return exercise.copyWith(
    id: '${exercise.id}_$newWeekId',
    setDetails: exercise.setDetails
        ?.map(
          (s) => ExerciseSet(
            line: s.line,
            sets: s.sets,
            reps: s.reps,
            rpe: s.rpe,
            note: s.note,
          ),
        )
        .toList(),
  );
}

/// Appends a deep copy of [weekIndex] with [newWeekName] and [newWeekId].
/// Returns null when [weekIndex] is out of range.
WorkoutRoutine? cloneWeekInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required String newWeekName,
  required String newWeekId,
}) {
  if (weekIndex < 0 || weekIndex >= routine.weeks.length) return null;
  final source = routine.weeks[weekIndex];
  final newDays = source.days
      .map(
        (day) => Day(
          id: '${newWeekId}_d_${day.id}',
          name: day.name,
          exercises: day.exercises
              .map((e) => cloneExerciseForWeekCopy(e, newWeekId))
              .toList(),
          scheduledWeekday: day.scheduledWeekday,
        ),
      )
      .toList();
  final newWeek = Week(id: newWeekId, name: newWeekName, days: newDays);
  return routine.copyWith(weeks: [...routine.weeks, newWeek]);
}

WorkoutRoutine addWeekToRoutine({
  required WorkoutRoutine routine,
  required String weekId,
  required String weekName,
  required String firstDayId,
  required String firstDayName,
}) {
  return routine.copyWith(
    weeks: [
      ...routine.weeks,
      Week(
        id: weekId,
        name: weekName,
        days: [
          Day(
            id: firstDayId,
            name: firstDayName,
            exercises: const [],
            scheduledWeekday: inferredScheduledWeekday(0),
          ),
        ],
      ),
    ],
  );
}

WorkoutRoutine? deleteWeekFromRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
}) {
  if (weekIndex < 0 || weekIndex >= routine.weeks.length) return null;
  final weekId = routine.weeks[weekIndex].id;
  return routine.copyWith(
    weeks: routine.weeks.where((w) => w.id != weekId).toList(),
  );
}

/// Re-inserts [week] at [weekIndex] (for undo after delete week).
WorkoutRoutine? insertWeekAtIndexInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required Week week,
}) {
  if (weekIndex < 0 || weekIndex > routine.weeks.length) return null;
  final weeks = List<Week>.from(routine.weeks);
  weeks.insert(weekIndex, week);
  return routine.copyWith(weeks: weeks);
}

WorkoutRoutine? renameWeekInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required String newName,
}) {
  final trimmed = newName.trim();
  if (trimmed.isEmpty) return null;
  if (weekIndex < 0 || weekIndex >= routine.weeks.length) return null;
  final week = routine.weeks[weekIndex];
  final newWeeks = List<Week>.from(routine.weeks);
  newWeeks[weekIndex] = week.copyWith(name: trimmed);
  return routine.copyWith(weeks: newWeeks);
}

WorkoutRoutine? renameDayInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required String newName,
}) {
  final trimmed = newName.trim();
  if (trimmed.isEmpty) return null;
  if (weekIndex < 0 || weekIndex >= routine.weeks.length) return null;
  final week = routine.weeks[weekIndex];
  if (dayIndex < 0 || dayIndex >= week.days.length) return null;
  final day = week.days[dayIndex];
  final newDays = List<Day>.from(week.days);
  newDays[dayIndex] = day.copyWith(name: trimmed);
  final newWeeks = List<Week>.from(routine.weeks);
  newWeeks[weekIndex] = week.copyWith(days: newDays);
  return routine.copyWith(weeks: newWeeks);
}

/// Returns null when the last day would be removed.
WorkoutRoutine? deleteDayFromRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
}) {
  if (weekIndex < 0 || weekIndex >= routine.weeks.length) return null;
  final week = routine.weeks[weekIndex];
  if (dayIndex < 0 || dayIndex >= week.days.length) return null;
  if (week.days.length <= 1) return null;
  final newDays = week.days.where((d) => d.id != week.days[dayIndex].id).toList();
  final newWeeks = List<Week>.from(routine.weeks);
  newWeeks[weekIndex] = week.copyWith(days: newDays);
  return routine.copyWith(weeks: newWeeks);
}

WorkoutRoutine? addDayToWeekInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required String dayId,
  required String dayName,
}) {
  if (weekIndex < 0 || weekIndex >= routine.weeks.length) return null;
  final week = routine.weeks[weekIndex];
  final newDays = [
    ...week.days,
    Day(
      id: dayId,
      name: dayName,
      exercises: const [],
      scheduledWeekday: inferredScheduledWeekday(week.days.length),
    ),
  ];
  final newWeeks = List<Week>.from(routine.weeks);
  newWeeks[weekIndex] = week.copyWith(days: newDays);
  return routine.copyWith(weeks: newWeeks);
}

WorkoutRoutine? setDayScheduledWeekdayInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required int weekday,
}) {
  if (weekday < DateTime.monday || weekday > DateTime.sunday) return null;
  if (weekIndex < 0 || weekIndex >= routine.weeks.length) return null;
  final week = routine.weeks[weekIndex];
  if (dayIndex < 0 || dayIndex >= week.days.length) return null;
  final day = week.days[dayIndex];
  final newDays = List<Day>.from(week.days);
  newDays[dayIndex] = day.copyWith(scheduledWeekday: weekday);
  final newWeeks = List<Week>.from(routine.weeks);
  newWeeks[weekIndex] = week.copyWith(days: newDays);
  return routine.copyWith(weeks: newWeeks);
}

Exercise cloneExerciseForDayCopy(Exercise exercise, String idSuffix) {
  return exercise.copyWith(
    id: '${exercise.id}_$idSuffix',
    setDetails: exercise.setDetails
        ?.map(
          (s) => ExerciseSet(
            line: s.line,
            sets: s.sets,
            reps: s.reps,
            rpe: s.rpe,
            note: s.note,
          ),
        )
        .toList(),
  );
}

/// Replaces [targetDayIndex] exercises with a deep copy of [sourceDayIndex].
WorkoutRoutine? cloneDayToTargetInRoutine({
  required WorkoutRoutine routine,
  required int sourceWeekIndex,
  required int sourceDayIndex,
  required int targetWeekIndex,
  required int targetDayIndex,
}) {
  if (sourceWeekIndex < 0 || sourceWeekIndex >= routine.weeks.length) {
    return null;
  }
  if (targetWeekIndex < 0 || targetWeekIndex >= routine.weeks.length) {
    return null;
  }
  final sourceWeek = routine.weeks[sourceWeekIndex];
  final targetWeek = routine.weeks[targetWeekIndex];
  if (sourceDayIndex < 0 || sourceDayIndex >= sourceWeek.days.length) {
    return null;
  }
  if (targetDayIndex < 0 || targetDayIndex >= targetWeek.days.length) {
    return null;
  }
  if (sourceWeekIndex == targetWeekIndex && sourceDayIndex == targetDayIndex) {
    return null;
  }

  final sourceDay = sourceWeek.days[sourceDayIndex];
  final targetDay = targetWeek.days[targetDayIndex];
  final idSuffix = 'd${DateTime.now().millisecondsSinceEpoch}';
  final copiedExercises = sourceDay.exercises
      .map((e) => cloneExerciseForDayCopy(e, idSuffix))
      .toList();

  final newTargetDays = List<Day>.from(targetWeek.days);
  newTargetDays[targetDayIndex] = targetDay.copyWith(exercises: copiedExercises);
  final newWeeks = List<Week>.from(routine.weeks);
  newWeeks[targetWeekIndex] = targetWeek.copyWith(days: newTargetDays);
  return routine.copyWith(weeks: newWeeks);
}
