import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/density_block.dart';
import '../../domain/exercise_prescription_scope.dart';
import '../../domain/exercise_progression_suggestions.dart';
import '../../data/workout_routine_model.dart';
import '../workout_builder_session_controller.dart';
import 'workout_exercise_card.dart';
import 'workout_superset_block.dart';
import 'workout_training_helpers.dart';

/// Scrollable exercise list for a single training day.
///
/// Keeps a single expanded exercise id in local state so cards stay collapsed
/// by default and only one detail panel is open at a time.
class WorkoutDayExerciseList extends StatefulWidget {
  const WorkoutDayExerciseList({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.session,
    required this.weekIndex,
    required this.dayIndex,
    required this.day,
    this.onAddExercise,
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
    this.onSetDensityBlock,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final WorkoutBuilderSessionController session;
  final int weekIndex;
  final int dayIndex;
  final Day day;
  final void Function(int, int)? onAddExercise;
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
  final void Function(int, int, String, String, {DensityBlockConfig? densityConfig})
  onAssignToSuperset;
  final void Function(int, int, String) onRemoveFromSuperset;
  final void Function(int, int, String) onAddExerciseToSuperset;
  final void Function(int, int, String, DensityBlockConfig)? onSetDensityBlock;

  @override
  State<WorkoutDayExerciseList> createState() => _WorkoutDayExerciseListState();
}

class _WorkoutDayExerciseListState extends State<WorkoutDayExerciseList> {
  String? _expandedExerciseId;
  String? _expandedSupersetId;

  void _setExpandedExercise(String? id) {
    setState(() {
      _expandedExerciseId = id;
      if (id != null) _expandedSupersetId = null;
    });
  }

  void _setExpandedSuperset(String? id) {
    setState(() {
      _expandedSupersetId = id;
      if (id != null) _expandedExerciseId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final colorScheme = widget.colorScheme;
    final day = widget.day;
    final weekIndex = widget.weekIndex;
    final dayIndex = widget.dayIndex;
    final l10n = AppLocalizations.of(context);
    final partition = partitionExercisesBySuperset(day.exercises);
    final showTrailingAdd =
        day.exercises.isNotEmpty && widget.onAddExercise != null;

    if (day.exercises.isEmpty) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fitness_center_outlined,
                size: 40,
                color: colorScheme.onSurface.withValues(alpha: 0.72),
              ),
              const SizedBox(height: 20),
              if (widget.onAddExercise != null)
                FilledButton.icon(
                  onPressed: () => widget.onAddExercise!(weekIndex, dayIndex),
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(l10n.workoutBuilderEmptyDayCta),
                ),
            ],
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (showTrailingAdd && index == partition.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            widget.onAddExercise!(weekIndex, dayIndex),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(l10n.workoutBuilderAddExercise),
                      ),
                    );
                  }
                  final entry = partition[index];
                  final isLastPartition = index == partition.length - 1;
                  final showDivider = !isLastPartition;
                  if (entry is Exercise) {
                    return _buildExerciseCard(
                      context,
                      exercise: entry,
                      showBottomDivider: showDivider,
                    );
                  }
                  final exercises = entry as List<Exercise>;
                  final groupId = exercises.isNotEmpty &&
                          exercises.first.supersetGroupId != null
                      ? exercises.first.supersetGroupId!
                      : null;
                  final densityConfig = groupId == null
                      ? null
                      : resolveDensityBlock(day, groupId);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: WorkoutSupersetBlock(
                      theme: theme,
                      colorScheme: colorScheme,
                      session: widget.session,
                      weekIndex: weekIndex,
                      dayIndex: dayIndex,
                      exercises: exercises,
                      supersetGroupId: groupId,
                      densityConfig: densityConfig,
                      expanded:
                          groupId != null && groupId == _expandedSupersetId,
                      onExpandedChanged: (value) {
                        _setExpandedSuperset(value ? groupId : null);
                      },
                      onAddExercise: () =>
                          widget.onAddExercise?.call(weekIndex, dayIndex),
                      onAddExerciseToSuperset: widget.onAddExerciseToSuperset,
                      onRemoveExercise: widget.onRemoveExercise,
                      onMoveExerciseWithinSuperset:
                          widget.onMoveExerciseWithinSuperset,
                      onRemoveFromSuperset: widget.onRemoveFromSuperset,
                      onUpdateExercise: widget.onUpdateExercise,
                      onSetDensityBlock: widget.onSetDensityBlock,
                    ),
                  );
                },
                childCount: partition.length + (showTrailingAdd ? 1 : 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context, {
    required Exercise exercise,
    required bool showBottomDivider,
  }) {
    final ex = exercise;
    final weekIndex = widget.weekIndex;
    final dayIndex = widget.dayIndex;
    final day = widget.day;
    final suggestion = suggestExerciseProgression(
      plannedExercise: ex,
      executions: widget.session.routine.sessionExecutions.values.toList(),
    );
    return WorkoutExerciseCard(
      key: ValueKey(ex.id),
      theme: widget.theme,
      colorScheme: widget.colorScheme,
      exercise: ex,
      expanded: _expandedExerciseId == ex.id,
      showBottomDivider: showBottomDivider,
      onExpandedChanged: (value) {
        _setExpandedExercise(value ? ex.id : null);
      },
      onDuplicate: () =>
          widget.onDuplicateExercise(weekIndex, dayIndex, ex),
      onRemove: () => widget.onRemoveExercise(weekIndex, dayIndex, ex.id),
      onMoveUp: () =>
          widget.onMoveExercise(weekIndex, dayIndex, ex.id, up: true),
      onMoveDown: () =>
          widget.onMoveExercise(weekIndex, dayIndex, ex.id, up: false),
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
          }) => widget.onUpdateExercise(
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
      onAddSet: () =>
          widget.onAddSetToExercise(weekIndex, dayIndex, ex.id),
      onUpdateSet: (setIndex, sets, reps, load, note) =>
          widget.onUpdateExerciseSet(
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
          widget.onRemoveExerciseSet(weekIndex, dayIndex, ex.id, setIndex),
      supersetOptions: getSupersetGroupOptions(
        day,
      ).where((o) => o.id != ex.supersetGroupId).toList(),
      onAssignToSuperset: (groupId, {densityConfig}) =>
          widget.onAssignToSuperset(
            weekIndex,
            dayIndex,
            ex.id,
            groupId,
            densityConfig: densityConfig,
          ),
      onRemoveFromSuperset: ex.supersetGroupId != null
          ? () => widget.onRemoveFromSuperset(weekIndex, dayIndex, ex.id)
          : null,
      progressionSuggestion: suggestion,
      onApplyProgressionSuggestion: suggestion.isActionable
          ? () => _applyProgressionSuggestion(suggestion, ex, weekIndex, dayIndex)
          : null,
    );
  }

  void _applyProgressionSuggestion(
    ExerciseProgressionSuggestion suggestion,
    Exercise ex,
    int weekIndex,
    int dayIndex,
  ) {
    final updatedSets = ex.effectiveSetDetails
        .map(
          (s) => s.copyWith(
            reps: suggestion.suggestedReps,
            rpe: suggestion.suggestedLoad,
          ),
        )
        .toList();
    widget.onUpdateExercise(
      weekIndex,
      dayIndex,
      ex.id,
      setDetails: updatedSets,
    );
  }
}
