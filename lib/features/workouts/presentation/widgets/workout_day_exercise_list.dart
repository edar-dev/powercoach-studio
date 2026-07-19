import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/exercise_prescription_scope.dart';
import '../../data/workout_routine_model.dart';
import '../workout_builder_session_controller.dart';
import 'workout_exercise_card.dart';
import 'workout_superset_block.dart';
import 'workout_training_helpers.dart';

/// Scrollable exercise list for a single training day.
class WorkoutDayExerciseList extends StatelessWidget {
  const WorkoutDayExerciseList({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.session,
    required this.weekIndex,
    required this.dayIndex,
    required this.day,
    required this.onAddExercise,
    required this.onDuplicateExercise,
    required this.onRemoveExercise,
    required this.onMoveExercise,
    required this.onMoveExerciseWithinSuperset,
    required this.onUpdateExercise,
    required this.onAddSetToExercise,
    required this.onUpdateExerciseSet,
    required this.onRemoveExerciseSet,
    required this.onAssignToSuperset,
    required this.onRemoveFromSuperset,
    required this.onAddExerciseToSuperset,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final WorkoutBuilderSessionController session;
  final int weekIndex;
  final int dayIndex;
  final Day day;
  final void Function(int, int) onAddExercise;
  final void Function(int, int, Exercise) onDuplicateExercise;
  final void Function(int, int, String) onRemoveExercise;
  final void Function(int, int, String, {required bool up}) onMoveExercise;
  final void Function(int, int, String, {required bool up})
  onMoveExerciseWithinSuperset;
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
  final void Function(int, int, String, String) onAssignToSuperset;
  final void Function(int, int, String) onRemoveFromSuperset;
  final void Function(int, int, String) onAddExerciseToSuperset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final partition = partitionExercisesBySuperset(day.exercises);
    final itemCount = partition.length + (day.exercises.isEmpty ? 1 : 0);
    return RepaintBoundary(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 96, right: 4),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (day.exercises.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  Icon(
                    Icons.fitness_center_outlined,
                    size: 40,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.workoutBuilderExerciseCount(0),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => onAddExercise(weekIndex, dayIndex),
                    icon: const Icon(Icons.add, size: 20),
                    label: Text(l10n.workoutBuilderEmptyDayCta),
                  ),
                ],
              ),
            );
          }
          final entry = partition[index];
          if (entry is Exercise) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildExerciseCard(context, exercise: entry),
            );
          }
          final exercises = entry as List<Exercise>;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: WorkoutSupersetBlock(
              theme: theme,
              colorScheme: colorScheme,
              session: session,
              weekIndex: weekIndex,
              dayIndex: dayIndex,
              exercises: exercises,
              supersetGroupId:
                  exercises.isNotEmpty &&
                      exercises.first.supersetGroupId != null
                  ? exercises.first.supersetGroupId!
                  : null,
              onAddExercise: () => onAddExercise(weekIndex, dayIndex),
              onAddExerciseToSuperset: onAddExerciseToSuperset,
              onRemoveExercise: onRemoveExercise,
              onMoveExerciseWithinSuperset: onMoveExerciseWithinSuperset,
              onRemoveFromSuperset: onRemoveFromSuperset,
              onUpdateExercise: onUpdateExercise,
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, {required Exercise exercise}) {
    final ex = exercise;
    return WorkoutExerciseCard(
      theme: theme,
      colorScheme: colorScheme,
      exercise: ex,
      compact: true,
      onDuplicate: () => onDuplicateExercise(weekIndex, dayIndex, ex),
      onRemove: () => onRemoveExercise(weekIndex, dayIndex, ex.id),
      onMoveUp: () => onMoveExercise(weekIndex, dayIndex, ex.id, up: true),
      onMoveDown: () => onMoveExercise(weekIndex, dayIndex, ex.id, up: false),
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
      onUpdateSet: (setIndex, sets, reps, load, note) => onUpdateExerciseSet(
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
      supersetOptions: getSupersetGroupOptions(
        day,
      ).where((o) => o.id != ex.supersetGroupId).toList(),
      onAssignToSuperset: (groupId) =>
          onAssignToSuperset(weekIndex, dayIndex, ex.id, groupId),
      onRemoveFromSuperset: ex.supersetGroupId != null
          ? () => onRemoveFromSuperset(weekIndex, dayIndex, ex.id)
          : null,
    );
  }
}
