import '../data/workout_routine_model.dart';
import 'exercise_prescription_scope.dart';
import 'exercise_summary_sync.dart';

typedef DayExercisesUpdater = List<Exercise> Function(List<Exercise> exercises);

WorkoutRoutine? updateDayExercisesInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required DayExercisesUpdater update,
}) {
  if (weekIndex < 0 || weekIndex >= routine.weeks.length) return null;
  final week = routine.weeks[weekIndex];
  if (dayIndex < 0 || dayIndex >= week.days.length) return null;
  final day = week.days[dayIndex];
  final newExercises = update(List<Exercise>.from(day.exercises));
  final newDays = List<Day>.from(week.days);
  newDays[dayIndex] = day.copyWith(exercises: newExercises);
  final newWeeks = List<Week>.from(routine.weeks);
  newWeeks[weekIndex] = week.copyWith(days: newDays);
  return routine.copyWith(weeks: newWeeks);
}

Exercise buildExerciseFromPrescription({
  required String id,
  required String name,
  required String note,
  required List<ExerciseSet> setDetails,
  String? customExerciseId,
  String? supersetGroupId,
}) {
  final list = setDetails.isEmpty ? [const ExerciseSet()] : setDetails;
  return Exercise(
    id: id,
    name: name,
    sets: '${list.length}',
    reps: list
        .map((s) => s.displayText)
        .where((r) => r.isNotEmpty)
        .join(' | '),
    rpe: '',
    note: note,
    setDetails: list,
    customExerciseId: customExerciseId,
    supersetGroupId: supersetGroupId,
  );
}

WorkoutRoutine? addExerciseToDayInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required Exercise exercise,
}) {
  return updateDayExercisesInRoutine(
    routine: routine,
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    update: (exercises) => [...exercises, exercise],
  );
}

WorkoutRoutine? addExerciseToSupersetInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required String supersetGroupId,
  required Exercise exercise,
}) {
  return updateDayExercisesInRoutine(
    routine: routine,
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    update: (exercises) {
      var insertIndex = exercises.length;
      for (var i = exercises.length - 1; i >= 0; i--) {
        if (exercises[i].supersetGroupId == supersetGroupId) {
          insertIndex = i + 1;
          break;
        }
      }
      final next = List<Exercise>.from(exercises);
      next.insert(insertIndex, exercise);
      return next;
    },
  );
}

WorkoutRoutine? removeExerciseFromDayInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required String exerciseId,
}) {
  return updateDayExercisesInRoutine(
    routine: routine,
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    update: (exercises) =>
        exercises.where((e) => e.id != exerciseId).toList(),
  );
}

WorkoutRoutine? moveExerciseInDayInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required String exerciseId,
  required bool up,
}) {
  return updateDayExercisesInRoutine(
    routine: routine,
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    update: (exercises) {
      final currentIndex = exercises.indexWhere((e) => e.id == exerciseId);
      if (currentIndex < 0) return exercises;
      final targetIndex = up ? currentIndex - 1 : currentIndex + 1;
      if (targetIndex < 0 || targetIndex >= exercises.length) return exercises;
      final reordered = List<Exercise>.from(exercises);
      final item = reordered.removeAt(currentIndex);
      reordered.insert(targetIndex, item);
      return reordered;
    },
  );
}

WorkoutRoutine? updateExerciseInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required String exerciseId,
  String? name,
  String? sets,
  String? reps,
  String? rpe,
  String? note,
  String? shortName,
  ExercisePrescriptionScope? prescriptionScope,
  List<ExerciseSet>? setDetails,
}) {
  return updateDayExercisesInRoutine(
    routine: routine,
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    update: (exercises) => exercises
        .map((e) {
          if (e.id != exerciseId) return e;
          return ExerciseSummarySync.apply(
            e.copyWith(
              name: name ?? e.name,
              sets: sets ?? e.sets,
              reps: reps ?? e.reps,
              rpe: rpe ?? e.rpe,
              note: note ?? e.note,
              shortName: shortName ?? e.shortName,
              prescriptionScope: prescriptionScope ?? e.prescriptionScope,
              setDetails: setDetails ?? e.setDetails,
            ),
          );
        })
        .toList(),
  );
}

WorkoutRoutine? addSetToExerciseInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required String exerciseId,
}) {
  return updateDayExercisesInRoutine(
    routine: routine,
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    update: (exercises) => exercises
        .map((e) {
          if (e.id != exerciseId) return e;
          final details = [...e.effectiveSetDetails, const ExerciseSet()];
          return e.copyWith(setDetails: details);
        })
        .toList(),
  );
}

WorkoutRoutine? updateExerciseSetInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required String exerciseId,
  required int setIndex,
  String? line,
  String? sets,
  String? reps,
  String? rpe,
  String? note,
}) {
  return updateDayExercisesInRoutine(
    routine: routine,
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    update: (exercises) => exercises
        .map((e) {
          if (e.id != exerciseId) return e;
          final details = e.effectiveSetDetails;
          if (setIndex < 0 || setIndex >= details.length) return e;
          final newDetails = List<ExerciseSet>.from(details);
          final cur = details[setIndex];
          if (line != null) {
            final trimmed = line.trim();
            if (trimmed.isNotEmpty) {
              newDetails[setIndex] = ExerciseSet(
                line: trimmed,
                sets: '1',
                reps: '',
                rpe: '',
                note: note ?? cur.note,
              );
            } else {
              newDetails[setIndex] = cur.copyWith(note: note ?? cur.note);
            }
          } else if (sets != null || reps != null || rpe != null) {
            newDetails[setIndex] = ExerciseSet(
              line: '',
              sets: sets ?? cur.sets,
              reps: reps ?? cur.reps,
              rpe: rpe ?? cur.rpe,
              note: note ?? cur.note,
            );
          } else {
            newDetails[setIndex] = cur.copyWith(note: note ?? cur.note);
          }
          return e.copyWith(setDetails: newDetails);
        })
        .toList(),
  );
}

WorkoutRoutine? removeExerciseSetInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required String exerciseId,
  required int setIndex,
}) {
  return updateDayExercisesInRoutine(
    routine: routine,
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    update: (exercises) => exercises
        .map((e) {
          if (e.id != exerciseId) return e;
          final details = e.effectiveSetDetails;
          if (details.length <= 1) return e;
          if (setIndex < 0 || setIndex >= details.length) return e;
          final newDetails = List<ExerciseSet>.from(details)..removeAt(setIndex);
          return e.copyWith(setDetails: newDetails);
        })
        .toList(),
  );
}

WorkoutRoutine? assignExerciseToSupersetInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required String exerciseId,
  required String supersetGroupId,
}) {
  return updateDayExercisesInRoutine(
    routine: routine,
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    update: (exercises) => exercises
        .map(
          (e) => e.id == exerciseId
              ? e.copyWith(supersetGroupId: supersetGroupId)
              : e,
        )
        .toList(),
  );
}

WorkoutRoutine? removeExerciseFromSupersetInRoutine({
  required WorkoutRoutine routine,
  required int weekIndex,
  required int dayIndex,
  required String exerciseId,
}) {
  return updateDayExercisesInRoutine(
    routine: routine,
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    update: (exercises) => exercises
        .map(
          (e) =>
              e.id == exerciseId ? e.copyWith(clearSupersetGroupId: true) : e,
        )
        .toList(),
  );
}
