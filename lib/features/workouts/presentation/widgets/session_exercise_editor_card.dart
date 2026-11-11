import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../core/ui/haptics.dart';
import '../../../../core/ui/widgets/keyboard_dismiss.dart';
import '../../../../core/ui/widgets/truncated_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customers/data/customer_maximal_repository.dart';
import '../../../customers/data/customer_measurement_repository.dart';
import '../../domain/collapsed_prescription_summary.dart';
import '../../domain/exercise_prescription_scope.dart';
import '../../domain/maximal_kg_resolver.dart';
import '../../domain/maximal_ref.dart';
import '../../domain/set_load_display.dart';
import '../../data/workout_routine_model.dart';
import 'workout_session_card_chrome.dart';
import 'workout_training_helpers.dart';

/// Training vs mobility presentation for the shared session editor card.
enum SessionExerciseEditorVariant { training, mobility }

/// Stitch-aligned exercise card used only inside the session edit modal.
///
/// Intentionally omits set-type / rest / status / 1RM / warm-up columns that
/// are not persisted in [ExerciseSet].
///
/// When [variant] is [SessionExerciseEditorVariant.mobility], the expanded body
/// uses the same set table + notes as training; supersets stay disabled.
class SessionExerciseEditorCard extends StatefulWidget {
  const SessionExerciseEditorCard({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.exercise,
    required this.index,
    required this.expanded,
    required this.onExpandedChanged,
    this.variant = SessionExerciseEditorVariant.training,
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
    this.customerId,
    this.onMaximalRefChanged,
    this.resolvedMaximalKg,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final Exercise exercise;
  final int index;
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
  final SessionExerciseEditorVariant variant;
  final String? athleteName;
  /// Customer id for Massimali resolve in the set editor (null in sandbox).
  final String? customerId;
  /// Persists [Exercise.maximalRef] when the set editor associate sheet changes it.
  final void Function(MaximalRef? ref, {required bool clear})?
      onMaximalRefChanged;
  /// Optional already-resolved maximal kg for TARGET % display (no per-row async).
  final double? resolvedMaximalKg;
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
  final void Function(String groupId)? onAssignToSuperset;
  final VoidCallback? onRemoveFromSuperset;

  @override
  State<SessionExerciseEditorCard> createState() =>
      _SessionExerciseEditorCardState();
}

class _SessionExerciseEditorCardState extends State<SessionExerciseEditorCard> {
  late final TextEditingController _noteController;
  Timer? _noteDebounce;
  bool _showSavedHint = false;
  double? _loadedMaximalKg;
  int _maximalLoadToken = 0;

  double? get _effectiveMaximalKg =>
      widget.resolvedMaximalKg ?? _loadedMaximalKg;

  bool get _isMobility =>
      widget.variant == SessionExerciseEditorVariant.mobility;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.exercise.note);
    if (widget.expanded) {
      unawaited(_loadResolvedMaximalKg());
    }
  }

  @override
  void didUpdateWidget(covariant SessionExerciseEditorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.id != widget.exercise.id ||
        (oldWidget.exercise.note != widget.exercise.note &&
            widget.exercise.note != _noteController.text)) {
      _noteController.text = widget.exercise.note;
    }
    final refChanged =
        oldWidget.exercise.maximalRef != widget.exercise.maximalRef ||
            oldWidget.customerId != widget.customerId ||
            oldWidget.resolvedMaximalKg != widget.resolvedMaximalKg;
    if (refChanged) {
      _loadedMaximalKg = null;
    }
    if (widget.expanded &&
        (refChanged || !oldWidget.expanded) &&
        widget.resolvedMaximalKg == null) {
      unawaited(_loadResolvedMaximalKg());
    }
  }

  @override
  void dispose() {
    _noteDebounce?.cancel();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadResolvedMaximalKg() async {
    final customerId = widget.customerId;
    final ref = widget.exercise.maximalRef;
    if (widget.resolvedMaximalKg != null ||
        customerId == null ||
        customerId.isEmpty ||
        ref == null) {
      if (mounted && _loadedMaximalKg != null) {
        setState(() => _loadedMaximalKg = null);
      }
      return;
    }
    final token = ++_maximalLoadToken;
    try {
      final measurements =
          await CustomerMeasurementRepository().getByCustomerId(customerId);
      final maximals =
          await CustomerMaximalRepository().getByCustomerId(customerId);
      if (!mounted || token != _maximalLoadToken) return;
      final kg = MaximalKgResolver.resolve(
        ref: ref,
        measurements: measurements,
        customs: maximals
            .map((m) => MaximalCustomKg(id: m.id, weightKg: m.weightKg))
            .toList(growable: false),
      );
      if (!mounted || token != _maximalLoadToken) return;
      setState(() => _loadedMaximalKg = kg);
    } catch (e, stack) {
      debugPrint('Session set table maximal resolve failed: $e\n$stack');
      if (!mounted || token != _maximalLoadToken) return;
      setState(() => _loadedMaximalKg = null);
    }
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

  /// Collapsed header prescription, matching day-card preview.
  String _prescriptionSubtitle() =>
      collapsedPrescriptionSummary(widget.exercise.effectiveSetDetails);

  /// Mobility collapsed secondary line: prescription summary, else note, else shortName.
  String _mobilityCollapsedSubtitle() {
    final rx = collapsedPrescriptionSummary(
      widget.exercise.effectiveSetDetails,
    );
    if (rx.isNotEmpty) return rx;
    final subtitle = widget.exercise.note.trim();
    if (subtitle.isNotEmpty) return subtitle;
    return widget.exercise.shortName.trim();
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
    final hasMenu = widget.onEdit != null ||
        widget.onDuplicate != null ||
        widget.onRemove != null ||
        widget.onMoveUp != null ||
        widget.onMoveDown != null ||
        (!_isMobility &&
            (widget.onAssignToSuperset != null ||
                widget.onRemoveFromSuperset != null));
    final athlete = (widget.athleteName ?? '').trim();
    final notesLabel = athlete.isEmpty
        ? l10n.workoutSessionTechnicalNotes
        : l10n.workoutSessionTechnicalNotesForAthlete(athlete);
    final collapsedRx = widget.expanded
        ? ''
        : (_isMobility ? _mobilityCollapsedSubtitle() : _prescriptionSubtitle());
    final headerTitle = exercise.name;

    return WorkoutSessionCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: WorkoutSessionCardChrome.headerPadding,
            child: Row(
              children: [
                Icon(
                  Icons.drag_indicator,
                  size: 18,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.55),
                ),
                const SizedBox(width: 8),
                WorkoutSessionIndexBadge(index: widget.index, theme: theme),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      AppHaptics.selection();
                      widget.onExpandedChanged(!widget.expanded);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TruncatedText(
                              headerTitle,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                              maxLines: 1,
                              tooltip: headerTitle,
                            ),
                            if (collapsedRx.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  collapsedRx,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
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
                  onPressed: () {
                    AppHaptics.selection();
                    widget.onExpandedChanged(!widget.expanded);
                  },
                ),
                if (hasMenu) _buildMenu(l10n),
              ],
            ),
          ),
          if (widget.expanded) ...[
            const Divider(height: 1, color: WorkoutSessionCardChrome.divider),
            Padding(
              padding: WorkoutSessionCardChrome.expandedPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SetTable(
                    theme: theme,
                    colorScheme: cs,
                    l10n: l10n,
                    details: details,
                    hasMaximalRef: exercise.maximalRef != null,
                    resolvedMaximalKg: _effectiveMaximalKg,
                    onEditSet: widget.onUpdateSet == null
                        ? null
                        : (i, s) => showEditSetDialog(
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
                              exercise: widget.exercise,
                              customerId: widget.customerId,
                              onMaximalRefChanged:
                                  widget.onMaximalRefChanged,
                            ),
                    onRemoveSet: widget.onRemoveSet,
                  ),
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
                                minimumSize: const Size(0, 44),
                              ),
                            ),
                          if (widget.onDuplicateLastSet != null)
                            TextButton(
                              onPressed: widget.onDuplicateLastSet,
                              style: TextButton.styleFrom(
                                foregroundColor: cs.onSurfaceVariant,
                                visualDensity: VisualDensity.compact,
                                minimumSize: const Size(0, 44),
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
                  _buildSecondaryNotesSection(
                    context: context,
                    theme: theme,
                    cs: cs,
                    l10n: l10n,
                    notesLabel: notesLabel,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Note (+ secondary RPE-adjacent controls) — tucked behind "Altro" on phone.
  Widget _buildSecondaryNotesSection({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme cs,
    required AppLocalizations l10n,
    required String notesLabel,
  }) {
    final notesBody = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          textInputAction: TextInputAction.done,
          onTapOutside: (_) => KeyboardDismiss.unfocus(),
          onSubmitted: (_) => KeyboardDismiss.unfocus(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: WorkoutSessionCardChrome.inputBg,
            hintText: l10n.workoutBuilderNotePlaceholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: WorkoutSessionCardChrome.cardBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: WorkoutSessionCardChrome.cardBorder,
              ),
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
    );

    final narrowPhone = !Breakpoints.isTabletOrWider(context) &&
        MediaQuery.sizeOf(context).width < 540;
    if (!narrowPhone) return notesBody;

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 4),
        onExpansionChanged: (_) => AppHaptics.selection(),
        title: Text(
          l10n.workoutBuilderMore,
          style: theme.textTheme.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [notesBody],
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
          if (!_isMobility && widget.onDuplicate != null)
            PopupMenuItem(
              value: 'duplicate',
              child: Text(menuL10n.workoutBuilderDuplicateExercise),
            ),
          if (!_isMobility && widget.onAssignToSuperset != null)
            PopupMenuItem(
              value: 'new',
              child: Text(menuL10n.workoutBuilderNewSuperset),
            ),
          if (!_isMobility)
            ...widget.supersetOptions.map(
              (o) => PopupMenuItem(
                value: 'group:${o.id}',
                child: Text(o.label, overflow: TextOverflow.ellipsis),
              ),
            ),
          if (!_isMobility && widget.onRemoveFromSuperset != null)
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

/// Wide enough for IT `BLOCCO` / EN `BLOCK` header labels.
const double _blockIndexColumnWidth = 68;
const double _colRepsWidth = 64;
const double _colPercentWidth = 72;
const double _colLoadWidth = 64;
const double _colRpeWidth = 48;
const double _colNoteWidth = 96;
const double _colActionsWidth = 88;

/// Min content width before the set table switches to horizontal scroll.
const double _setTableMinScrollWidth = 540;

class _SetTable extends StatelessWidget {
  const _SetTable({
    required this.theme,
    required this.colorScheme,
    required this.l10n,
    required this.details,
    required this.hasMaximalRef,
    this.resolvedMaximalKg,
    this.onEditSet,
    this.onRemoveSet,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final List<ExerciseSet> details;
  final bool hasMaximalRef;
  final double? resolvedMaximalKg;
  final void Function(int index, ExerciseSet set)? onEditSet;
  final void Function(int setIndex)? onRemoveSet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scrollMode = constraints.maxWidth < _setTableMinScrollWidth;
        final table = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SetTableHeader(theme: theme, l10n: l10n, fixedColumns: scrollMode),
            const SizedBox(height: 6),
            ...details.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              return _SetTableRow(
                theme: theme,
                colorScheme: colorScheme,
                l10n: l10n,
                setNumber: i + 1,
                set: s,
                hasMaximalRef: hasMaximalRef,
                resolvedMaximalKg: resolvedMaximalKg,
                canRemove: details.length > 1 && onRemoveSet != null,
                fixedColumns: scrollMode,
                onEdit: onEditSet == null ? null : () => onEditSet!(i, s),
                onRemove: onRemoveSet == null ? null : () => onRemoveSet!(i),
              );
            }),
          ],
        );

        if (!scrollMode) return table;

        return _HorizontallyScrollableWithEdgeFade(
          key: const Key('session_set_table_scroll'),
          minContentWidth: _setTableMinScrollWidth,
          fadeColor: WorkoutSessionCardChrome.cardBg,
          child: table,
        );
      },
    );
  }
}

/// Horizontal scroll with optional left/right edge fades when content overflows.
class _HorizontallyScrollableWithEdgeFade extends StatefulWidget {
  const _HorizontallyScrollableWithEdgeFade({
    super.key,
    required this.child,
    required this.minContentWidth,
    required this.fadeColor,
  });

  final Widget child;
  final double minContentWidth;
  final Color fadeColor;

  @override
  State<_HorizontallyScrollableWithEdgeFade> createState() =>
      _HorizontallyScrollableWithEdgeFadeState();
}

class _HorizontallyScrollableWithEdgeFadeState
    extends State<_HorizontallyScrollableWithEdgeFade> {
  final _controller = ScrollController();
  var _showLeftFade = false;
  var _showRightFade = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateFades);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFades());
  }

  @override
  void dispose() {
    _controller.removeListener(_updateFades);
    _controller.dispose();
    super.dispose();
  }

  void _updateFades() {
    if (!_controller.hasClients) return;
    final pos = _controller.position;
    final showLeft = pos.pixels > 1;
    final showRight = pos.pixels < pos.maxScrollExtent - 1;
    if (showLeft != _showLeftFade || showRight != _showRightFade) {
      setState(() {
        _showLeftFade = showLeft;
        _showRightFade = showRight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Absorb horizontal scroll notifications so a parent RefreshIndicator
    // does not treat sideways drag as vertical overscroll / pull-to-refresh.
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) =>
          notification.metrics.axis == Axis.horizontal,
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            primary: false,
            child: SizedBox(
              width: widget.minContentWidth,
              child: widget.child,
            ),
          ),
          if (_showLeftFade)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 20,
              child: IgnorePointer(
                child: DecoratedBox(
                  key: const Key('session_set_table_left_fade'),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.fadeColor,
                        widget.fadeColor.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_showRightFade)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 20,
              child: IgnorePointer(
                child: DecoratedBox(
                  key: const Key('session_set_table_right_fade'),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.fadeColor.withValues(alpha: 0),
                        widget.fadeColor,
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SetTableHeader extends StatelessWidget {
  const _SetTableHeader({
    required this.theme,
    required this.l10n,
    required this.fixedColumns,
  });

  final ThemeData theme;
  final AppLocalizations l10n;
  final bool fixedColumns;

  @override
  Widget build(BuildContext context) {
    final style = theme.textTheme.labelSmall?.copyWith(
      color: const Color(0xFF94A3B8),
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );
    Widget cell(String label, {required double width, bool flex = false}) {
      final text = FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(label, style: style),
      );
      if (fixedColumns || !flex) {
        return SizedBox(width: width, child: text);
      }
      return Expanded(child: text);
    }

    return Row(
      children: [
        cell(l10n.workoutSessionColSet, width: _blockIndexColumnWidth),
        cell(l10n.workoutSessionColReps, width: _colRepsWidth, flex: true),
        cell(l10n.workoutSessionColPercent, width: _colPercentWidth, flex: true),
        cell(l10n.workoutSessionColLoad, width: _colLoadWidth, flex: true),
        cell(l10n.workoutSessionColRpe, width: _colRpeWidth, flex: true),
        cell(l10n.workoutSessionColNote, width: _colNoteWidth, flex: true),
        const SizedBox(width: _colActionsWidth),
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
    required this.hasMaximalRef,
    required this.canRemove,
    required this.fixedColumns,
    this.resolvedMaximalKg,
    this.onEdit,
    this.onRemove,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final int setNumber;
  final ExerciseSet set;
  final bool hasMaximalRef;
  final double? resolvedMaximalKg;
  final bool canRemove;
  final bool fixedColumns;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  /// REPS cell: show block sets×reps when [set.sets] > 1 and reps is plain.
  static String repsCellLabel(ExerciseSet set) {
    final reps = set.reps.trim();
    if (reps.isEmpty) return '—';
    final blockSets = int.tryParse(set.sets.trim());
    if (blockSets != null &&
        blockSets > 1 &&
        !RegExp(r'^\d+x', caseSensitive: false).hasMatch(reps)) {
      return '$blockSets×$reps';
    }
    return reps;
  }

  Widget _cell(
    Widget child, {
    required double width,
    bool flex = false,
  }) {
    if (fixedColumns || !flex) {
      return SizedBox(width: width, child: child);
    }
    return Expanded(child: child);
  }

  @override
  Widget build(BuildContext context) {
    final cellStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w500,
    );
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final reps = repsCellLabel(set);
    final display = formatSetLoadDisplay(
      set.rpe,
      resolvedMaximalKg: resolvedMaximalKg,
      hasMaximalRef: hasMaximalRef,
    );
    final note = set.note.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _cell(
            Text(
              '$setNumber',
              style: cellStyle?.copyWith(fontWeight: FontWeight.w700),
            ),
            width: _blockIndexColumnWidth,
          ),
          _cell(Text(reps, style: cellStyle), width: _colRepsWidth, flex: true),
          _cell(
            Text(
              display.percentLabel,
              style: display.percentLabel == '—' ? muted : cellStyle,
            ),
            width: _colPercentWidth,
            flex: true,
          ),
          _cell(
            Text(
              display.loadLabel,
              style: display.loadLabel == '—' ? muted : cellStyle,
            ),
            width: _colLoadWidth,
            flex: true,
          ),
          _cell(
            Text(
              display.rpeLabel,
              style: display.rpeLabel == '—' ? muted : cellStyle,
            ),
            width: _colRpeWidth,
            flex: true,
          ),
          _cell(
            Text(
              note.isEmpty ? '—' : note,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: note.isEmpty ? muted : cellStyle,
            ),
            width: _colNoteWidth,
            flex: true,
          ),
          SizedBox(
            width: _colActionsWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  IconButton(
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: l10n.workoutBuilderEditSetTitle,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: onEdit,
                  ),
                if (canRemove && onRemove != null)
                  IconButton(
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
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
