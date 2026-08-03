import 'package:flutter/material.dart';

import '../../data/workout_routine_model.dart';
import '../../domain/exercise_prescription_scope.dart';
import '../workout_builder_session_controller.dart';
import 'training_week_day_panel.dart';
import 'workout_day_exercise_list.dart';
import 'workout_training_helpers.dart';

class WorkoutTrainingTab extends StatelessWidget {
  const WorkoutTrainingTab({
    super.key,
    required this.theme,
    required this.cs,
    this.embeddedInTab = false,
    required this.session,
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
  });

  final ThemeData theme;
  final ColorScheme cs;
  final bool embeddedInTab;
  final WorkoutBuilderSessionController session;
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
  final void Function(int weekIndex, int dayIndex, int weekday)
  onUpdateScheduledWeekday;
  final VoidCallback? onLogSession;
  final void Function(int weekIndex, int dayIndex)? onCloneDayToTarget;
  final bool readOnly;
  final bool editorMode;
  final String? planId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, embeddedInTab ? 0 : 8, 0, 0),
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
        onLogSession: onLogSession,
        onCloneDayToTarget: readOnly ? null : onCloneDayToTarget,
        planId: planId,
        editorMode: editorMode,
        exerciseListBuilder: (context, weekIndex, dayIndex, day) {
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
            onMoveExerciseWithinSuperset: onMoveExerciseWithinSuperset,
            onUpdateExercise: onUpdateExercise,
            onAddSetToExercise: onAddSetToExercise,
            onUpdateExerciseSet: onUpdateExerciseSet,
            onRemoveExerciseSet: onRemoveExerciseSet,
            onAssignToSuperset: onAssignToSuperset,
            onRemoveFromSuperset: onRemoveFromSuperset,
            onAddExerciseToSuperset: onAddExerciseToSuperset,
          );
        },
      ),
    );
  }
}
