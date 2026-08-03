import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../domain/exercise_prescription_scope.dart';
import '../../data/workout_routine_model.dart';
import 'workout_training_helpers.dart';

/// Flat typographic exercise row for the session sheet.
class WorkoutExerciseCard extends StatelessWidget {
  const WorkoutExerciseCard({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.exercise,
    required this.expanded,
    required this.onExpandedChanged,
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
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
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

  void _openEditDialog(BuildContext context, {bool focusNote = false}) {
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
      focusNote: focusNote,
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

  bool get _hasAnySetNote =>
      exercise.effectiveSetDetails.any((s) => s.note.trim().isNotEmpty);

  String _prescriptionLabel(AppLocalizations l10n) {
    final details = exercise.effectiveSetDetails;
    final texts = details
        .map((s) => s.displayText.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (texts.isEmpty) {
      return l10n.workoutBuilderPrescriptionPlaceholder;
    }
    // Bare set count without reps (e.g. "1") is not a useful prescription.
    if (texts.length == 1 && RegExp(r'^\d+$').hasMatch(texts.first)) {
      return l10n.workoutBuilderPrescriptionPlaceholder;
    }
    return texts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final details = exercise.effectiveSetDetails;
    final l10n = AppLocalizations.of(context);
    final prescription = _prescriptionLabel(l10n);
    final isPlaceholder =
        prescription == l10n.workoutBuilderPrescriptionPlaceholder;
    final hasMenu =
        onEdit != null ||
        onDuplicate != null ||
        onRemove != null ||
        onMoveUp != null ||
        onMoveDown != null ||
        onAssignToSuperset != null ||
        onRemoveFromSuperset != null;
    final secondaryColor = colorScheme.onSurface.withValues(alpha: 0.72);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => onExpandedChanged(!expanded),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            exercise.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (linked) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.link,
                            size: 16,
                            color: StitchM3Theme.accent,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (!expanded)
                Flexible(
                  child: Text(
                    prescription,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isPlaceholder
                          ? secondaryColor
                          : colorScheme.onSurface,
                      fontStyle:
                          isPlaceholder ? FontStyle.italic : FontStyle.normal,
                      fontWeight:
                          isPlaceholder ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              IconButton(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                padding: EdgeInsets.zero,
                tooltip: expanded
                    ? MaterialLocalizations.of(context).expandedIconTapHint
                    : MaterialLocalizations.of(context).collapsedIconTapHint,
                icon: Icon(
                  expanded ? Icons.expand_less : Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () => onExpandedChanged(!expanded),
              ),
              if (hasMenu)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 24,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  iconSize: 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
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
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...details.asMap().entries.map((entry) {
                  final i = entry.key;
                  final s = entry.value;
                  final setLabel = s.displayText.trim().isEmpty
                      ? l10n.workoutBuilderPrescriptionPlaceholder
                      : s.displayText;
                  final setNote = s.note.trim();
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: i < details.length - 1 ? 8 : 0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                setLabel,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (setNote.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  setNote,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: secondaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (onUpdateSet != null)
                          IconButton(
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            padding: EdgeInsets.zero,
                            tooltip: l10n.workoutBuilderEditSetTitle,
                            icon: const Icon(Icons.edit_outlined, size: 20),
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
                        if (onRemoveSet != null && details.length > 1)
                          IconButton(
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            padding: EdgeInsets.zero,
                            tooltip: MaterialLocalizations.of(
                              context,
                            ).deleteButtonTooltip,
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 20,
                            ),
                            color: StitchM3Theme.danger,
                            onPressed: () => onRemoveSet!(i),
                          ),
                      ],
                    ),
                  );
                }),
                if (onAddSet != null)
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
                if (exercise.note.trim().isNotEmpty || !_hasAnySetNote)
                  InkWell(
                    onTap: onEdit != null
                        ? () => _openEditDialog(context, focusNote: true)
                        : null,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        exercise.note.trim().isNotEmpty
                            ? exercise.note
                            : l10n.workoutBuilderNotePlaceholder,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: exercise.note.trim().isNotEmpty
                              ? colorScheme.onSurface
                              : secondaryColor,
                          fontStyle: exercise.note.trim().isEmpty
                              ? FontStyle.italic
                              : null,
                          fontWeight: exercise.note.trim().isEmpty
                              ? FontWeight.w500
                              : null,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Divider(
          height: 1,
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ],
    );
  }
}

/// Set/rep summary cell (kept for any remaining callers).
class WorkoutSetRepCell extends StatelessWidget {
  const WorkoutSetRepCell({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.label,
    required this.value,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.72),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
