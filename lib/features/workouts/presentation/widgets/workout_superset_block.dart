import 'package:flutter/material.dart';

import '../../domain/exercise_prescription_scope.dart';
import '../../data/workout_routine_model.dart';
import '../workout_builder_session_controller.dart';
import 'workout_superset_actions.dart';
import 'workout_superset_panel.dart';
import 'workout_training_helpers.dart';

/// Superset group block in the workout training tab (expandable preview + editor sheet).
class WorkoutSupersetBlock extends StatelessWidget {
  const WorkoutSupersetBlock({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.session,
    required this.weekIndex,
    required this.dayIndex,
    required this.exercises,
    this.supersetGroupId,
    required this.expanded,
    required this.onExpandedChanged,
    required this.onAddExercise,
    required this.onAddExerciseToSuperset,
    required this.onRemoveExercise,
    required this.onMoveExerciseWithinSuperset,
    required this.onRemoveFromSuperset,
    required this.onUpdateExercise,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final WorkoutBuilderSessionController session;
  final int weekIndex;
  final int dayIndex;
  final List<Exercise> exercises;
  final String? supersetGroupId;
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
  final VoidCallback onAddExercise;
  final void Function(int, int, String) onAddExerciseToSuperset;
  final void Function(int, int, String) onRemoveExercise;
  final void Function(int, int, String, {required bool up})
  onMoveExerciseWithinSuperset;
  final void Function(int, int, String) onRemoveFromSuperset;
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

  void _openEditor(BuildContext context) {
    final groupId = supersetGroupId;
    if (groupId == null || groupId.isEmpty) return;
    WorkoutSupersetActions.showSupersetEditorSheet(
      context: context,
      session: session,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      supersetGroupId: groupId,
      theme: theme,
      colorScheme: colorScheme,
      onAddExerciseToSuperset: onAddExerciseToSuperset,
      onRemoveExercise: onRemoveExercise,
      onMoveExerciseWithinSuperset: onMoveExerciseWithinSuperset,
      onRemoveFromSuperset: onRemoveFromSuperset,
      onUpdateExercise: onUpdateExercise,
    );
  }

  @override
  Widget build(BuildContext buildContext) {
    final lead = exercises.isNotEmpty ? exercises.first : null;
    final prescriptionSummary =
        lead != null ? supersetPrescriptionSummary(lead) : null;
    final namesSummary = exercises.map((e) => e.name).join(' · ');

    return WorkoutSupersetPanel(
      theme: theme,
      colorScheme: colorScheme,
      expanded: expanded,
      onExpandedChanged: onExpandedChanged,
      prescriptionSummary: (prescriptionSummary != null &&
              prescriptionSummary.trim().isNotEmpty)
          ? prescriptionSummary
          : namesSummary,
      onOpenEditor:
          supersetGroupId != null ? () => _openEditor(buildContext) : null,
      onAddExercise: supersetGroupId != null
          ? () => onAddExerciseToSuperset(weekIndex, dayIndex, supersetGroupId!)
          : onAddExercise,
      children: [
        ...exercises.map(
          (exercise) {
            final exerciseNote = exercise.note.trim();
            final setNotes = exercise.effectiveSetDetails
                .map((s) => s.note.trim())
                .where((n) => n.isNotEmpty)
                .toList();
            final notePreview = exerciseNote.isNotEmpty
                ? exerciseNote
                : setNotes.join(' · ');
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (notePreview.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        notePreview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
