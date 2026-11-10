import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../domain/exercise_prescription_scope.dart';
import '../../domain/maximal_ref.dart';
import '../../data/workout_routine_model.dart';
import '../workout_builder_session_controller.dart';
import 'session_exercise_editor_card.dart';
import 'workout_exercise_card.dart';
import 'workout_superset_block.dart';
import 'workout_training_helpers.dart';

/// Training vs mobility presentation for the shared day exercise list.
enum SessionListVariant { training, mobility }

/// Scrollable exercise list for a single training day (or mobility section).
///
/// Keeps a single expanded exercise id in local state so cards stay collapsed
/// by default and only one detail panel is open at a time. Newly added
/// exercises (or their parent superset) are expanded automatically.
///
/// When [variant] is [SessionListVariant.mobility], [session] may be null and
/// the list skips supersets / set editing — cards use
/// [SessionExerciseEditorVariant.mobility].
class WorkoutDayExerciseList extends StatefulWidget {
  const WorkoutDayExerciseList({
    super.key,
    required this.theme,
    required this.colorScheme,
    this.session,
    required this.weekIndex,
    required this.dayIndex,
    required this.day,
    this.variant = SessionListVariant.training,
    this.onAddExercise,
    this.onCreateSuperset,
    this.sessionEditStyle = false,
    this.pinBottomCtas = false,
    this.athleteName,
    this.customerId,
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
  }) : assert(
          variant == SessionListVariant.mobility || session != null,
          'session is required for SessionListVariant.training',
        );

  final ThemeData theme;
  final ColorScheme colorScheme;

  /// Required for [SessionListVariant.training] (superset block needs it).
  final WorkoutBuilderSessionController? session;
  final int weekIndex;
  final int dayIndex;
  final Day day;
  final SessionListVariant variant;
  final void Function(int, int)? onAddExercise;

  /// Session-edit bottom CTA: creates a new superset group.
  final VoidCallback? onCreateSuperset;

  /// When true, renders Stitch session cards + dual bottom CTAs.
  final bool sessionEditStyle;

  /// When true with [sessionEditStyle], omit trailing CTAs from the scroll
  /// sliver so a parent sticky footer can own them. Empty-state CTAs stay
  /// visible in the empty body.
  final bool pinBottomCtas;
  final String? athleteName;

  /// Customer id for Massimali resolve in set editors (null in sandbox).
  final String? customerId;

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
    MaximalRef? maximalRef,
    bool clearMaximalRef,
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

  @override
  void didUpdateWidget(covariant WorkoutDayExerciseList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIds = {
      for (final e in oldWidget.day.exercises) e.id,
    };
    final added = widget.day.exercises
        .where((e) => !oldIds.contains(e.id))
        .toList(growable: false);
    if (added.isEmpty) return;

    // Append is the common path (library pick, duplicate, compact/full add).
    // When several ids appear at once (e.g. day clone), expand the last one.
    final newest = added.last;
    final groupId = newest.supersetGroupId;
    if (groupId != null && groupId.isNotEmpty) {
      _expandedSupersetId = groupId;
      _expandedExerciseId = null;
    } else {
      _expandedExerciseId = newest.id;
      _expandedSupersetId = null;
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

  bool get _isMobility => widget.variant == SessionListVariant.mobility;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final colorScheme = widget.colorScheme;
    final day = widget.day;
    final weekIndex = widget.weekIndex;
    final dayIndex = widget.dayIndex;
    final l10n = AppLocalizations.of(context);
    // Mobility never groups supersets — each synthetic exercise is standalone.
    final partition = _isMobility
        ? List<Object>.from(day.exercises)
        : partitionExercisesBySuperset(day.exercises);
    final showTrailingAdd =
        day.exercises.isNotEmpty && widget.onAddExercise != null;
    final createSuperset = _isMobility ? null : widget.onCreateSuperset;
    final showSessionCtas = widget.sessionEditStyle &&
        (widget.onAddExercise != null || createSuperset != null);
    // Pinning moves non-empty trailing CTAs to a sticky footer; empty body
    // keeps CTAs in-place so the empty state stays actionable.
    final showInScrollSessionCtas =
        showSessionCtas && !widget.pinBottomCtas;

    if (day.exercises.isEmpty) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isMobility
                    ? Icons.self_improvement_outlined
                    : Icons.fitness_center_outlined,
                size: 40,
                color: colorScheme.onSurface.withValues(alpha: 0.72),
              ),
              const SizedBox(height: 12),
              Text(
                _isMobility
                    ? l10n.workoutBuilderMobilityEmptyTitle
                    : l10n.workoutBuilderSessionEmptyTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_isMobility) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.workoutBuilderMobilityEmptyMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 20),
              ] else
                const SizedBox(height: 16),
              if (widget.sessionEditStyle && showSessionCtas)
                SessionDayBottomCtas(
                  l10n: l10n,
                  onAddFromLibrary: widget.onAddExercise == null
                      ? null
                      : () => widget.onAddExercise!(weekIndex, dayIndex),
                  onCreateSuperset: createSuperset,
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

    // Cache once per list build; cards filter out their own group id.
    final allSupersetOptions = getSupersetGroupOptions(day);

    final trailingCount = widget.sessionEditStyle
        ? (showInScrollSessionCtas ? 1 : 0)
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
                        child: SessionDayBottomCtas(
                          l10n: l10n,
                          onAddFromLibrary: widget.onAddExercise == null
                              ? null
                              : () =>
                                  widget.onAddExercise!(weekIndex, dayIndex),
                          onCreateSuperset: createSuperset,
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
                    return RepaintBoundary(
                      child: _buildExerciseCard(
                        context,
                        exercise: entry,
                        displayIndex:
                            exerciseIndexById[entry.id] ?? (index + 1),
                        showBottomDivider: showDivider,
                        allSupersetOptions: allSupersetOptions,
                      ),
                    );
                  }
                  final exercises = entry as List<Exercise>;
                  final groupId = exercises.isNotEmpty &&
                          exercises.first.supersetGroupId != null
                      ? exercises.first.supersetGroupId!
                      : null;
                  final session = widget.session;
                  assert(
                    session != null,
                    'session required to render WorkoutSupersetBlock',
                  );
                  return RepaintBoundary(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: WorkoutSupersetBlock(
                        theme: theme,
                        colorScheme: colorScheme,
                        session: session!,
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
    required List<({String id, String label})> allSupersetOptions,
  }) {
    final ex = exercise;
    final weekIndex = widget.weekIndex;
    final dayIndex = widget.dayIndex;
    final filteredSupersetOptions = allSupersetOptions
        .where((o) => o.id != ex.supersetGroupId)
        .toList(growable: false);
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

    void onMaximalRefChanged(MaximalRef? ref, {required bool clear}) {
      widget.onUpdateExercise(
        weekIndex,
        dayIndex,
        ex.id,
        maximalRef: ref,
        clearMaximalRef: clear,
      );
    }

    if (widget.sessionEditStyle) {
      final canEdit = !widget.readOnly;
      final mobility = _isMobility;
      return SessionExerciseEditorCard(
        key: ValueKey(ex.id),
        theme: widget.theme,
        colorScheme: widget.colorScheme,
        exercise: ex,
        index: displayIndex,
        expanded: _expandedExerciseId == ex.id,
        variant: mobility
            ? SessionExerciseEditorVariant.mobility
            : SessionExerciseEditorVariant.training,
        athleteName: mobility ? null : widget.athleteName,
        customerId: mobility ? null : widget.customerId,
        onExpandedChanged: (value) {
          _setExpandedExercise(value ? ex.id : null);
        },
        onDuplicate: canEdit && !mobility
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
        onAddSet: canEdit && !mobility ? onAddSet : null,
        onDuplicateLastSet: canEdit && !mobility ? onDuplicateLastSet : null,
        onUpdateSet: canEdit && !mobility ? onUpdateSet : null,
        onRemoveSet: canEdit && !mobility ? onRemoveSet : null,
        onMaximalRefChanged:
            canEdit && !mobility ? onMaximalRefChanged : null,
        supersetOptions:
            canEdit && !mobility ? filteredSupersetOptions : const [],
        onAssignToSuperset: canEdit && !mobility
            ? (groupId) => widget.onAssignToSuperset(
                  weekIndex,
                  dayIndex,
                  ex.id,
                  groupId,
                )
            : null,
        onRemoveFromSuperset:
            canEdit && !mobility && ex.supersetGroupId != null
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
      customerId: widget.customerId,
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
      onMaximalRefChanged: onMaximalRefChanged,
      supersetOptions: filteredSupersetOptions,
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

/// Dual day CTAs shared by the in-scroll trailing row and sticky phone footer.
class SessionDayBottomCtas extends StatelessWidget {
  const SessionDayBottomCtas({
    super.key,
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
