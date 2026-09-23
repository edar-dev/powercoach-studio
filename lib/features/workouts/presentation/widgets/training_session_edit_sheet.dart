import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/ui/breakpoints.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/density_block.dart';
import '../../domain/exercise_prescription_scope.dart';
import '../../domain/workout_exercise_mutations.dart';
import '../workout_builder_session_controller.dart';
import 'exercise_library_pick_panel.dart';
import 'workout_day_exercise_list.dart';

/// Opens the Stitch-aligned full-screen "Modifica sessione" sheet.
///
/// Tracks the day by stable [Day.id] so deletes/reorders while the sheet is
/// open either keep pointing at the same day or auto-dismiss.
Future<void> showTrainingSessionEditSheet({
  required BuildContext context,
  required ThemeData theme,
  required ColorScheme cs,
  required WorkoutBuilderSessionController session,
  required int globalWeekIndex,
  required int dayIndex,
  required void Function(int weekIndex, int dayIndex) onRenameDay,
  required void Function(int weekIndex, int dayIndex) onEditDayNote,
  required void Function(int weekIndex, int dayIndex) onDeleteDay,
  void Function(int weekIndex, int dayIndex)? onCloneDayToTarget,
  required void Function(int, int, Exercise) onDuplicateExercise,
  required void Function(int, int, String) onRemoveExercise,
  required void Function(int, int, String, {required bool up}) onMoveExercise,
  required void Function(int, int, String, {required bool up})
  onMoveExerciseWithinSuperset,
  required void Function(
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
  onUpdateExercise,
  required void Function(int, int, String) onAddSetToExercise,
  required void Function(
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
  onUpdateExerciseSet,
  required void Function(int, int, String, int) onRemoveExerciseSet,
  required void Function(
    int,
    int,
    String,
    String, {
    DensityBlockConfig? densityConfig,
  })
  onAssignToSuperset,
  required void Function(int, int, String) onRemoveFromSuperset,
  required void Function(int, int, String) onAddExerciseToSuperset,
  void Function(int, int, String, DensityBlockConfig)? onSetDensityBlock,
  bool readOnly = false,
}) {
  final l10n = AppLocalizations.of(context);
  final initialDay = _dayOrNull(session.routine, globalWeekIndex, dayIndex);
  if (initialDay == null) return Future.value();
  final dayId = initialDay.id;

  return showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutPhaseEditSession,
    fullScreen: true,
    scrollBody: false,
    bodyBuilder: (sheetContext) => ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final located = _locateDayById(session.routine, dayId);
        if (located == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (sheetContext.mounted) {
              Navigator.of(sheetContext).maybePop();
            }
          });
          return Center(
            child: Text(
              l10n.workoutBuilderNoDaysInWeek,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          );
        }
        return TrainingSessionEditBody(
          theme: theme,
          cs: cs,
          session: session,
          day: located.day,
          globalWeekIndex: located.weekIndex,
          dayIndex: located.dayIndex,
          onRenameDay: () =>
              onRenameDay(located.weekIndex, located.dayIndex),
          onEditDayNote: () =>
              onEditDayNote(located.weekIndex, located.dayIndex),
          onDeleteDay: () {
            Navigator.of(sheetContext).maybePop();
            onDeleteDay(located.weekIndex, located.dayIndex);
          },
          onCloneDayToTarget: onCloneDayToTarget,
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
          readOnly: readOnly,
        );
      },
    ),
  );
}

Day? _dayOrNull(WorkoutRoutine routine, int weekIndex, int dayIndex) {
  if (weekIndex < 0 || weekIndex >= routine.weeks.length) return null;
  final week = routine.weeks[weekIndex];
  if (dayIndex < 0 || dayIndex >= week.days.length) return null;
  return week.days[dayIndex];
}

({int weekIndex, int dayIndex, Day day})? _locateDayById(
  WorkoutRoutine routine,
  String dayId,
) {
  for (var wi = 0; wi < routine.weeks.length; wi++) {
    final days = routine.weeks[wi].days;
    for (var di = 0; di < days.length; di++) {
      if (days[di].id == dayId) {
        return (weekIndex: wi, dayIndex: di, day: days[di]);
      }
    }
  }
  return null;
}

class TrainingSessionEditBody extends StatelessWidget {
  const TrainingSessionEditBody({
    super.key,
    required this.theme,
    required this.cs,
    required this.session,
    required this.day,
    required this.globalWeekIndex,
    required this.dayIndex,
    required this.onRenameDay,
    required this.onEditDayNote,
    required this.onDeleteDay,
    this.onCloneDayToTarget,
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
    this.readOnly = false,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final WorkoutBuilderSessionController session;
  final Day day;
  final int globalWeekIndex;
  final int dayIndex;
  final VoidCallback onRenameDay;
  final VoidCallback onEditDayNote;
  final VoidCallback onDeleteDay;
  final void Function(int weekIndex, int dayIndex)? onCloneDayToTarget;
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
  final bool readOnly;

  void _openLibraryPicker(BuildContext context) {
    showExerciseLibraryPickPanel(
      context: context,
      theme: theme,
      cs: cs,
      onPicked: (item) {
        final exId = 'e_${DateTime.now().millisecondsSinceEpoch}';
        session.addExerciseToDay(
          weekIndex: globalWeekIndex,
          dayIndex: dayIndex,
          exercise: buildExerciseFromPrescription(
            id: exId,
            name: item.name,
            note: '',
            setDetails: defaultExerciseSetDetails(),
            customExerciseId: item.id,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final maxWidth = AppBreakpoints.isDesktop(context)
        ? AppBreakpoints.sessionSheetMaxWidth
        : double.infinity;
    final dayName = day.name.trim().isEmpty
        ? l10n.workoutBuilderDayNumbered(dayIndex + 1)
        : day.name.trim();

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.fitness_center, size: 18, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!readOnly) ...[
                    IconButton(
                      tooltip: l10n.workoutBuilderRenameDayTitle,
                      onPressed: onRenameDay,
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      tooltip: l10n.workoutBuilderDayCoachingNoteTitle,
                      onPressed: onEditDayNote,
                      icon: const Icon(Icons.notes_outlined, size: 20),
                      visualDensity: VisualDensity.compact,
                    ),
                    if (onCloneDayToTarget != null)
                      IconButton(
                        tooltip: l10n.workoutBuilderCloneDayToTarget,
                        onPressed: () =>
                            onCloneDayToTarget!(globalWeekIndex, dayIndex),
                        icon: const Icon(Icons.copy_outlined, size: 20),
                        visualDensity: VisualDensity.compact,
                      ),
                    IconButton(
                      tooltip: l10n.workoutBuilderDeleteDayMenu,
                      onPressed: onDeleteDay,
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: cs.error,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: WorkoutDayExerciseList(
                theme: theme,
                colorScheme: cs,
                session: session,
                weekIndex: globalWeekIndex,
                dayIndex: dayIndex,
                day: day,
                onAddExercise: readOnly
                    ? null
                    : (w, d) => _openLibraryPicker(context),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
