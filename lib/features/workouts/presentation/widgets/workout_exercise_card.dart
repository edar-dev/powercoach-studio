import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../domain/exercise_prescription_scope.dart';
import '../../data/workout_routine_model.dart';
import 'workout_training_helpers.dart';

/// Single exercise row/card in the workout training tab.
class WorkoutExerciseCard extends StatelessWidget {
  const WorkoutExerciseCard({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.exercise,
    required this.compact,
    this.linked = false,
    this.onDuplicate,
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
  final ColorScheme colorScheme;
  final Exercise exercise;
  final bool compact;
  final bool linked;
  final VoidCallback? onDuplicate;
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
      colorScheme,
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
        onDuplicate != null ||
        onRemove != null ||
        onMoveUp != null ||
        onMoveDown != null ||
        onAssignToSuperset != null ||
        onRemoveFromSuperset != null;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
      child: InkWell(
        onTap: onEdit != null ? () => _openEditDialog(context) : null,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.6)),
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
                                  color: colorScheme.onSurface,
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
                            color: colorScheme.onSurfaceVariant,
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
                        color: colorScheme.onSurfaceVariant,
                      ),
                      padding: EdgeInsets.zero,
                      tooltip: l10n.workoutBuilderExerciseMenuTooltip,
                      onSelected: (value) {
                        if (value == 'edit') {
                          _openEditDialog(context);
                        } else if (value == 'duplicate') {
                          onDuplicate?.call();
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
                          if (onDuplicate != null)
                            PopupMenuItem(
                              value: 'duplicate',
                              child: Text(
                                menuL10n.workoutBuilderDuplicateExercise,
                              ),
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
                          child: WorkoutSetRepCell(
                            theme: theme,
                            colorScheme: colorScheme,
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
                              colorScheme,
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
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
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

/// Set/rep summary cell inside an exercise card.
class WorkoutSetRepCell extends StatelessWidget {
  const WorkoutSetRepCell({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.label,
    required this.value,
    required this.compact,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
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
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: EdgeInsets.all(compact ? 8 : 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Center(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
