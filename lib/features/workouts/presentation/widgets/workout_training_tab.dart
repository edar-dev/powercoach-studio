import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/exercise_prescription_scope.dart';
import 'training_week_day_panel.dart';
import 'workout_dashed_button.dart';
import 'workout_training_helpers.dart';

class WorkoutTrainingTab extends StatelessWidget {
  const WorkoutTrainingTab({
    super.key,
    required this.theme,
    required this.cs,
    this.embeddedInTab = false,
    required this.weeks,
    required this.selectedWeekIndex,
    required this.selectedDayIndex,
    required this.onNewWeek,
    required this.onCloneWeek,
    required this.onDeleteWeek,
    required this.onRenameWeek,
    required this.onAddDay,
    required this.onRenameDay,
    required this.onDeleteDay,
    required this.onAddExercise,
    required this.onRemoveExercise,
    required this.onMoveExercise,
    required this.onUpdateExercise,
    required this.onAddSetToExercise,
    required this.onUpdateExerciseSet,
    required this.onRemoveExerciseSet,
    required this.onAssignToSuperset,
    required this.onRemoveFromSuperset,
    required this.onAddExerciseToSuperset,
    required this.onSelectWeek,
    required this.onSelectDay,
    required this.onUpdateScheduledWeekday,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final bool embeddedInTab;
  final List<Week> weeks;
  final int selectedWeekIndex;
  final int selectedDayIndex;
  final VoidCallback onNewWeek;
  final void Function(int) onCloneWeek;
  final void Function(int) onDeleteWeek;
  final void Function(int, String) onRenameWeek;
  final void Function(int) onAddDay;
  final void Function(int, int, String) onRenameDay;
  final void Function(int, int) onDeleteDay;
  final void Function(int, int) onAddExercise;
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
  final void Function(int, int, String, String) onAssignToSuperset;
  final void Function(int, int, String) onRemoveFromSuperset;
  final void Function(int, int, String) onAddExerciseToSuperset;
  final void Function(int) onSelectWeek;
  final void Function(int) onSelectDay;
  final void Function(int weekIndex, int dayIndex, int weekday)
  onUpdateScheduledWeekday;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, embeddedInTab ? 8 : 24, 12, 8),
      child: TrainingWeekDayPanel(
        theme: theme,
        cs: cs,
        weeks: weeks,
        selectedWeekIndex: selectedWeekIndex,
        selectedDayIndex: selectedDayIndex,
        onSelectWeek: onSelectWeek,
        onSelectDay: onSelectDay,
        onNewWeek: onNewWeek,
        onCloneWeek: onCloneWeek,
        onDeleteWeek: onDeleteWeek,
        onEditWeek: (weekIndex) {
          final week = weeks[weekIndex];
          showRenameWeekDialog(
            context,
            week.name,
            (name) => onRenameWeek(weekIndex, name),
          );
        },
        onAddDay: onAddDay,
        onEditDay: (weekIndex, dayIndex) {
          final day = weeks[weekIndex].days[dayIndex];
          showRenameDayDialog(
            context,
            day.name,
            (name) => onRenameDay(weekIndex, dayIndex, name),
          );
        },
        onDeleteDay: onDeleteDay,
        onUpdateScheduledWeekday: onUpdateScheduledWeekday,
        onAddExercise: onAddExercise,
        exerciseListBuilder: (context, weekIndex, dayIndex, day) {
          final l10n = AppLocalizations.of(context);
          final partition = partitionExercisesBySuperset(day.exercises);
          return ListView(
            padding: const EdgeInsets.only(bottom: 96, right: 4),
            children: [
              for (final entry in partition.asMap().entries) ...[
                if (entry.value is Exercise)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildExerciseCard(
                      context,
                      weekIndex: weekIndex,
                      dayIndex: dayIndex,
                      day: day,
                      exercise: entry.value as Exercise,
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _WorkoutSupersetBlock(
                      theme: theme,
                      cs: cs,
                      weekIndex: weekIndex,
                      dayIndex: dayIndex,
                      exercises: entry.value as List<Exercise>,
                      supersetGroupId:
                          (entry.value as List<Exercise>).isNotEmpty &&
                              (entry.value as List<Exercise>)
                                      .first
                                      .supersetGroupId !=
                                  null
                          ? (entry.value as List<Exercise>)
                                .first
                                .supersetGroupId!
                          : null,
                      onAddExercise: () => onAddExercise(weekIndex, dayIndex),
                      onAddExerciseToSuperset: onAddExerciseToSuperset,
                      onRemoveExercise: onRemoveExercise,
                      onMoveExercise: onMoveExercise,
                      onUpdateExercise: onUpdateExercise,
                      onAddSetToExercise: onAddSetToExercise,
                      onUpdateExerciseSet: onUpdateExerciseSet,
                      onRemoveExerciseSet: onRemoveExerciseSet,
                      onAssignToSuperset: onAssignToSuperset,
                      onRemoveFromSuperset: onRemoveFromSuperset,
                      supersetOptionsForDay: getSupersetGroupOptions(day),
                    ),
                  ),
              ],
              if (day.exercises.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    l10n.workoutBuilderExerciseCount(0),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context, {
    required int weekIndex,
    required int dayIndex,
    required Day day,
    required Exercise exercise,
  }) {
    final ex = exercise;
    return _WorkoutExerciseCard(
      theme: theme,
      cs: cs,
      exercise: ex,
      compact: true,
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

class _WorkoutSupersetBlock extends StatelessWidget {
  const _WorkoutSupersetBlock({
    required this.theme,
    required this.cs,
    required this.weekIndex,
    required this.dayIndex,
    required this.exercises,
    this.supersetGroupId,
    required this.onAddExercise,
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
  final ColorScheme cs;
  final int weekIndex;
  final int dayIndex;
  final List<Exercise> exercises;
  final String? supersetGroupId;
  final VoidCallback onAddExercise;
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
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        border: Border(left: BorderSide(color: StitchM3Theme.accent, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, size: 18, color: StitchM3Theme.accent),
              const SizedBox(width: 8),
              Text(
                l10n.workoutBuilderSuperSetHeading,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: StitchM3Theme.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...exercises.map(
            (ex) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _WorkoutExerciseCard(
                theme: theme,
                cs: cs,
                exercise: ex,
                compact: false,
                linked: true,
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
                    ? (groupId) => onAssignToSuperset!(
                        weekIndex,
                        dayIndex,
                        ex.id,
                        groupId,
                      )
                    : null,
                onRemoveFromSuperset: onRemoveFromSuperset != null
                    ? () => onRemoveFromSuperset!(weekIndex, dayIndex, ex.id)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          WorkoutDashedButton(
            icon: Icons.add,
            label: l10n.workoutBuilderAddExercise,
            onPressed:
                supersetGroupId != null && onAddExerciseToSuperset != null
                ? () => onAddExerciseToSuperset!(
                    weekIndex,
                    dayIndex,
                    supersetGroupId!,
                  )
                : onAddExercise,
          ),
        ],
      ),
    );
  }
}

class _WorkoutExerciseCard extends StatelessWidget {
  const _WorkoutExerciseCard({
    required this.theme,
    required this.cs,
    required this.exercise,
    required this.compact,
    this.linked = false,
    this.onRemove,
    this.onMoveUp,
    this.onMoveDown,
    this.onEdit,
    this.onAddSet,
    this.onUpdateSet,
    this.onRemoveSet,
    this.supersetOptions = const [],
    this.onAssignToSuperset,
    this.onRemoveFromSuperset,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final Exercise exercise;
  final bool compact;
  final bool linked;
  final VoidCallback? onRemove;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final void Function(
    String name,
    String sets,
    String reps,
    String rpe,
    String note, {
    List<ExerciseSet>? setDetails,
    String? shortName,
    ExercisePrescriptionScope? prescriptionScope,
  })?
  onEdit;
  final VoidCallback? onAddSet;
  final void Function(
    int setIndex,
    String sets,
    String reps,
    String load,
    String note,
  )?
  onUpdateSet;
  final void Function(int setIndex)? onRemoveSet;
  final List<({String id, String label})> supersetOptions;
  final void Function(String groupId)? onAssignToSuperset;
  final VoidCallback? onRemoveFromSuperset;

  void _openEditDialog(BuildContext context) {
    if (onEdit == null) return;
    showEditExerciseDialog(
      context,
      theme,
      cs,
      exercise.name,
      exercise.sets,
      exercise.reps,
      exercise.rpe,
      exercise.note,
      (name, sets, reps, rpe, note) => onEdit!(name, sets, reps, rpe, note),
      initialShortName: exercise.shortName,
      initialScope: exercise.prescriptionScope,
      initialSetDetails: exercise.effectiveSetDetails,
      onSaveWithSets:
          (
            name,
            note,
            setDetails, {
            shortName = '',
            prescriptionScope = ExercisePrescriptionScope.perWeek,
          }) => onEdit!(
            name,
            exercise.sets,
            exercise.reps,
            exercise.rpe,
            note,
            setDetails: setDetails,
            shortName: shortName,
            prescriptionScope: prescriptionScope,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final details = exercise.effectiveSetDetails;
    final hasMultipleSets = details.length > 1;
    final l10n = AppLocalizations.of(context);
    final setsSummary = hasMultipleSets
        ? details.map((s) => s.displayText).join(' · ')
        : details.first.displayText;
    final hasMenu =
        onEdit != null ||
        onRemove != null ||
        onMoveUp != null ||
        onMoveDown != null ||
        onAssignToSuperset != null ||
        onRemoveFromSuperset != null;

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
      child: InkWell(
        onTap: onEdit != null ? () => _openEditDialog(context) : null,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            border: Border.all(color: cs.outline.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                exercise.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                            if (linked)
                              Icon(
                                Icons.link,
                                size: 16,
                                color: StitchM3Theme.accent,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          setsSummary,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasMenu)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: cs.onSurfaceVariant,
                      ),
                      padding: EdgeInsets.zero,
                      tooltip: l10n.workoutBuilderExerciseMenuTooltip,
                      onSelected: (value) {
                        if (value == 'edit') {
                          _openEditDialog(context);
                        } else if (value == 'up') {
                          onMoveUp?.call();
                        } else if (value == 'down') {
                          onMoveDown?.call();
                        } else if (value == 'delete') {
                          onRemove?.call();
                        } else if (value == 'new') {
                          onAssignToSuperset!(
                            'ss_${DateTime.now().millisecondsSinceEpoch}',
                          );
                        } else if (value.startsWith('group:')) {
                          onAssignToSuperset!(value.substring(6));
                        } else if (value == 'remove_ss') {
                          onRemoveFromSuperset?.call();
                        }
                      },
                      itemBuilder: (ctx) {
                        final menuL10n = AppLocalizations.of(ctx);
                        return [
                          if (onEdit != null)
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(menuL10n.workoutBuilderEditExercise),
                            ),
                          if (onMoveUp != null)
                            PopupMenuItem(
                              value: 'up',
                              child: Text(menuL10n.workoutBuilderMoveUp),
                            ),
                          if (onMoveDown != null)
                            PopupMenuItem(
                              value: 'down',
                              child: Text(menuL10n.workoutBuilderMoveDown),
                            ),
                          if (onAssignToSuperset != null)
                            PopupMenuItem(
                              value: 'new',
                              child: Text(menuL10n.workoutBuilderNewSuperset),
                            ),
                          ...supersetOptions.map(
                            (o) => PopupMenuItem(
                              value: 'group:${o.id}',
                              child: Text(
                                o.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (onRemoveFromSuperset != null)
                            PopupMenuItem(
                              value: 'remove_ss',
                              child: Text(
                                menuL10n.workoutBuilderRemoveFromSuperset,
                                style: const TextStyle(
                                  color: StitchM3Theme.danger,
                                ),
                              ),
                            ),
                          if (onRemove != null)
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                menuL10n.workoutBuilderDeleteExercise,
                                style: const TextStyle(
                                  color: StitchM3Theme.danger,
                                ),
                              ),
                            ),
                        ];
                      },
                    ),
                ],
              ),
              if (!compact && hasMultipleSets)
                ...details.asMap().entries.map((entry) {
                  final i = entry.key;
                  final s = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      top: i == 0 ? 8 : 4,
                      bottom: i < details.length - 1 ? 4 : 0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SetRepCell(
                            theme: theme,
                            cs: cs,
                            label: l10n.workoutBuilderSetsLabel,
                            value: s.displayText,
                            compact: compact,
                          ),
                        ),
                        if (onUpdateSet != null)
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () => showEditSetDialog(
                              context,
                              theme,
                              cs,
                              s.sets,
                              s.reps,
                              s.rpe,
                              s.note,
                              (sets, reps, load, note) =>
                                  onUpdateSet!(i, sets, reps, load, note),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              if (!compact && onAddSet != null) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onAddSet,
                    icon: Icon(
                      Icons.add,
                      size: 16,
                      color: StitchM3Theme.accent,
                    ),
                    label: Text(l10n.workoutBuilderAddSet),
                  ),
                ),
              ],
              if (exercise.note.isNotEmpty ||
                  (!compact && exercise.note.isEmpty)) ...[
                const SizedBox(height: 4),
                Text(
                  exercise.note.isNotEmpty
                      ? exercise.note
                      : l10n.workoutBuilderNotePlaceholder,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: exercise.note.isNotEmpty
                        ? cs.onSurface
                        : cs.onSurfaceVariant,
                    fontStyle: exercise.note.isEmpty ? FontStyle.italic : null,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SetRepCell extends StatelessWidget {
  const _SetRepCell({
    required this.theme,
    required this.cs,
    required this.label,
    required this.value,
    required this.compact,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: EdgeInsets.all(compact ? 8 : 12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
            border: Border.all(color: cs.outline),
          ),
          child: Center(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
