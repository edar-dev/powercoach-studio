import 'package:flutter/material.dart';

import '../../data/workout_routine_model.dart';
import '../../domain/density_block.dart';
import '../../domain/exercise_prescription_scope.dart';
import '../../domain/workout_exercise_mutations.dart';
import '../workout_builder_session_controller.dart';
import 'exercise_add_sheet.dart';
import 'workout_builder_superset_editor_sheet.dart';

/// Superset/multiset exercise actions extracted from the builder screen (phase 3).
class WorkoutSupersetActions {
  const WorkoutSupersetActions._();

  static Future<void> showSupersetEditorSheet({
    required BuildContext context,
    required WorkoutBuilderSessionController session,
    required int weekIndex,
    required int dayIndex,
    required String supersetGroupId,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required void Function(int weekIndex, int dayIndex, String supersetGroupId)
    onAddExerciseToSuperset,
    required void Function(int weekIndex, int dayIndex, String exerciseId)
    onRemoveExercise,
    required void Function(
      int weekIndex,
      int dayIndex,
      String exerciseId, {
      required bool up,
    })
    onMoveExerciseWithinSuperset,
    required void Function(int weekIndex, int dayIndex, String exerciseId)
    onRemoveFromSuperset,
    required void Function(
      int weekIndex,
      int dayIndex,
      String exerciseId, {
      String? name,
      String? sets,
      String? reps,
      String? rpe,
      String? note,
      String? shortName,
      ExercisePrescriptionScope? prescriptionScope,
      List<ExerciseSet>? setDetails,
    })
    onUpdateExercise,
    void Function(int weekIndex, int dayIndex, String groupId, DensityBlockConfig config)?
    onSetDensityBlock,
  }) {
    return showWorkoutBuilderSupersetEditorSheet(
      context: context,
      session: session,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      supersetGroupId: supersetGroupId,
      theme: theme,
      colorScheme: colorScheme,
      onAddExerciseToSuperset: onAddExerciseToSuperset,
      onRemoveExercise: onRemoveExercise,
      onMoveExerciseWithinSuperset: onMoveExerciseWithinSuperset,
      onRemoveFromSuperset: onRemoveFromSuperset,
      onUpdateExercise: onUpdateExercise,
      onSetDensityBlock: onSetDensityBlock,
    );
  }

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
