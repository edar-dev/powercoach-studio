import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../domain/density_block.dart';
import '../../domain/exercise_prescription_scope.dart';
import '../../data/workout_routine_model.dart';
import 'workout_training_helpers.dart';

/// Stitch-aligned exercise card used only inside the session edit modal.
///
/// Intentionally omits set-type / rest / status / 1RM / warm-up columns that
/// are not persisted in [ExerciseSet].
class SessionExerciseEditorCard extends StatefulWidget {
  const SessionExerciseEditorCard({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.exercise,
    required this.index,
    required this.expanded,
    required this.onExpandedChanged,
    this.athleteName,
    this.onDuplicate,
    this.onRemove,
    this.onMoveUp,
    this.onMoveDown,
    this.onEdit,
    this.onAddSet,
    this.onDuplicateLastSet,
    this.onUpdateSet,
    this.onRemoveSet,
    this.supersetOptions = const [],
    this.onAssignToSuperset,
    this.onRemoveFromSuperset,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final Exercise exercise;
  final int index;
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
  final String? athleteName;
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
  final VoidCallback? onDuplicateLastSet;
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
  final void Function(String groupId, {DensityBlockConfig? densityConfig})?
  onAssignToSuperset;
  final VoidCallback? onRemoveFromSuperset;

  static const Color _cardBg = Color(0xFF151D2E);
  static const Color _cardBorder = Color(0xFF28354D);
  static const Color _inputBg = Color(0xFF0F172A);

  @override
  State<SessionExerciseEditorCard> createState() =>
      _SessionExerciseEditorCardState();
}

class _SessionExerciseEditorCardState extends State<SessionExerciseEditorCard> {
  late final TextEditingController _noteController;
  Timer? _noteDebounce;
  bool _showSavedHint = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.exercise.note);
  }

  @override
  void didUpdateWidget(covariant SessionExerciseEditorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.id != widget.exercise.id ||
        (oldWidget.exercise.note != widget.exercise.note &&
            widget.exercise.note != _noteController.text)) {
      _noteController.text = widget.exercise.note;
    }
  }

  @override
  void dispose() {
    _noteDebounce?.cancel();
    _noteController.dispose();
    super.dispose();
  }

  void _onNoteChanged(String value) {
    _noteDebounce?.cancel();
    _noteDebounce = Timer(const Duration(milliseconds: 450), () {
      final onEdit = widget.onEdit;
      if (onEdit == null) return;
      final ex = widget.exercise;
      onEdit(
        ex.name,
        ex.sets,
        ex.reps,
        ex.rpe,
        value,
        setDetails: ex.setDetails,
        shortName: ex.shortName,
        prescriptionScope: ex.prescriptionScope,
      );
      if (!mounted) return;
      setState(() => _showSavedHint = true);
      Future<void>.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showSavedHint = false);
      });
    });
  }

  void _openEditDialog(BuildContext context, {bool focusNote = false}) {
    final onEdit = widget.onEdit;
    if (onEdit == null) return;
    final exercise = widget.exercise;
    showEditExerciseDialog(
      context,
      widget.theme,
      widget.colorScheme,
      exercise.name,
      exercise.sets,
      exercise.reps,
      exercise.rpe,
      exercise.note,
      (name, sets, reps, rpe, note) => onEdit(name, sets, reps, rpe, note),
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
          }) => onEdit(
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
    final l10n = AppLocalizations.of(context);
    final theme = widget.theme;
    final cs = widget.colorScheme;
    final exercise = widget.exercise;
    final details = exercise.effectiveSetDetails;
    final hasMenu =
        widget.onEdit != null ||
        widget.onDuplicate != null ||
        widget.onRemove != null ||
        widget.onMoveUp != null ||
        widget.onMoveDown != null ||
        widget.onAssignToSuperset != null ||
        widget.onRemoveFromSuperset != null;
    final athlete = (widget.athleteName ?? '').trim();
    final notesLabel = athlete.isEmpty
        ? l10n.workoutSessionTechnicalNotes
        : l10n.workoutSessionTechnicalNotesForAthlete(athlete);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: SessionExerciseEditorCard._cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SessionExerciseEditorCard._cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            child: Row(
              children: [
                Icon(
                  Icons.drag_indicator,
                  size: 18,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.55),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: StitchM3Theme.accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: StitchM3Theme.accent.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    '${widget.index}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: StitchM3Theme.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () =>
                        widget.onExpandedChanged(!widget.expanded),
                    borderRadius: BorderRadius.circular(8),
                    child: Text(
                      exercise.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  tooltip: widget.expanded
                      ? MaterialLocalizations.of(context).expandedIconTapHint
                      : MaterialLocalizations.of(context).collapsedIconTapHint,
                  icon: Icon(
                    widget.expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: cs.onSurfaceVariant,
                  ),
                  onPressed: () =>
                      widget.onExpandedChanged(!widget.expanded),
                ),
                if (hasMenu) _buildMenu(l10n),
              ],
            ),
          ),
          if (widget.expanded) ...[
            const Divider(height: 1, color: Color(0xFF28354D)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SetTableHeader(theme: theme, l10n: l10n),
                  const SizedBox(height: 6),
                  ...details.asMap().entries.map((entry) {
                    final i = entry.key;
                    final s = entry.value;
                    return _SetTableRow(
                      theme: theme,
                      colorScheme: cs,
                      l10n: l10n,
                      setNumber: i + 1,
                      set: s,
                      canRemove: details.length > 1 && widget.onRemoveSet != null,
                      onEdit: widget.onUpdateSet == null
                          ? null
                          : () => showEditSetDialog(
                                context,
                                theme,
                                cs,
                                s.sets,
                                s.reps,
                                s.rpe,
                                s.note,
                                (sets, reps, load, note) =>
                                    widget.onUpdateSet!(
                                      i,
                                      sets,
                                      reps,
                                      load,
                                      note,
                                    ),
                              ),
                      onRemove: widget.onRemoveSet == null
                          ? null
                          : () => widget.onRemoveSet!(i),
                    );
                  }),
                  if (widget.onAddSet != null ||
                      widget.onDuplicateLastSet != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (widget.onAddSet != null)
                            TextButton.icon(
                              onPressed: widget.onAddSet,
                              icon: const Icon(Icons.add, size: 16),
                              label: Text(l10n.workoutBuilderAddSet),
                              style: TextButton.styleFrom(
                                foregroundColor: StitchM3Theme.accent,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          if (widget.onDuplicateLastSet != null)
                            TextButton(
                              onPressed: widget.onDuplicateLastSet,
                              style: TextButton.styleFrom(
                                foregroundColor: cs.onSurfaceVariant,
                                visualDensity: VisualDensity.compact,
                              ),
                              child: Text(
                                details.isEmpty
                                    ? l10n.workoutSessionDuplicateLastSet
                                    : l10n.workoutSessionDuplicateLastSetN(
                                        details.length,
                                      ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          notesLabel,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_showSavedHint)
                        Text(
                          l10n.workoutSessionSavedHint,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF34D399),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    onChanged: widget.onEdit == null ? null : _onNoteChanged,
                    enabled: widget.onEdit != null,
                    maxLines: 3,
                    minLines: 2,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: SessionExerciseEditorCard._inputBg,
                      hintText: l10n.workoutBuilderNotePlaceholder,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF28354D)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF28354D)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: StitchM3Theme.accent,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenu(AppLocalizations l10n) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: 22,
        color: widget.colorScheme.onSurfaceVariant,
      ),
      iconSize: 22,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      tooltip: l10n.workoutBuilderExerciseMenuTooltip,
      onSelected: (value) {
        if (value == 'edit') {
          _openEditDialog(context);
        } else if (value == 'duplicate') {
          widget.onDuplicate?.call();
        } else if (value == 'up') {
          widget.onMoveUp?.call();
        } else if (value == 'down') {
          widget.onMoveDown?.call();
        } else if (value == 'delete') {
          widget.onRemove?.call();
        } else if (value == 'new') {
          widget.onAssignToSuperset!(
            'ss_${DateTime.now().millisecondsSinceEpoch}',
          );
        } else if (value == 'new_circuit') {
          widget.onAssignToSuperset!(
            'ss_${DateTime.now().millisecondsSinceEpoch}',
            densityConfig: DensityBlockConfig.defaultCircuit,
          );
        } else if (value == 'new_emom') {
          widget.onAssignToSuperset!(
            'ss_${DateTime.now().millisecondsSinceEpoch}',
            densityConfig: DensityBlockConfig.defaultEmom,
          );
        } else if (value.startsWith('group:')) {
          widget.onAssignToSuperset!(value.substring(6));
        } else if (value == 'remove_ss') {
          widget.onRemoveFromSuperset?.call();
        }
      },
      itemBuilder: (ctx) {
        final menuL10n = AppLocalizations.of(ctx);
        return [
          if (widget.onEdit != null)
            PopupMenuItem(
              value: 'edit',
              child: Text(menuL10n.workoutBuilderEditExercise),
            ),
          if (widget.onMoveUp != null)
            PopupMenuItem(
              value: 'up',
              child: Text(menuL10n.workoutBuilderMoveUp),
            ),
          if (widget.onMoveDown != null)
            PopupMenuItem(
              value: 'down',
              child: Text(menuL10n.workoutBuilderMoveDown),
            ),
          if (widget.onDuplicate != null)
            PopupMenuItem(
              value: 'duplicate',
              child: Text(menuL10n.workoutBuilderDuplicateExercise),
            ),
          if (widget.onAssignToSuperset != null)
            PopupMenuItem(
              value: 'new',
              child: Text(menuL10n.workoutBuilderNewSuperset),
            ),
          if (widget.onAssignToSuperset != null)
            PopupMenuItem(
              value: 'new_circuit',
              child: Text(menuL10n.workoutBuilderNewCircuit),
            ),
          if (widget.onAssignToSuperset != null)
            PopupMenuItem(
              value: 'new_emom',
              child: Text(menuL10n.workoutBuilderNewEmom),
            ),
          ...widget.supersetOptions.map(
            (o) => PopupMenuItem(
              value: 'group:${o.id}',
              child: Text(o.label, overflow: TextOverflow.ellipsis),
            ),
          ),
          if (widget.onRemoveFromSuperset != null)
            PopupMenuItem(
              value: 'remove_ss',
              child: Text(
                menuL10n.workoutBuilderRemoveFromSuperset,
                style: const TextStyle(color: StitchM3Theme.danger),
              ),
            ),
          if (widget.onRemove != null)
            PopupMenuItem(
              value: 'delete',
              child: Text(
                menuL10n.workoutBuilderDeleteExercise,
                style: const TextStyle(color: StitchM3Theme.danger),
              ),
            ),
        ];
      },
    );
  }
}

class _SetTableHeader extends StatelessWidget {
  const _SetTableHeader({required this.theme, required this.l10n});

  final ThemeData theme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final style = theme.textTheme.labelSmall?.copyWith(
      color: const Color(0xFF94A3B8),
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );
    return Row(
      children: [
        SizedBox(width: 40, child: Text(l10n.workoutSessionColSet, style: style)),
        Expanded(child: Text(l10n.workoutSessionColReps, style: style)),
        Expanded(flex: 2, child: Text(l10n.workoutSessionColLoadRpe, style: style)),
        Expanded(child: Text(l10n.workoutSessionColNote, style: style)),
        const SizedBox(width: 88),
      ],
    );
  }
}

class _SetTableRow extends StatelessWidget {
  const _SetTableRow({
    required this.theme,
    required this.colorScheme,
    required this.l10n,
    required this.setNumber,
    required this.set,
    required this.canRemove,
    this.onEdit,
    this.onRemove,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final int setNumber;
  final ExerciseSet set;
  final bool canRemove;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final cellStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w500,
    );
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final reps = set.reps.trim().isEmpty ? '—' : set.reps.trim();
    final load = set.rpe.trim().isEmpty ? '—' : set.rpe.trim();
    final note = set.note.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '$setNumber',
              style: cellStyle?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(reps, style: cellStyle)),
          Expanded(flex: 2, child: Text(load, style: cellStyle)),
          Expanded(
            child: Text(
              note.isEmpty ? '—' : note,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: note.isEmpty ? muted : cellStyle,
            ),
          ),
          SizedBox(
            width: 88,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  IconButton(
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: l10n.workoutBuilderEditSetTitle,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: onEdit,
                  ),
                if (canRemove && onRemove != null)
                  IconButton(
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).deleteButtonTooltip,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: StitchM3Theme.danger,
                    onPressed: onRemove,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
