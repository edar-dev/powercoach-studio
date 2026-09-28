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

Week _cloneWeekDeep(Week source, {required String newWeekId, required String newWeekName}) {
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
  return Week(id: newWeekId, name: newWeekName, days: newDays);
}

Phase _clonePhaseDeep(Phase source, {required String newPhaseId}) {
  final newWeeks = <Week>[];
  for (var i = 0; i < source.weeks.length; i++) {
    final week = source.weeks[i];
    final weekId = '${newPhaseId}_w${i + 1}';
    newWeeks.add(
      _cloneWeekDeep(
        week,
        newWeekId: weekId,
        newWeekName: week.name,
      ),
    );
  }
  return Phase(
    id: newPhaseId,
    name: source.name,
    objective: source.objective,
    weeks: newWeeks,
  );
}

/// Ensures [routine] has at least one phase; creates default General if empty.
WorkoutRoutine ensureDefaultPhase(WorkoutRoutine routine) {
  if (routine.phases.isNotEmpty) return routine;
  return routine.copyWith(phases: [WorkoutRoutine.defaultPhase()]);
}

/// Appends a deep copy of [weekIndex] (global) into the same phase.
/// Returns null when [weekIndex] is out of range.
WorkoutRoutine? cloneWeekInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required String newWeekName,
  required String newWeekId,
}) {
  final loc = routine.locateWeek(weekIndex);
  if (loc == null) return null;
  final phase = routine.phases[loc.phaseIndex];
  final source = phase.weeks[loc.weekIndexInPhase];
  final newWeek = _cloneWeekDeep(
    source,
    newWeekId: newWeekId,
    newWeekName: newWeekName,
  );
  return routine.replacePhaseWeeks(
    loc.phaseIndex,
    [...phase.weeks, newWeek],
  );
}

/// Appends a week to [phaseIndex] (defaults to last phase, creating one if needed).
WorkoutRoutine addWeekToRoutine({
  required WorkoutRoutine routine,
  required String weekId,
  required String weekName,
  required String firstDayId,
  required String firstDayName,
  int? phaseIndex,
}) {
  var next = ensureDefaultPhase(routine);
  final targetPhase = phaseIndex ?? (next.phases.length - 1);
  if (targetPhase < 0 || targetPhase >= next.phases.length) {
    return next;
  }
  final phase = next.phases[targetPhase];
  final week = Week(
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
  );
  return next.replacePhaseWeeks(targetPhase, [...phase.weeks, week])!;
}

WorkoutRoutine? deleteWeekFromRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
}) {
  final loc = routine.locateWeek(weekIndex);
  if (loc == null) return null;
  final phase = routine.phases[loc.phaseIndex];
  final weekId = phase.weeks[loc.weekIndexInPhase].id;
  final updated = routine.replacePhaseWeeks(
    loc.phaseIndex,
    phase.weeks.where((w) => w.id != weekId).toList(),
  );
  if (updated == null) return null;
  return updated.remapSessionWeekIndices(
    (old) => old == weekIndex ? null : (old > weekIndex ? old - 1 : old),
  );
}

/// Re-inserts [week] at global [weekIndex] (for undo after delete week).
WorkoutRoutine? insertWeekAtIndexInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required Week week,
}) {
  final flatCount = routine.weeks.length;
  if (weekIndex < 0 || weekIndex > flatCount) return null;

  if (routine.phases.isEmpty) {
    return routine.copyWith(
      phases: [WorkoutRoutine.defaultPhase(weeks: [week])],
    );
  }

  if (weekIndex == flatCount) {
    // Append to last phase — no index shift for existing weeks.
    final last = routine.phases.length - 1;
    final phase = routine.phases[last];
    return routine.replacePhaseWeeks(last, [...phase.weeks, week]);
  }

  final loc = routine.locateWeek(weekIndex);
  if (loc == null) return null;
  final phase = routine.phases[loc.phaseIndex];
  final weeks = List<Week>.from(phase.weeks);
  weeks.insert(loc.weekIndexInPhase, week);
  final updated = routine.replacePhaseWeeks(loc.phaseIndex, weeks);
  if (updated == null) return null;
  return updated.remapSessionWeekIndices(
    (old) => old >= weekIndex ? old + 1 : old,
  );
}

WorkoutRoutine? renameWeekInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required String newName,
}) {
  final trimmed = newName.trim();
  if (trimmed.isEmpty) return null;
  final loc = routine.locateWeek(weekIndex);
  if (loc == null) return null;
  final phase = routine.phases[loc.phaseIndex];
  final week = phase.weeks[loc.weekIndexInPhase];
  return routine.replaceWeekAt(
    weekIndex,
    week.copyWith(name: trimmed),
  );
}

WorkoutRoutine? renameDayInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required String newName,
}) {
  final trimmed = newName.trim();
  if (trimmed.isEmpty) return null;
  final loc = routine.locateWeek(weekIndex);
  if (loc == null) return null;
  final week = routine.phases[loc.phaseIndex].weeks[loc.weekIndexInPhase];
  if (dayIndex < 0 || dayIndex >= week.days.length) return null;
  final day = week.days[dayIndex];
  final newDays = List<Day>.from(week.days);
  newDays[dayIndex] = day.copyWith(name: trimmed);
  return routine.replaceWeekAt(weekIndex, week.copyWith(days: newDays));
}

/// Returns null when the last day would be removed.
WorkoutRoutine? deleteDayFromRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
}) {
  final loc = routine.locateWeek(weekIndex);
  if (loc == null) return null;
  final week = routine.phases[loc.phaseIndex].weeks[loc.weekIndexInPhase];
  if (dayIndex < 0 || dayIndex >= week.days.length) return null;
  if (week.days.length <= 1) return null;
  final newDays =
      week.days.where((d) => d.id != week.days[dayIndex].id).toList();
  return routine.replaceWeekAt(weekIndex, week.copyWith(days: newDays));
}

WorkoutRoutine? addDayToWeekInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required String dayId,
  required String dayName,
}) {
  final loc = routine.locateWeek(weekIndex);
  if (loc == null) return null;
  final week = routine.phases[loc.phaseIndex].weeks[loc.weekIndexInPhase];
  final newDays = [
    ...week.days,
    Day(
      id: dayId,
      name: dayName,
      exercises: const [],
      scheduledWeekday: inferredScheduledWeekday(week.days.length),
    ),
  ];
  return routine.replaceWeekAt(weekIndex, week.copyWith(days: newDays));
}

WorkoutRoutine? setDayScheduledWeekdayInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required int weekday,
}) {
  if (weekday < DateTime.monday || weekday > DateTime.sunday) return null;
  final loc = routine.locateWeek(weekIndex);
  if (loc == null) return null;
  final week = routine.phases[loc.phaseIndex].weeks[loc.weekIndexInPhase];
  if (dayIndex < 0 || dayIndex >= week.days.length) return null;
  final day = week.days[dayIndex];
  final newDays = List<Day>.from(week.days);
  newDays[dayIndex] = day.copyWith(scheduledWeekday: weekday);
  return routine.replaceWeekAt(weekIndex, week.copyWith(days: newDays));
}

/// Clears [Day.scheduledWeekday] so the day is flexible (athlete-chosen).
WorkoutRoutine? clearDayScheduledWeekdayInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
}) {
  final loc = routine.locateWeek(weekIndex);
  if (loc == null) return null;
  final week = routine.phases[loc.phaseIndex].weeks[loc.weekIndexInPhase];
  if (dayIndex < 0 || dayIndex >= week.days.length) return null;
  final day = week.days[dayIndex];
  final newDays = List<Day>.from(week.days);
  newDays[dayIndex] = day.copyWith(clearScheduledWeekday: true);
  return routine.replaceWeekAt(weekIndex, week.copyWith(days: newDays));
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
  final sourceLoc = routine.locateWeek(sourceWeekIndex);
  final targetLoc = routine.locateWeek(targetWeekIndex);
  if (sourceLoc == null || targetLoc == null) return null;
  final sourceWeek =
      routine.phases[sourceLoc.phaseIndex].weeks[sourceLoc.weekIndexInPhase];
  final targetWeek =
      routine.phases[targetLoc.phaseIndex].weeks[targetLoc.weekIndexInPhase];
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
  newTargetDays[targetDayIndex] = targetDay.copyWith(
    exercises: copiedExercises,
  );
  return routine.replaceWeekAt(
    targetWeekIndex,
    targetWeek.copyWith(days: newTargetDays),
  );
}

// --- Phase CRUD ---

WorkoutRoutine addPhaseToRoutine({
  required WorkoutRoutine routine,
  required String phaseId,
  required String phaseName,
  String? objective,
  List<Week>? weeks,
}) {
  final phase = Phase(
    id: phaseId,
    name: phaseName.trim().isEmpty ? kDefaultPhaseName : phaseName.trim(),
    objective: objective?.trim().isEmpty == true ? null : objective?.trim(),
    weeks: weeks ?? const [],
  );
  return routine.copyWith(phases: [...routine.phases, phase]);
}

WorkoutRoutine? renamePhaseInRoutine({
  required WorkoutRoutine routine,
  required int phaseIndex,
  required String newName,
}) {
  final trimmed = newName.trim();
  if (trimmed.isEmpty) return null;
  if (phaseIndex < 0 || phaseIndex >= routine.phases.length) return null;
  final next = List<Phase>.from(routine.phases);
  next[phaseIndex] = next[phaseIndex].copyWith(name: trimmed);
  return routine.copyWith(phases: next);
}

WorkoutRoutine? setPhaseObjectiveInRoutine({
  required WorkoutRoutine routine,
  required int phaseIndex,
  required String? objective,
}) {
  if (phaseIndex < 0 || phaseIndex >= routine.phases.length) return null;
  final trimmed = objective?.trim();
  final next = List<Phase>.from(routine.phases);
  next[phaseIndex] = next[phaseIndex].copyWith(
    objective: trimmed,
    clearObjective: trimmed == null || trimmed.isEmpty,
  );
  return routine.copyWith(phases: next);
}

WorkoutRoutine? duplicatePhaseInRoutine({
  required WorkoutRoutine routine,
  required int phaseIndex,
  required String newPhaseId,
  String? newPhaseName,
}) {
  if (phaseIndex < 0 || phaseIndex >= routine.phases.length) return null;
  final source = routine.phases[phaseIndex];
  final cloned = _clonePhaseDeep(source, newPhaseId: newPhaseId);
  final named = newPhaseName == null
      ? cloned
      : cloned.copyWith(name: newPhaseName.trim().isEmpty ? cloned.name : newPhaseName.trim());
  final insertAt = phaseIndex + 1;
  var globalInsert = 0;
  for (var i = 0; i < insertAt; i++) {
    globalInsert += routine.phases[i].weeks.length;
  }
  final shift = named.weeks.length;
  final next = List<Phase>.from(routine.phases)..insert(insertAt, named);
  final updated = routine.copyWith(phases: next);
  if (shift == 0) return updated;
  return updated.remapSessionWeekIndices(
    (old) => old >= globalInsert ? old + shift : old,
  );
}

WorkoutRoutine? deletePhaseFromRoutine({
  required WorkoutRoutine routine,
  required int phaseIndex,
}) {
  if (phaseIndex < 0 || phaseIndex >= routine.phases.length) return null;
  var globalStart = 0;
  for (var i = 0; i < phaseIndex; i++) {
    globalStart += routine.phases[i].weeks.length;
  }
  final removeCount = routine.phases[phaseIndex].weeks.length;
  final next = List<Phase>.from(routine.phases)..removeAt(phaseIndex);
  final updated = routine.copyWith(phases: next);
  if (removeCount == 0) return updated;
  return updated.remapSessionWeekIndices((old) {
    if (old >= globalStart && old < globalStart + removeCount) return null;
    if (old >= globalStart + removeCount) return old - removeCount;
    return old;
  });
}

WorkoutRoutine? insertPhaseAtIndexInRoutine({
  required WorkoutRoutine routine,
  required int phaseIndex,
  required Phase phase,
}) {
  if (phaseIndex < 0 || phaseIndex > routine.phases.length) return null;
  var globalStart = 0;
  for (var i = 0; i < phaseIndex; i++) {
    globalStart += routine.phases[i].weeks.length;
  }
  final shift = phase.weeks.length;
  final next = List<Phase>.from(routine.phases)..insert(phaseIndex, phase);
  final updated = routine.copyWith(phases: next);
  if (shift == 0) return updated;
  return updated.remapSessionWeekIndices(
    (old) => old >= globalStart ? old + shift : old,
  );
}
