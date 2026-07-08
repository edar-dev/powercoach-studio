import 'package:flutter/material.dart';

import '../../domain/exercise_prescription_scope.dart';
import '../../data/workout_routine_model.dart';
import 'workout_exercise_card.dart';
import 'workout_superset_panel.dart';

/// Superset group block in the workout training tab.
class WorkoutSupersetBlock extends StatelessWidget {
  const WorkoutSupersetBlock({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.weekIndex,
    required this.dayIndex,
    required this.exercises,
    this.supersetGroupId,
    required this.onAddExercise,
    required this.onDuplicateExercise,
    this.onAddExerciseToSuperset,
    required this.onRemoveExercise,
    required this.onMoveExercise,
    required this.onUpdateExercise,
    required this.onAddSetToExercise,
    required this.onUpdateExerciseSet,
    required this.onRemoveExerciseSet,
    this.onAssignToSuperset,
    this.onRemoveFromSuperset,
    this.supersetOptionsForDay = const [],
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final int weekIndex;
  final int dayIndex;
  final List<Exercise> exercises;
  final String? supersetGroupId;
  final VoidCallback onAddExercise;
  final void Function(int, int, Exercise) onDuplicateExercise;
  final void Function(int, int, String)? onAddExerciseToSuperset;
  final void Function(int, int, String) onRemoveExercise;
  final void Function(int, int, String, {required bool up}) onMoveExercise;
  final void Function(
    int,
    int,
    String, {
    String? name,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
    String? shortName,
    ExercisePrescriptionScope? prescriptionScope,
    List<ExerciseSet>? setDetails,
  })
  onUpdateExercise;
  final void Function(int, int, String) onAddSetToExercise;
  final void Function(
    int,
    int,
    String,
    int, {
    String? line,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
  })
  onUpdateExerciseSet;
  final void Function(int, int, String, int) onRemoveExerciseSet;
  final void Function(int, int, String, String)? onAssignToSuperset;
  final void Function(int, int, String)? onRemoveFromSuperset;
  final List<({String id, String label})> supersetOptionsForDay;

  @override
  Widget build(BuildContext context) {
    return WorkoutSupersetPanel(
      theme: theme,
      colorScheme: colorScheme,
      onAddExercise: supersetGroupId != null && onAddExerciseToSuperset != null
          ? () =>
                onAddExerciseToSuperset!(weekIndex, dayIndex, supersetGroupId!)
          : onAddExercise,
      children: [
        ...exercises.map(
          (ex) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WorkoutExerciseCard(
              theme: theme,
              colorScheme: colorScheme,
              exercise: ex,
              compact: false,
              linked: true,
              onDuplicate: () => onDuplicateExercise(weekIndex, dayIndex, ex),
              onRemove: () => onRemoveExercise(weekIndex, dayIndex, ex.id),
              onMoveUp: () =>
                  onMoveExercise(weekIndex, dayIndex, ex.id, up: true),
              onMoveDown: () =>
                  onMoveExercise(weekIndex, dayIndex, ex.id, up: false),
              onEdit:
                  (
                    name,
                    sets,
                    reps,
                    rpe,
                    note, {
                    setDetails,
                    shortName,
                    prescriptionScope,
                  }) => onUpdateExercise(
                    weekIndex,
                    dayIndex,
                    ex.id,
                    name: name,
                    sets: sets,
                    reps: reps,
                    rpe: rpe,
                    note: note,
                    setDetails: setDetails,
                    shortName: shortName,
                    prescriptionScope: prescriptionScope,
                  ),
              onAddSet: () => onAddSetToExercise(weekIndex, dayIndex, ex.id),
              onUpdateSet: (setIndex, sets, reps, load, note) =>
                  onUpdateExerciseSet(
                    weekIndex,
                    dayIndex,
                    ex.id,
                    setIndex,
                    sets: sets,
                    reps: reps,
                    rpe: load,
                    note: note,
                  ),
              onRemoveSet: (setIndex) =>
                  onRemoveExerciseSet(weekIndex, dayIndex, ex.id, setIndex),
              supersetOptions: supersetOptionsForDay
                  .where((o) => o.id != ex.supersetGroupId)
                  .toList(),
              onAssignToSuperset: onAssignToSuperset != null
                  ? (groupId) =>
                        onAssignToSuperset!(weekIndex, dayIndex, ex.id, groupId)
                  : null,
              onRemoveFromSuperset: onRemoveFromSuperset != null
                  ? () => onRemoveFromSuperset!(weekIndex, dayIndex, ex.id)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
