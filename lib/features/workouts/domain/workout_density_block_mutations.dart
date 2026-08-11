import '../data/workout_routine_model.dart';
import 'density_block.dart';
import 'workout_exercise_mutations.dart';

/// Sets or replaces the density config for [groupId] on a day.
///
/// [DensityBlockType.superset] clears the entry (absent = legacy superset).
Day setDensityBlock(Day day, String groupId, DensityBlockConfig config) {
  if (groupId.isEmpty) return day;
  if (config.type == DensityBlockType.superset) {
    return clearDensityBlock(day, groupId);
  }
  final next = Map<String, DensityBlockConfig>.from(day.densityBlocks ?? const {});
  next[groupId] = config;
  return day.copyWith(densityBlocks: next);
}

/// Removes the density config for [groupId], if present.
Day clearDensityBlock(Day day, String groupId) {
  final current = day.densityBlocks;
  if (current == null || !current.containsKey(groupId)) return day;
  final next = Map<String, DensityBlockConfig>.from(current)..remove(groupId);
  if (next.isEmpty) {
    return day.copyWith(clearDensityBlocks: true);
  }
  return day.copyWith(densityBlocks: next);
}

/// Drops density entries whose group id is no longer used by any exercise.
Day pruneOrphanDensityBlocks(Day day) {
  final blocks = day.densityBlocks;
  if (blocks == null || blocks.isEmpty) return day;
  final activeIds = <String>{};
  for (final exercise in day.exercises) {
    final id = exercise.supersetGroupId;
    if (id != null && id.isNotEmpty) activeIds.add(id);
  }
  final next = Map<String, DensityBlockConfig>.from(blocks)
    ..removeWhere((key, _) => !activeIds.contains(key));
  if (next.length == blocks.length) return day;
  if (next.isEmpty) return day.copyWith(clearDensityBlocks: true);
  return day.copyWith(densityBlocks: next);
}

WorkoutRoutine? updateDayInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required Day Function(Day day) update,
}) {
  if (weekIndex < 0 || weekIndex >= routine.weeks.length) return null;
  final week = routine.weeks[weekIndex];
  if (dayIndex < 0 || dayIndex >= week.days.length) return null;
  final day = week.days[dayIndex];
  final newDays = List<Day>.from(week.days);
  newDays[dayIndex] = update(day);
  final newWeeks = List<Week>.from(routine.weeks);
  newWeeks[weekIndex] = week.copyWith(days: newDays);
  return routine.copyWith(weeks: newWeeks);
}

WorkoutRoutine? setDensityBlockInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required String groupId,
  required DensityBlockConfig config,
}) {
  return updateDayInRoutine(
    routine: routine,
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    update: (day) => setDensityBlock(day, groupId, config),
  );
}

WorkoutRoutine? clearDensityBlockInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required String groupId,
}) {
  return updateDayInRoutine(
    routine: routine,
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    update: (day) => clearDensityBlock(day, groupId),
  );
}

/// Assigns [exerciseId] to [groupId] and optionally sets density metadata.
WorkoutRoutine? assignExerciseToDensityGroupInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required String exerciseId,
  required String groupId,
  DensityBlockConfig? densityConfig,
}) {
  final assigned = assignExerciseToSupersetInRoutine(
    routine: routine,
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    exerciseId: exerciseId,
    supersetGroupId: groupId,
  );
  if (assigned == null) return null;
  if (densityConfig == null) return assigned;
  return setDensityBlockInRoutine(
    routine: assigned,
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    groupId: groupId,
    config: densityConfig,
  );
}

WorkoutRoutine? pruneOrphanDensityBlocksInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
}) {
  return updateDayInRoutine(
    routine: routine,
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    update: pruneOrphanDensityBlocks,
  );
}
