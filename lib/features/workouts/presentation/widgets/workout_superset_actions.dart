import 'package:flutter/material.dart';

import '../../data/workout_routine_model.dart';
import '../../domain/workout_exercise_mutations.dart';
import 'exercise_add_sheet.dart';

/// Superset/multiset exercise actions extracted from the builder screen (phase 3).
class WorkoutSupersetActions {
  const WorkoutSupersetActions._();

  static void showAddExerciseToSupersetDialog({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required WorkoutRoutine routine,
    required int weekIndex,
    required int dayIndex,
    required String supersetGroupId,
    String? customerId,
    required void Function(WorkoutRoutine updated) onRoutineChanged,
  }) {
    if (weekIndex < 0 || weekIndex >= routine.weeks.length) return;
    if (dayIndex < 0 || dayIndex >= routine.weeks[weekIndex].days.length) {
      return;
    }
    final exId = 'e_${DateTime.now().millisecondsSinceEpoch}';
    showAddExerciseDialog(context, theme, colorScheme, (
      name,
      note,
      details, [
      customExerciseId,
    ]) {
      final trimmedName = name.trim();
      if (trimmedName.isEmpty) return;
      final updated = addExerciseToSupersetInRoutine(
        routine: routine,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        supersetGroupId: supersetGroupId,
        exercise: buildExerciseFromPrescription(
          id: exId,
          name: trimmedName,
          note: note,
          setDetails: details,
          customExerciseId: customExerciseId,
          supersetGroupId: supersetGroupId,
        ),
      );
      if (updated == null) return;
      onRoutineChanged(updated);
    }, customerId: customerId);
  }

  static WorkoutRoutine? assignToSuperset({
    required WorkoutRoutine routine,
    required int weekIndex,
    required int dayIndex,
    required String exerciseId,
    required String supersetGroupId,
  }) => assignExerciseToSupersetInRoutine(
    routine: routine,
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    exerciseId: exerciseId,
    supersetGroupId: supersetGroupId,
  );

  static WorkoutRoutine? removeFromSuperset({
    required WorkoutRoutine routine,
    required int weekIndex,
    required int dayIndex,
    required String exerciseId,
  }) => removeExerciseFromSupersetInRoutine(
    routine: routine,
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    exerciseId: exerciseId,
  );
}
