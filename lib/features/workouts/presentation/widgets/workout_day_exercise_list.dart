import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../domain/exercise_prescription_scope.dart';
import '../../data/workout_routine_model.dart';
import '../workout_builder_session_controller.dart';
import 'session_exercise_editor_card.dart';
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
    this.onCreateSuperset,
    this.sessionEditStyle = false,
    this.athleteName,
    this.readOnly = false,
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
  final void Function(int, int)? onAddExercise;

  /// Session-edit bottom CTA: creates a new superset group.
  final VoidCallback? onCreateSuperset;

  /// When true, renders Stitch session cards + dual bottom CTAs.
  final bool sessionEditStyle;
  final String? athleteName;

  /// When true, hides mutation controls on session cards.
  final bool readOnly;
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
  State<WorkoutDayExerciseList> createState() => _WorkoutDayExerciseListState();
}

class _WorkoutDayExerciseListState extends State<WorkoutDayExerciseList> {
  String? _expandedExerciseId;
  String? _expandedSupersetId;

  @override
  void initState() {
    super.initState();
    if (widget.sessionEditStyle && widget.day.exercises.isNotEmpty) {
      final first = widget.day.exercises.first;
      // Expand first standalone exercise; supersets stay collapsed.
      if (first.supersetGroupId == null || first.supersetGroupId!.isEmpty) {
        _expandedExerciseId = first.id;
      }
    }
  }

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
    final showSessionCtas = widget.sessionEditStyle &&
        (widget.onAddExercise != null || widget.onCreateSuperset != null);

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
              const SizedBox(height: 12),
              Text(
                l10n.workoutBuilderSessionEmptyTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              if (widget.sessionEditStyle && showSessionCtas)
                _SessionBottomCtas(
                  l10n: l10n,
                  onAddFromLibrary: widget.onAddExercise == null
                      ? null
                      : () => widget.onAddExercise!(weekIndex, dayIndex),
                  onCreateSuperset: widget.onCreateSuperset,
                )
              else if (widget.onAddExercise != null)
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

    // Precompute display indices for session cards (1-based across day).
    final exerciseIndexById = <String, int>{};
    var nextIndex = 1;
    for (final ex in day.exercises) {
      exerciseIndexById[ex.id] = nextIndex++;
    }

    final trailingCount = widget.sessionEditStyle
        ? (showSessionCtas ? 1 : 0)
        : (showTrailingAdd ? 1 : 0);

    return RepaintBoundary(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == partition.length) {
                    if (widget.sessionEditStyle) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _SessionBottomCtas(
                          l10n: l10n,
                          onAddFromLibrary: widget.onAddExercise == null
                              ? null
                              : () =>
                                  widget.onAddExercise!(weekIndex, dayIndex),
                          onCreateSuperset: widget.onCreateSuperset,
                        ),
                      );
                    }
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
                  final showDivider =
                      !isLastPartition && !widget.sessionEditStyle;
                  if (entry is Exercise) {
                    return _buildExerciseCard(
                      context,
                      exercise: entry,
                      displayIndex: exerciseIndexById[entry.id] ?? (index + 1),
                      showBottomDivider: showDivider,
                    );
                  }
                  final exercises = entry as List<Exercise>;
                  final groupId = exercises.isNotEmpty &&
                          exercises.first.supersetGroupId != null
                      ? exercises.first.supersetGroupId!
                      : null;
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
                    ),
                  );
                },
                childCount: partition.length + trailingCount,
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
    required int displayIndex,
    required bool showBottomDivider,
  }) {
    final ex = exercise;
    final weekIndex = widget.weekIndex;
    final dayIndex = widget.dayIndex;
    final day = widget.day;
    void onEdit(
      String name,
      String sets,
      String reps,
      String rpe,
      String note, {
      List<ExerciseSet>? setDetails,
      String? shortName,
      ExercisePrescriptionScope? prescriptionScope,
    }) =>
        widget.onUpdateExercise(
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
        );
    void onUpdateSet(
      int setIndex,
      String sets,
      String reps,
      String load,
      String note,
    ) =>
        widget.onUpdateExerciseSet(
          weekIndex,
          dayIndex,
          ex.id,
          setIndex,
          sets: sets,
          reps: reps,
          rpe: load,
          note: note,
        );
    void onRemoveSet(int setIndex) =>
        widget.onRemoveExerciseSet(weekIndex, dayIndex, ex.id, setIndex);
    void onAddSet() =>
        widget.onAddSetToExercise(weekIndex, dayIndex, ex.id);
    void onDuplicateLastSet() {
      final details = List<ExerciseSet>.from(ex.effectiveSetDetails);
      if (details.isEmpty) {
        onAddSet();
        return;
      }
      final last = details.last;
      details.add(
        ExerciseSet(
          line: last.line,
          sets: last.sets,
          reps: last.reps,
          rpe: last.rpe,
          note: last.note,
        ),
      );
      widget.onUpdateExercise(
        weekIndex,
        dayIndex,
        ex.id,
        setDetails: details,
      );
    }

    if (widget.sessionEditStyle) {
      final canEdit = !widget.readOnly;
      return SessionExerciseEditorCard(
        key: ValueKey(ex.id),
        theme: widget.theme,
        colorScheme: widget.colorScheme,
        exercise: ex,
        index: displayIndex,
        expanded: _expandedExerciseId == ex.id,
        athleteName: widget.athleteName,
        onExpandedChanged: (value) {
          _setExpandedExercise(value ? ex.id : null);
        },
        onDuplicate: canEdit
            ? () => widget.onDuplicateExercise(weekIndex, dayIndex, ex)
            : null,
        onRemove: canEdit
            ? () => widget.onRemoveExercise(weekIndex, dayIndex, ex.id)
            : null,
        onMoveUp: canEdit
            ? () =>
                widget.onMoveExercise(weekIndex, dayIndex, ex.id, up: true)
            : null,
        onMoveDown: canEdit
            ? () =>
                widget.onMoveExercise(weekIndex, dayIndex, ex.id, up: false)
            : null,
        onEdit: canEdit ? onEdit : null,
        onAddSet: canEdit ? onAddSet : null,
        onDuplicateLastSet: canEdit ? onDuplicateLastSet : null,
        onUpdateSet: canEdit ? onUpdateSet : null,
        onRemoveSet: canEdit ? onRemoveSet : null,
        supersetOptions: canEdit
            ? getSupersetGroupOptions(
                day,
              ).where((o) => o.id != ex.supersetGroupId).toList()
            : const [],
        onAssignToSuperset: canEdit
            ? (groupId) => widget.onAssignToSuperset(
                  weekIndex,
                  dayIndex,
                  ex.id,
                  groupId,
                )
            : null,
        onRemoveFromSuperset: canEdit && ex.supersetGroupId != null
            ? () => widget.onRemoveFromSuperset(weekIndex, dayIndex, ex.id)
            : null,
      );
    }

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
      onEdit: onEdit,
      onAddSet: onAddSet,
      onUpdateSet: onUpdateSet,
      onRemoveSet: onRemoveSet,
      supersetOptions: getSupersetGroupOptions(
        day,
      ).where((o) => o.id != ex.supersetGroupId).toList(),
      onAssignToSuperset: (groupId) =>
          widget.onAssignToSuperset(
            weekIndex,
            dayIndex,
            ex.id,
            groupId,
          ),
      onRemoveFromSuperset: ex.supersetGroupId != null
          ? () => widget.onRemoveFromSuperset(weekIndex, dayIndex, ex.id)
          : null,
    );
  }
}

class _SessionBottomCtas extends StatelessWidget {
  const _SessionBottomCtas({
    required this.l10n,
    this.onAddFromLibrary,
    this.onCreateSuperset,
  });

  final AppLocalizations l10n;
  final VoidCallback? onAddFromLibrary;
  final VoidCallback? onCreateSuperset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onAddFromLibrary != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onAddFromLibrary,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.workoutSessionAddFromLibrary),
              style: OutlinedButton.styleFrom(
                foregroundColor: StitchM3Theme.accent,
                side: BorderSide(
                  color: StitchM3Theme.accent.withValues(alpha: 0.75),
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        if (onAddFromLibrary != null && onCreateSuperset != null)
          const SizedBox(width: 12),
        if (onCreateSuperset != null)
          Expanded(
            child: FilledButton.tonalIcon(
              onPressed: onCreateSuperset,
              icon: const Icon(Icons.link, size: 18),
              label: Text(l10n.workoutSessionCreateSupersetCircuit),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
