import 'package:flutter/material.dart';

import '../../../../core/ui/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/density_block.dart';
import '../../domain/exercise_prescription_scope.dart';
import '../../domain/workout_phase_presets.dart';
import '../workout_builder_session_controller.dart';
import 'training_phase_detail_header.dart';
import 'training_phase_rail.dart';
import 'training_week_day_panel.dart';
import 'workout_day_exercise_list.dart';
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
    required this.onAddExercise,
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
    required this.onSelectWeek,
    required this.onSelectDay,
    required this.onUpdateScheduledWeekday,
    this.onLogSession,
    this.onCloneDayToTarget,
    this.readOnly = false,
    this.editorMode = false,
    this.planId,
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
  final void Function(int, int) onAddExercise;
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
  final void Function(
    int,
    int,
    String,
    String, {
    DensityBlockConfig? densityConfig,
  })
  onAssignToSuperset;
  final void Function(int, int, String) onRemoveFromSuperset;
  final void Function(int, int, String) onAddExerciseToSuperset;
  final void Function(int, int, String, DensityBlockConfig)? onSetDensityBlock;
  final void Function(int) onSelectWeek;
  final void Function(int) onSelectDay;
  final void Function(int weekIndex, int dayIndex, int? weekday)
  onUpdateScheduledWeekday;
  final VoidCallback? onLogSession;
  final void Function(int weekIndex, int dayIndex)? onCloneDayToTarget;
  final bool readOnly;
  final bool editorMode;
  final String? planId;

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
    final globalOffset =
        session.routine.globalWeekIndex(phaseIndex, 0) ?? 0;
    final progress = phaseProgressPercent(
      phase: phase,
      globalWeekOffset: globalOffset,
      sessionCompletionByKey: session.routine.sessionCompletionByKey,
    );

    final detail = _PhaseDetailBody(
      theme: theme,
      cs: cs,
      session: session,
      phase: phase,
      phaseIndex: phaseIndex,
      progressPercent: progress,
      selectedWeekIndex: selectedWeekIndex,
      selectedDayIndex: selectedDayIndex,
      onDuplicatePhase: () => onDuplicatePhase(phaseIndex),
      onEditPhaseSettings: () => onEditPhaseSettings(phaseIndex),
      onDeletePhase: () => onDeletePhase(phaseIndex),
      onNewWeek: onNewWeek,
      onCloneWeek: onCloneWeek,
      onDeleteWeek: onDeleteWeek,
      onRenameWeek: onRenameWeek,
      onAddDay: onAddDay,
      onRenameDay: onRenameDay,
      onSetDayCoachingNote: onSetDayCoachingNote,
      onDeleteDay: onDeleteDay,
      onAddExercise: onAddExercise,
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
      onSetDensityBlock: onSetDensityBlock,
      onSelectWeek: onSelectWeek,
      onSelectDay: onSelectDay,
      onUpdateScheduledWeekday: onUpdateScheduledWeekday,
      onLogSession: onLogSession,
      onCloneDayToTarget: onCloneDayToTarget,
      readOnly: readOnly,
      editorMode: editorMode,
      planId: planId,
    );

    final wide = Breakpoints.isDesktop(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(0, embeddedInTab ? 0 : 8, 0, 0),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 220,
                  child: TrainingPhaseRail(
                    phases: phases,
                    selectedPhaseIndex: phaseIndex,
                    onSelectPhase: onSelectPhase,
                    onAddPhase: readOnly ? null : onAddPhase,
                    vertical: true,
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
                Expanded(child: detail),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TrainingPhaseRail(
                  phases: phases,
                  selectedPhaseIndex: phaseIndex,
                  onSelectPhase: onSelectPhase,
                  onAddPhase: readOnly ? null : onAddPhase,
                ),
                const SizedBox(height: 8),
                Expanded(child: detail),
              ],
            ),
    );
  }
}

class _PhaseDetailBody extends StatelessWidget {
  const _PhaseDetailBody({
    required this.theme,
    required this.cs,
    required this.session,
    required this.phase,
    required this.phaseIndex,
    required this.progressPercent,
    required this.selectedWeekIndex,
    required this.selectedDayIndex,
    required this.onDuplicatePhase,
    required this.onEditPhaseSettings,
    required this.onDeletePhase,
    required this.onNewWeek,
    required this.onCloneWeek,
    required this.onDeleteWeek,
    required this.onRenameWeek,
    required this.onAddDay,
    required this.onRenameDay,
    required this.onSetDayCoachingNote,
    required this.onDeleteDay,
    required this.onAddExercise,
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
    required this.onSelectWeek,
    required this.onSelectDay,
    required this.onUpdateScheduledWeekday,
    this.onLogSession,
    this.onCloneDayToTarget,
    this.readOnly = false,
    this.editorMode = false,
    this.planId,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final WorkoutBuilderSessionController session;
  final Phase phase;
  final int phaseIndex;
  final int progressPercent;
  final int selectedWeekIndex;
  final int selectedDayIndex;
  final VoidCallback onDuplicatePhase;
  final VoidCallback onEditPhaseSettings;
  final VoidCallback onDeletePhase;
  final VoidCallback onNewWeek;
  final void Function(int) onCloneWeek;
  final void Function(int) onDeleteWeek;
  final void Function(int, String) onRenameWeek;
  final void Function(int) onAddDay;
  final void Function(int, int, String) onRenameDay;
  final void Function(int, int, String) onSetDayCoachingNote;
  final void Function(int, int) onDeleteDay;
  final void Function(int, int) onAddExercise;
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
  final void Function(
    int,
    int,
    String,
    String, {
    DensityBlockConfig? densityConfig,
  })
  onAssignToSuperset;
  final void Function(int, int, String) onRemoveFromSuperset;
  final void Function(int, int, String) onAddExerciseToSuperset;
  final void Function(int, int, String, DensityBlockConfig)? onSetDensityBlock;
  final void Function(int) onSelectWeek;
  final void Function(int) onSelectDay;
  final void Function(int weekIndex, int dayIndex, int? weekday)
  onUpdateScheduledWeekday;
  final VoidCallback? onLogSession;
  final void Function(int weekIndex, int dayIndex)? onCloneDayToTarget;
  final bool readOnly;
  final bool editorMode;
  final String? planId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final weeks = phase.weeks;
    final globalOffset =
        session.routine.globalWeekIndex(phaseIndex, 0) ?? selectedWeekIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: TrainingPhaseDetailHeader(
            phase: phase,
            phaseIndex: phaseIndex,
            progressPercent: progressPercent,
            onDuplicate: onDuplicatePhase,
            onSettings: onEditPhaseSettings,
            onDelete: readOnly ? null : onDeletePhase,
            readOnly: readOnly,
          ),
        ),
        if (weeks.isEmpty)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.workoutBuilderNoWeeksYet,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: readOnly ? null : onNewWeek,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.workoutPhaseAddWeek),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Expanded(
            child: _ExpandablePhaseWeeks(
              theme: theme,
              cs: cs,
              session: session,
              phaseWeeks: weeks,
              globalWeekOffset: globalOffset,
              selectedWeekIndex: selectedWeekIndex,
              selectedDayIndex: selectedDayIndex,
              onNewWeek: onNewWeek,
              onCloneWeek: onCloneWeek,
              onDeleteWeek: onDeleteWeek,
              onRenameWeek: onRenameWeek,
              onAddDay: onAddDay,
              onRenameDay: onRenameDay,
              onSetDayCoachingNote: onSetDayCoachingNote,
              onDeleteDay: onDeleteDay,
              onAddExercise: onAddExercise,
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
              onSetDensityBlock: onSetDensityBlock,
              onSelectWeek: onSelectWeek,
              onSelectDay: onSelectDay,
              onUpdateScheduledWeekday: onUpdateScheduledWeekday,
              onLogSession: onLogSession,
              onCloneDayToTarget: onCloneDayToTarget,
              readOnly: readOnly,
              editorMode: editorMode,
              planId: planId,
            ),
          ),
      ],
    );
  }
}

/// Expandable weeks within a phase; selected week shows day/exercise panel.
class _ExpandablePhaseWeeks extends StatelessWidget {
  const _ExpandablePhaseWeeks({
    required this.theme,
    required this.cs,
    required this.session,
    required this.phaseWeeks,
    required this.globalWeekOffset,
    required this.selectedWeekIndex,
    required this.selectedDayIndex,
    required this.onNewWeek,
    required this.onCloneWeek,
    required this.onDeleteWeek,
    required this.onRenameWeek,
    required this.onAddDay,
    required this.onRenameDay,
    required this.onSetDayCoachingNote,
    required this.onDeleteDay,
    required this.onAddExercise,
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
    required this.onSelectWeek,
    required this.onSelectDay,
    required this.onUpdateScheduledWeekday,
    this.onLogSession,
    this.onCloneDayToTarget,
    this.readOnly = false,
    this.editorMode = false,
    this.planId,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final WorkoutBuilderSessionController session;
  final List<Week> phaseWeeks;
  final int globalWeekOffset;
  final int selectedWeekIndex;
  final int selectedDayIndex;
  final VoidCallback onNewWeek;
  final void Function(int) onCloneWeek;
  final void Function(int) onDeleteWeek;
  final void Function(int, String) onRenameWeek;
  final void Function(int) onAddDay;
  final void Function(int, int, String) onRenameDay;
  final void Function(int, int, String) onSetDayCoachingNote;
  final void Function(int, int) onDeleteDay;
  final void Function(int, int) onAddExercise;
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
  final void Function(
    int,
    int,
    String,
    String, {
    DensityBlockConfig? densityConfig,
  })
  onAssignToSuperset;
  final void Function(int, int, String) onRemoveFromSuperset;
  final void Function(int, int, String) onAddExerciseToSuperset;
  final void Function(int, int, String, DensityBlockConfig)? onSetDensityBlock;
  final void Function(int) onSelectWeek;
  final void Function(int) onSelectDay;
  final void Function(int weekIndex, int dayIndex, int? weekday)
  onUpdateScheduledWeekday;
  final VoidCallback? onLogSession;
  final void Function(int weekIndex, int dayIndex)? onCloneDayToTarget;
  final bool readOnly;
  final bool editorMode;
  final String? planId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Full flat weeks for the day panel toolbar (global indices).
    final allWeeks = session.routine.weeks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            itemCount: phaseWeeks.length + 1,
            itemBuilder: (context, index) {
              if (index == phaseWeeks.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: OutlinedButton.icon(
                    onPressed: readOnly ? null : onNewWeek,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.workoutPhaseAddWeek),
                  ),
                );
              }
              final weekInPhase = index;
              final globalWeek = globalWeekOffset + weekInPhase;
              final week = phaseWeeks[weekInPhase];
              final expanded = globalWeek == selectedWeekIndex;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  key: ValueKey('phase-week-$globalWeek-$expanded'),
                  initiallyExpanded: expanded,
                  onExpansionChanged: (open) {
                    if (open) onSelectWeek(globalWeek);
                  },
                  title: Text(
                    week.name.trim().isEmpty
                        ? l10n.workoutBuilderWeekNumbered(weekInPhase + 1)
                        : week.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  children: [
                    if (expanded)
                      SizedBox(
                        height: 420,
                        child: TrainingWeekDayPanel(
                          theme: theme,
                          cs: cs,
                          weeks: allWeeks,
                          selectedWeekIndex: selectedWeekIndex,
                          selectedDayIndex: selectedDayIndex,
                          onSelectWeek: onSelectWeek,
                          onSelectDay: onSelectDay,
                          onNewWeek: onNewWeek,
                          onCloneWeek: onCloneWeek,
                          onDeleteWeek: onDeleteWeek,
                          onEditWeek: (weekIndex) {
                            final w = allWeeks[weekIndex];
                            showRenameWeekDialog(
                              context,
                              w.name,
                              (name) => onRenameWeek(weekIndex, name),
                            );
                          },
                          onAddDay: onAddDay,
                          onEditDay: (weekIndex, dayIndex) {
                            final day = allWeeks[weekIndex].days[dayIndex];
                            showRenameDayDialog(
                              context,
                              day.name,
                              (name) => onRenameDay(weekIndex, dayIndex, name),
                            );
                          },
                          onDeleteDay: onDeleteDay,
                          onUpdateScheduledWeekday: onUpdateScheduledWeekday,
                          onLogSession: onLogSession,
                          onCloneDayToTarget:
                              readOnly ? null : onCloneDayToTarget,
                          onEditDayCoachingNote: readOnly
                              ? null
                              : (weekIndex, dayIndex) {
                                  final day =
                                      allWeeks[weekIndex].days[dayIndex];
                                  showEditDayCoachingNoteDialog(
                                    context,
                                    day.coachingNote ?? '',
                                    (note) => onSetDayCoachingNote(
                                      weekIndex,
                                      dayIndex,
                                      note,
                                    ),
                                  );
                                },
                          planId: planId,
                          editorMode: editorMode,
                          exerciseListBuilder:
                              (context, weekIndex, dayIndex, day) {
                            return WorkoutDayExerciseList(
                              theme: theme,
                              colorScheme: cs,
                              session: session,
                              weekIndex: weekIndex,
                              dayIndex: dayIndex,
                              day: day,
                              onAddExercise: readOnly ? null : onAddExercise,
                              onDuplicateExercise: onDuplicateExercise,
                              onRemoveExercise: onRemoveExercise,
                              onMoveExercise: onMoveExercise,
                              onMoveExerciseWithinSuperset:
                                  onMoveExerciseWithinSuperset,
                              onUpdateExercise: onUpdateExercise,
                              onAddSetToExercise: onAddSetToExercise,
                              onUpdateExerciseSet: onUpdateExerciseSet,
                              onRemoveExerciseSet: onRemoveExerciseSet,
                              onAssignToSuperset: onAssignToSuperset,
                              onRemoveFromSuperset: onRemoveFromSuperset,
                              onAddExerciseToSuperset: onAddExerciseToSuperset,
                              onSetDensityBlock: onSetDensityBlock,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
