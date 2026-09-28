import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/exercise_prescription_scope.dart';
import '../../domain/workout_phase_presets.dart';
import '../workout_builder_session_controller.dart';
import 'training_phase_day_card.dart';
import 'training_phase_detail_header.dart';
import 'training_phase_rail.dart';
import 'training_session_edit_sheet.dart';
import 'workout_training_rename_dialogs.dart';

class WorkoutTrainingTab extends StatelessWidget {
  const WorkoutTrainingTab({
    super.key,
    required this.theme,
    required this.cs,
    this.embeddedInTab = false,
    required this.session,
    required this.phases,
    required this.selectedPhaseIndex,
    required this.selectedWeekIndex,
    required this.selectedDayIndex,
    required this.onAddPhase,
    required this.onDuplicatePhase,
    required this.onEditPhaseSettings,
    required this.onDeletePhase,
    required this.onSelectPhase,
    required this.onNewWeek,
    required this.onCloneWeek,
    required this.onDeleteWeek,
    required this.onRenameWeek,
    required this.onAddDay,
    required this.onRenameDay,
    required this.onSetDayCoachingNote,
    required this.onDeleteDay,
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
    required this.onSelectWeek,
    required this.onSelectDay,
    required this.onUpdateScheduledWeekday,
    this.onLogSession,
    this.onCloneDayToTarget,
    this.readOnly = false,
    this.editorMode = false,
    this.planId,
    this.editorCustomerName,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final bool embeddedInTab;
  final WorkoutBuilderSessionController session;
  final List<Phase> phases;
  final int selectedPhaseIndex;
  final int selectedWeekIndex;
  final int selectedDayIndex;
  final VoidCallback onAddPhase;
  final void Function(int phaseIndex) onDuplicatePhase;
  final void Function(int phaseIndex) onEditPhaseSettings;
  final void Function(int phaseIndex) onDeletePhase;
  final void Function(int phaseIndex) onSelectPhase;
  final VoidCallback onNewWeek;
  final void Function(int) onCloneWeek;
  final void Function(int) onDeleteWeek;
  final void Function(int, String) onRenameWeek;
  final void Function(int) onAddDay;
  final void Function(int, int, String) onRenameDay;
  final void Function(int, int, String) onSetDayCoachingNote;
  final void Function(int, int) onDeleteDay;
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
  final void Function(int) onSelectWeek;
  final void Function(int) onSelectDay;
  final void Function(int weekIndex, int dayIndex, int? weekday)
  onUpdateScheduledWeekday;
  final VoidCallback? onLogSession;
  final void Function(int weekIndex, int dayIndex)? onCloneDayToTarget;
  final bool readOnly;
  final bool editorMode;
  final String? planId;
  final String? editorCustomerName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (phases.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.layers_outlined, size: 48, color: cs.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                l10n.workoutPhaseEmptyTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.workoutPhaseEmptyMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: readOnly ? null : onAddPhase,
                icon: const Icon(Icons.add),
                label: Text(l10n.workoutPhaseAdd),
              ),
            ],
          ),
        ),
      );
    }

    final phaseIndex = selectedPhaseIndex.clamp(0, phases.length - 1);
    final phase = phases[phaseIndex];
    final globalOffset = session.routine.globalWeekIndex(phaseIndex, 0) ?? 0;
    final progress = phaseProgressPercent(
      phase: phase,
      globalWeekOffset: globalOffset,
      sessionCompletionByKey: session.routine.sessionCompletionByKey,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(0, embeddedInTab ? 0 : 8, 0, 0),
      child: _PhaseTrainingBody(
        theme: theme,
        cs: cs,
        session: session,
        phases: phases,
        phase: phase,
        phaseIndex: phaseIndex,
        progressPercent: progress,
        globalWeekOffset: globalOffset,
        selectedWeekIndex: selectedWeekIndex,
        selectedDayIndex: selectedDayIndex,
        onAddPhase: onAddPhase,
        onDuplicatePhase: () => onDuplicatePhase(phaseIndex),
        onEditPhaseSettings: () => onEditPhaseSettings(phaseIndex),
        onDeletePhase: () => onDeletePhase(phaseIndex),
        onSelectPhase: onSelectPhase,
        onNewWeek: onNewWeek,
        onCloneWeek: onCloneWeek,
        onDeleteWeek: onDeleteWeek,
        onRenameWeek: onRenameWeek,
        onAddDay: onAddDay,
        onRenameDay: onRenameDay,
        onSetDayCoachingNote: onSetDayCoachingNote,
        onDeleteDay: onDeleteDay,
        onDuplicateExercise: onDuplicateExercise,
        onRemoveExercise: onRemoveExercise,
        onMoveExercise: onMoveExercise,
        onMoveExerciseWithinSuperset: onMoveExerciseWithinSuperset,
        onUpdateExercise: onUpdateExercise,
        onAddSetToExercise: onAddSetToExercise,
        onUpdateExerciseSet: onUpdateExerciseSet,
        onRemoveExerciseSet: onRemoveExerciseSet,
        onAssignToSuperset: onAssignToSuperset,
        onRemoveFromSuperset: onRemoveFromSuperset,
        onAddExerciseToSuperset: onAddExerciseToSuperset,
        onSelectWeek: onSelectWeek,
        onSelectDay: onSelectDay,
        onUpdateScheduledWeekday: onUpdateScheduledWeekday,
        onLogSession: onLogSession,
        onCloneDayToTarget: onCloneDayToTarget,
        readOnly: readOnly,
        editorMode: editorMode,
        planId: planId,
        editorCustomerName: editorCustomerName,
      ),
    );
  }
}

class _PhaseTrainingBody extends StatefulWidget {
  const _PhaseTrainingBody({
    required this.theme,
    required this.cs,
    required this.session,
    required this.phases,
    required this.phase,
    required this.phaseIndex,
    required this.progressPercent,
    required this.globalWeekOffset,
    required this.selectedWeekIndex,
    required this.selectedDayIndex,
    required this.onAddPhase,
    required this.onDuplicatePhase,
    required this.onEditPhaseSettings,
    required this.onDeletePhase,
    required this.onSelectPhase,
    required this.onNewWeek,
    required this.onCloneWeek,
    required this.onDeleteWeek,
    required this.onRenameWeek,
    required this.onAddDay,
    required this.onRenameDay,
    required this.onSetDayCoachingNote,
    required this.onDeleteDay,
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
    required this.onSelectWeek,
    required this.onSelectDay,
    required this.onUpdateScheduledWeekday,
    this.onLogSession,
    this.onCloneDayToTarget,
    this.readOnly = false,
    this.editorMode = false,
    this.planId,
    this.editorCustomerName,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final WorkoutBuilderSessionController session;
  final List<Phase> phases;
  final Phase phase;
  final int phaseIndex;
  final int progressPercent;
  final int globalWeekOffset;
  final int selectedWeekIndex;
  final int selectedDayIndex;
  final VoidCallback onAddPhase;
  final VoidCallback onDuplicatePhase;
  final VoidCallback onEditPhaseSettings;
  final VoidCallback onDeletePhase;
  final void Function(int phaseIndex) onSelectPhase;
  final VoidCallback onNewWeek;
  final void Function(int) onCloneWeek;
  final void Function(int) onDeleteWeek;
  final void Function(int, String) onRenameWeek;
  final void Function(int) onAddDay;
  final void Function(int, int, String) onRenameDay;
  final void Function(int, int, String) onSetDayCoachingNote;
  final void Function(int, int) onDeleteDay;
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
  final void Function(int) onSelectWeek;
  final void Function(int) onSelectDay;
  final void Function(int weekIndex, int dayIndex, int? weekday)
  onUpdateScheduledWeekday;
  final VoidCallback? onLogSession;
  final void Function(int weekIndex, int dayIndex)? onCloneDayToTarget;
  final bool readOnly;
  final bool editorMode;
  final String? planId;
  final String? editorCustomerName;

  @override
  State<_PhaseTrainingBody> createState() => _PhaseTrainingBodyState();
}

class _PhaseTrainingBodyState extends State<_PhaseTrainingBody> {
  late Set<int> _expandedWeeks;

  @override
  void initState() {
    super.initState();
    _expandedWeeks = _initialExpanded();
  }

  @override
  void didUpdateWidget(covariant _PhaseTrainingBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phaseIndex != widget.phaseIndex ||
        oldWidget.phase.weeks.length != widget.phase.weeks.length) {
      _expandedWeeks = _initialExpanded();
    } else if (oldWidget.selectedWeekIndex != widget.selectedWeekIndex) {
      _expandedWeeks = {..._expandedWeeks, widget.selectedWeekIndex};
    }
  }

  Set<int> _initialExpanded() {
    final weeks = widget.phase.weeks;
    if (weeks.isEmpty) return {};
    final first = widget.globalWeekOffset;
    final selected = widget.selectedWeekIndex;
    final inPhase = selected >= widget.globalWeekOffset &&
        selected < widget.globalWeekOffset + weeks.length;
    return {first, if (inPhase) selected};
  }

  void _toggleWeek(int globalWeek) {
    setState(() {
      if (_expandedWeeks.contains(globalWeek)) {
        _expandedWeeks = {..._expandedWeeks}..remove(globalWeek);
      } else {
        _expandedWeeks = {..._expandedWeeks, globalWeek};
        widget.onSelectWeek(globalWeek);
      }
    });
  }

  void _openSessionEditor(int globalWeek, int dayIndex) {
    widget.onSelectWeek(globalWeek);
    widget.onSelectDay(dayIndex);
    setState(() {
      _expandedWeeks = {..._expandedWeeks, globalWeek};
    });
    final weeks = widget.phase.weeks;
    final weekInPhase = globalWeek - widget.globalWeekOffset;
    if (weekInPhase < 0 || weekInPhase >= weeks.length) return;
    if (dayIndex < 0 || dayIndex >= weeks[weekInPhase].days.length) return;

    Day liveDay(int weekIndex, int index) {
      final routineWeeks = widget.session.routine.weeks;
      if (weekIndex < 0 ||
          weekIndex >= routineWeeks.length ||
          index < 0 ||
          index >= routineWeeks[weekIndex].days.length) {
        return weeks[weekInPhase].days[dayIndex];
      }
      return routineWeeks[weekIndex].days[index];
    }

    final l10n = AppLocalizations.of(context);
    final week = weeks[weekInPhase];
    final weekName = week.name.trim();
    final weekLabel = weekName.isEmpty
        ? l10n.workoutBuilderWeekNumbered(weekInPhase + 1)
        : weekName;
    final phaseLabel = widget.phase.name.trim().isEmpty
        ? l10n.workoutPhaseNumbered(widget.phaseIndex + 1)
        : widget.phase.name.trim();

    showTrainingSessionEditSheet(
      context: context,
      theme: widget.theme,
      cs: widget.cs,
      session: widget.session,
      globalWeekIndex: globalWeek,
      dayIndex: dayIndex,
      onRenameDay: (weekIndex, index) {
        final day = liveDay(weekIndex, index);
        showRenameDayDialog(
          context,
          day.name,
          (name) => widget.onRenameDay(weekIndex, index, name),
        );
      },
      onEditDayNote: (weekIndex, index) {
        final day = liveDay(weekIndex, index);
        showEditDayCoachingNoteDialog(
          context,
          day.coachingNote ?? '',
          (note) => widget.onSetDayCoachingNote(weekIndex, index, note),
        );
      },
      onDeleteDay: (weekIndex, index) =>
          widget.onDeleteDay(weekIndex, index),
      onCloneDayToTarget: widget.onCloneDayToTarget,
      onDuplicateExercise: widget.onDuplicateExercise,
      onRemoveExercise: widget.onRemoveExercise,
      onMoveExercise: widget.onMoveExercise,
      onMoveExerciseWithinSuperset: widget.onMoveExerciseWithinSuperset,
      onUpdateExercise: widget.onUpdateExercise,
      onAddSetToExercise: widget.onAddSetToExercise,
      onUpdateExerciseSet: widget.onUpdateExerciseSet,
      onRemoveExerciseSet: widget.onRemoveExerciseSet,
      onAssignToSuperset: widget.onAssignToSuperset,
      onRemoveFromSuperset: widget.onRemoveFromSuperset,
      onAddExerciseToSuperset: widget.onAddExerciseToSuperset,
      readOnly: widget.readOnly,
      editorMode: widget.editorMode,
      planId: widget.planId,
      customerName: widget.editorCustomerName,
      onLogSession: widget.onLogSession,
      phaseName: phaseLabel,
      weekLabel: weekLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final weeks = widget.phase.weeks;

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: widget.cs.surfaceContainer.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.cs.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TrainingPhaseRail(
                phases: widget.phases,
                selectedPhaseIndex: widget.phaseIndex,
                onSelectPhase: widget.onSelectPhase,
                onAddPhase: widget.readOnly ? null : widget.onAddPhase,
                onDuplicatePhase:
                    widget.readOnly ? null : widget.onDuplicatePhase,
                onEditPhaseSettings:
                    widget.readOnly ? null : widget.onEditPhaseSettings,
              ),
              const SizedBox(height: 14),
              Divider(
                height: 1,
                color: widget.cs.outlineVariant.withValues(alpha: 0.45),
              ),
              const SizedBox(height: 12),
              TrainingPhaseDetailHeader(
                phase: widget.phase,
                phaseIndex: widget.phaseIndex,
                progressPercent: widget.progressPercent,
                onDelete: widget.readOnly ? null : widget.onDeletePhase,
                readOnly: widget.readOnly,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (weeks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Text(
                  l10n.workoutBuilderNoWeeksYet,
                  textAlign: TextAlign.center,
                  style: widget.theme.textTheme.bodyLarge?.copyWith(
                    color: widget.cs.onSurface.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: widget.readOnly ? null : widget.onNewWeek,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.workoutPhaseAddWeek),
                ),
              ],
            ),
          )
        else ...[
          for (var wi = 0; wi < weeks.length; wi++) ...[
            _WeekBlock(
              theme: widget.theme,
              cs: widget.cs,
              week: weeks[wi],
              weekInPhase: wi,
              globalWeekIndex: widget.globalWeekOffset + wi,
              expanded: _expandedWeeks.contains(widget.globalWeekOffset + wi),
              selectedWeekIndex: widget.selectedWeekIndex,
              selectedDayIndex: widget.selectedDayIndex,
              onToggleExpanded: () =>
                  _toggleWeek(widget.globalWeekOffset + wi),
              onEditSession: (dayIndex) =>
                  _openSessionEditor(widget.globalWeekOffset + wi, dayIndex),
              onAddDay: () => widget.onAddDay(widget.globalWeekOffset + wi),
              onCloneWeek: () =>
                  widget.onCloneWeek(widget.globalWeekOffset + wi),
              onDeleteWeek: () =>
                  widget.onDeleteWeek(widget.globalWeekOffset + wi),
              onRenameWeek: () {
                final week = weeks[wi];
                showRenameWeekDialog(
                  context,
                  week.name,
                  (name) =>
                      widget.onRenameWeek(widget.globalWeekOffset + wi, name),
                );
              },
              onRenameDay: (dayIndex) {
                final day = weeks[wi].days[dayIndex];
                showRenameDayDialog(
                  context,
                  day.name,
                  (name) => widget.onRenameDay(
                    widget.globalWeekOffset + wi,
                    dayIndex,
                    name,
                  ),
                );
              },
              onEditDayNote: (dayIndex) {
                final day = weeks[wi].days[dayIndex];
                showEditDayCoachingNoteDialog(
                  context,
                  day.coachingNote ?? '',
                  (note) => widget.onSetDayCoachingNote(
                    widget.globalWeekOffset + wi,
                    dayIndex,
                    note,
                  ),
                );
              },
              onDeleteDay: (dayIndex) => widget.onDeleteDay(
                widget.globalWeekOffset + wi,
                dayIndex,
              ),
              onUpdateScheduledWeekday: widget.onUpdateScheduledWeekday,
              readOnly: widget.readOnly,
            ),
            const SizedBox(height: 28),
          ],
          _AddWeekButton(
            key: const ValueKey('training-add-week'),
            cs: widget.cs,
            theme: widget.theme,
            label: l10n.workoutPhaseAddWeek,
            onPressed: widget.readOnly ? null : widget.onNewWeek,
          ),
        ],
      ],
    );
  }
}

class _AddWeekButton extends StatelessWidget {
  const _AddWeekButton({
    super.key,
    required this.cs,
    required this.theme,
    required this.label,
    required this.onPressed,
  });

  final ColorScheme cs;
  final ThemeData theme;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _DashedRoundedPainter(
            color: cs.outlineVariant,
            radius: 16,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary.withValues(alpha: 0.18),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Icon(Icons.add, size: 16, color: cs.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  '+ $label',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRoundedPainter extends CustomPainter {
  _DashedRoundedPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      const dash = 7.0;
      const gap = 5.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _WeekBlock extends StatelessWidget {
  const _WeekBlock({
    required this.theme,
    required this.cs,
    required this.week,
    required this.weekInPhase,
    required this.globalWeekIndex,
    required this.expanded,
    required this.selectedWeekIndex,
    required this.selectedDayIndex,
    required this.onToggleExpanded,
    required this.onEditSession,
    required this.onAddDay,
    required this.onCloneWeek,
    required this.onDeleteWeek,
    required this.onRenameWeek,
    required this.onRenameDay,
    required this.onEditDayNote,
    required this.onDeleteDay,
    required this.onUpdateScheduledWeekday,
    this.readOnly = false,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final Week week;
  final int weekInPhase;
  final int globalWeekIndex;
  final bool expanded;
  final int selectedWeekIndex;
  final int selectedDayIndex;
  final VoidCallback onToggleExpanded;
  final void Function(int dayIndex) onEditSession;
  final VoidCallback onAddDay;
  final VoidCallback onCloneWeek;
  final VoidCallback onDeleteWeek;
  final VoidCallback onRenameWeek;
  final void Function(int dayIndex) onRenameDay;
  final void Function(int dayIndex) onEditDayNote;
  final void Function(int dayIndex) onDeleteDay;
  final void Function(int weekIndex, int dayIndex, int? weekday)
  onUpdateScheduledWeekday;
  final bool readOnly;

  String _weekTitle(AppLocalizations l10n) {
    final trimmed = week.name.trim();
    if (trimmed.isEmpty) {
      return l10n.workoutBuilderWeekNumbered(weekInPhase + 1);
    }
    final match = RegExp(
      r'^(SETTIMANA|WEEK)\s+(\d+)$',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (match != null) {
      return l10n.workoutBuilderWeekNumbered(int.parse(match.group(2)!));
    }
    // Custom name: keep numbered title + show custom as focus chip.
    return l10n.workoutBuilderWeekNumbered(weekInPhase + 1);
  }

  String? _weekFocusLabel() {
    final trimmed = week.name.trim();
    if (trimmed.isEmpty) return null;
    final match = RegExp(
      r'^(SETTIMANA|WEEK)\s+(\d+)$',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (match != null) return null;
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final focus = _weekFocusLabel();

    if (!expanded) {
      return Material(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onToggleExpanded,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _weekTitle(l10n),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (focus != null) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                    color: cs.outlineVariant
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                child: Text(
                                  focus,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.workoutPhaseFrequencyValue(week.days.length),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  l10n.workoutPhaseExpandWeek,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l10n.workoutPhaseCollapseWeek,
              onPressed: onToggleExpanded,
              icon: const Icon(Icons.expand_more, size: 20),
              visualDensity: VisualDensity.compact,
            ),
            Text(
              _weekTitle(l10n),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (focus != null) ...[
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  focus,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const Spacer(),
            if (!readOnly)
              TextButton.icon(
                onPressed: onAddDay,
                icon: const Icon(Icons.add, size: 16),
                label: Text(l10n.workoutPhaseAddDay),
                style: TextButton.styleFrom(
                  foregroundColor: cs.primary,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            if (!readOnly)
              PopupMenuButton<String>(
                tooltip: l10n.workoutBuilderWeekMenuTooltip,
                onSelected: (value) {
                  switch (value) {
                    case 'rename':
                      onRenameWeek();
                    case 'clone':
                      onCloneWeek();
                    case 'delete':
                      onDeleteWeek();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Text(l10n.workoutBuilderRenameWeekMenu),
                  ),
                  PopupMenuItem(
                    value: 'clone',
                    child: Text(l10n.workoutBuilderDuplicateWeek),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.workoutBuilderDeleteWeekMenu),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 1280
                ? 4
                : width >= 900
                    ? 3
                    : width >= 560
                        ? 2
                        : 1;
            final itemCount = week.days.length + (readOnly ? 0 : 1);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                // Fits ~4 exercise previews + header/footer; list scrolls if denser.
                mainAxisExtent: 360,
              ),
              itemBuilder: (context, index) {
                if (index >= week.days.length) {
                  return TrainingPhaseAddDayCard(
                    weekNumber: weekInPhase + 1,
                    onAddDay: onAddDay,
                  );
                }
                final day = week.days[index];
                final selected = selectedWeekIndex == globalWeekIndex &&
                    selectedDayIndex == index;
                return TrainingPhaseDayCard(
                  day: day,
                  dayIndex: index,
                  selected: selected,
                  readOnly: readOnly,
                  onEditSession: () => onEditSession(index),
                  onUpdateScheduledWeekday: readOnly
                      ? null
                      : (weekday) => onUpdateScheduledWeekday(
                            globalWeekIndex,
                            index,
                            weekday,
                          ),
                  onMenuSelected: readOnly
                      ? null
                      : (action) {
                          switch (action) {
                            case 'rename':
                              onRenameDay(index);
                            case 'note':
                              onEditDayNote(index);
                            case 'delete':
                              onDeleteDay(index);
                          }
                        },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
