import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../data/workout_routine_model.dart';
import '../domain/exercise_prescription_scope.dart';
import '../domain/workout_exercise_mutations.dart';
import 'workout_builder_session_controller.dart';
import 'widgets/exercise_add_sheet.dart';
import 'widgets/workout_superset_actions.dart';
import 'widgets/workout_training_helpers.dart';

/// Training-tab actions for the workout builder (weeks, days, exercises, supersets).
class WorkoutBuilderTrainingHandlers {
  WorkoutBuilderTrainingHandlers({
    required this.context,
    required this.session,
    this.customerId,
  });

  final BuildContext context;
  final WorkoutBuilderSessionController session;
  final String? customerId;

  WorkoutRoutine get _routine => session.routine;

  void addWeek() {
    final l10n = AppLocalizations.of(context);
    final id = 'w_${DateTime.now().millisecondsSinceEpoch}';
    final next = _routine.weeks.length + 1;
    session.addWeek(
      weekId: id,
      weekName: l10n.workoutBuilderWeekNumbered(next),
      firstDayId: '${id}_d1',
      firstDayName: l10n.workoutBuilderDayNumbered(1),
    );
  }

  Future<void> cloneWeek(int weekIndex) async {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final source = _routine.weeks[weekIndex];
    final l10n = AppLocalizations.of(context);
    final defaultName = '${source.name}${l10n.workoutBuilderNameCopySuffix}';
    final name = await showDuplicateWeekDialog(context, defaultName);
    if (!context.mounted || name == null || name.isEmpty) return;
    cloneWeekWithName(weekIndex, name);
  }

  void cloneWeekWithName(int weekIndex, String name) {
    final newId = 'w_${DateTime.now().millisecondsSinceEpoch}';
    session.cloneWeek(
      weekIndex: weekIndex,
      newWeekName: name,
      newWeekId: newId,
    );
  }

  void deleteWeek(int weekIndex) {
    session.deleteWeek(weekIndex);
  }

  Future<void> confirmDeleteWeek(int weekIndex) async {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: l10n.workoutBuilderDeleteWeekTitle,
      message: l10n.workoutBuilderDeleteWeekMessage,
      confirmLabel: l10n.customerDelete,
      cancelLabel: l10n.customerCancel,
      destructive: true,
    );
    if (confirmed && context.mounted) deleteWeek(weekIndex);
  }

  void renameDay(int weekIndex, int dayIndex, String newName) {
    session.renameDay(weekIndex, dayIndex, newName);
  }

  void renameWeek(int weekIndex, String newName) {
    session.renameWeek(weekIndex, newName);
  }

  void deleteDay(int weekIndex, int dayIndex) {
    session.deleteDay(weekIndex, dayIndex);
  }

  void addDayToWeek(int weekIndex) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final l10n = AppLocalizations.of(context);
    final week = _routine.weeks[weekIndex];
    final dayId = '${week.id}_d_${DateTime.now().millisecondsSinceEpoch}';
    session.addDayToWeek(
      weekIndex: weekIndex,
      dayId: dayId,
      dayName: l10n.workoutBuilderDayNumbered(week.days.length + 1),
    );
  }

  void setDayScheduledWeekday(int weekIndex, int dayIndex, int weekday) {
    session.setDayScheduledWeekday(
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      weekday: weekday,
    );
  }

  void addExerciseToDay(int weekIndex, int dayIndex) {
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    if (dayIndex < 0 || dayIndex >= _routine.weeks[weekIndex].days.length) {
      return;
    }
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final exId = 'e_${DateTime.now().millisecondsSinceEpoch}';
    showAddExerciseDialog(context, theme, cs, (
      name,
      note,
      details, [
      customExerciseId,
    ]) {
      final trimmedName = name.trim();
      if (trimmedName.isEmpty) return;
      session.addExerciseToDay(
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        exercise: buildExerciseFromPrescription(
          id: exId,
          name: trimmedName,
          note: note,
          setDetails: details,
          customExerciseId: customExerciseId,
        ),
      );
    }, customerId: customerId);
  }

  void addExerciseToSuperset(
    int weekIndex,
    int dayIndex,
    String supersetGroupId,
  ) {
    WorkoutSupersetActions.showAddExerciseToSupersetDialog(
      context: context,
      theme: Theme.of(context),
      colorScheme: Theme.of(context).colorScheme,
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      supersetGroupId: supersetGroupId,
      customerId: customerId,
      onRoutineChanged: session.setRoutine,
    );
  }

  void removeExercise(int weekIndex, int dayIndex, String exerciseId) {
    final day =
        weekIndex >= 0 &&
            weekIndex < _routine.weeks.length &&
            dayIndex >= 0 &&
            dayIndex < _routine.weeks[weekIndex].days.length
        ? _routine.weeks[weekIndex].days[dayIndex]
        : null;
    Exercise? removedExercise;
    for (final exercise in day?.exercises ?? const <Exercise>[]) {
      if (exercise.id == exerciseId) {
        removedExercise = exercise;
        break;
      }
    }
    if (!session.removeExercise(
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
    )) {
      return;
    }
    if (removedExercise == null || !context.mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.workoutBuilderExerciseRemoved),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: l10n.workoutBuilderUndo,
          onPressed: () {
            session.addExerciseToDay(
              weekIndex: weekIndex,
              dayIndex: dayIndex,
              exercise: removedExercise!,
            );
          },
        ),
      ),
    );
  }

  void duplicateExercise(int weekIndex, int dayIndex, Exercise exercise) {
    final newId = 'e_${DateTime.now().millisecondsSinceEpoch}';
    session.duplicateExercise(
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      source: exercise,
      newExerciseId: newId,
    );
  }

  void moveExerciseInDay(
    int weekIndex,
    int dayIndex,
    String exerciseId, {
    required bool up,
  }) {
    session.moveExercise(
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
      up: up,
    );
  }

  void updateExercise(
    int weekIndex,
    int dayIndex,
    String exerciseId, {
    String? name,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
    String? shortName,
    ExercisePrescriptionScope? prescriptionScope,
    List<ExerciseSet>? setDetails,
  }) {
    session.updateExercise(
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
      name: name,
      sets: sets,
      reps: reps,
      rpe: rpe,
      note: note,
      shortName: shortName,
      prescriptionScope: prescriptionScope,
      setDetails: setDetails,
    );
  }

  void addSetToExercise(int weekIndex, int dayIndex, String exerciseId) {
    session.addSetToExercise(
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
    );
  }

  void updateExerciseSet(
    int weekIndex,
    int dayIndex,
    String exerciseId,
    int setIndex, {
    String? line,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
  }) {
    session.updateExerciseSet(
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
      setIndex: setIndex,
      line: line,
      sets: sets,
      reps: reps,
      rpe: rpe,
      note: note,
    );
  }

  void removeExerciseSet(
    int weekIndex,
    int dayIndex,
    String exerciseId,
    int setIndex,
  ) {
    session.removeExerciseSet(
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
      setIndex: setIndex,
    );
  }

  void assignToSuperset(
    int weekIndex,
    int dayIndex,
    String exerciseId,
    String supersetGroupId,
  ) {
    final updated = WorkoutSupersetActions.assignToSuperset(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
      supersetGroupId: supersetGroupId,
    );
    if (updated == null) return;
    session.setRoutine(updated);
  }

  void removeFromSuperset(int weekIndex, int dayIndex, String exerciseId) {
    final updated = WorkoutSupersetActions.removeFromSuperset(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
    );
    if (updated == null) return;
    session.setRoutine(updated);
  }
}
