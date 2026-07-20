import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../settings/data/user_preferences_repository.dart';
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
    this.readOnly = false,
  });

  final BuildContext context;
  final WorkoutBuilderSessionController session;
  final String? customerId;
  final bool readOnly;

  WorkoutRoutine get _routine => session.routine;

  void _showUndoSnackBar(String message, VoidCallback onUndo) {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: l10n.workoutBuilderUndo,
          onPressed: onUndo,
        ),
      ),
    );
  }

  Future<bool> _resolveCompactAddMode() async {
    final pref =
        await UserPreferencesRepository.instance.getWorkoutBuilderCompactAdd();
    if (!context.mounted) return false;
    return resolveWorkoutBuilderCompactAdd(context, preferenceOverride: pref);
  }

  void addWeek() {
    if (readOnly) return;
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
    if (readOnly) return;
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final source = _routine.weeks[weekIndex];
    final l10n = AppLocalizations.of(context);
    final defaultName = '${source.name}${l10n.workoutBuilderNameCopySuffix}';
    final name = await showDuplicateWeekDialog(context, defaultName);
    if (!context.mounted || name == null || name.isEmpty) return;
    cloneWeekWithName(weekIndex, name);
  }

  void cloneWeekWithName(int weekIndex, String name) {
    if (readOnly) return;
    final newId = 'w_${DateTime.now().millisecondsSinceEpoch}';
    session.cloneWeek(
      weekIndex: weekIndex,
      newWeekName: name,
      newWeekId: newId,
    );
  }

  void deleteWeek(int weekIndex) {
    if (readOnly) return;
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    final removedWeek = _routine.weeks[weekIndex];
    if (!session.deleteWeek(weekIndex)) return;
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    _showUndoSnackBar(l10n.workoutBuilderWeekRemoved, () {
      session.insertWeekAtIndex(weekIndex: weekIndex, week: removedWeek);
      session.selectWeek(weekIndex);
    });
  }

  Future<void> confirmDeleteWeek(int weekIndex) async {
    if (readOnly) return;
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
    if (readOnly) return;
    session.renameDay(weekIndex, dayIndex, newName);
  }

  void renameWeek(int weekIndex, String newName) {
    if (readOnly) return;
    session.renameWeek(weekIndex, newName);
  }

  void deleteDay(int weekIndex, int dayIndex) {
    if (readOnly) return;
    session.deleteDay(weekIndex, dayIndex);
  }

  void addDayToWeek(int weekIndex) {
    if (readOnly) return;
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
    if (readOnly) return;
    session.setDayScheduledWeekday(
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      weekday: weekday,
    );
  }

  Future<void> addExerciseToDay(int weekIndex, int dayIndex) async {
    if (readOnly) return;
    if (weekIndex < 0 || weekIndex >= _routine.weeks.length) return;
    if (dayIndex < 0 || dayIndex >= _routine.weeks[weekIndex].days.length) {
      return;
    }
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final exId = 'e_${DateTime.now().millisecondsSinceEpoch}';
    final compact = await _resolveCompactAddMode();
    if (!context.mounted) return;
    await showAddExerciseDialog(context, theme, cs, (
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
    }, customerId: customerId, compact: compact);
  }

  void addExerciseToSuperset(
    int weekIndex,
    int dayIndex,
    String supersetGroupId,
  ) {
    if (readOnly) return;
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
    if (readOnly) return;
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
    _showUndoSnackBar(l10n.workoutBuilderExerciseRemoved, () {
      session.addExerciseToDay(
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        exercise: removedExercise!,
      );
    });
  }

  void duplicateExercise(int weekIndex, int dayIndex, Exercise exercise) {
    if (readOnly) return;
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
    if (readOnly) return;
    session.moveExercise(
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
      up: up,
    );
  }

  void moveExerciseWithinSuperset(
    int weekIndex,
    int dayIndex,
    String exerciseId, {
    required bool up,
  }) {
    if (readOnly) return;
    session.moveExerciseWithinSuperset(
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
    if (readOnly) return;
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
    if (readOnly) return;
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
    if (readOnly) return;
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
    if (readOnly) return;
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
    if (readOnly) return;
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
    if (readOnly) return;
    final day =
        weekIndex >= 0 &&
            weekIndex < _routine.weeks.length &&
            dayIndex >= 0 &&
            dayIndex < _routine.weeks[weekIndex].days.length
        ? _routine.weeks[weekIndex].days[dayIndex]
        : null;
    Exercise? exercise;
    for (final candidate in day?.exercises ?? const <Exercise>[]) {
      if (candidate.id == exerciseId) {
        exercise = candidate;
        break;
      }
    }
    final previousGroupId = exercise?.supersetGroupId;
    final updated = WorkoutSupersetActions.removeFromSuperset(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exerciseId: exerciseId,
    );
    if (updated == null) return;
    session.setRoutine(updated);
    if (previousGroupId == null || previousGroupId.isEmpty || !context.mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    _showUndoSnackBar(l10n.workoutBuilderSupersetUnlinked, () {
      assignToSuperset(
        weekIndex,
        dayIndex,
        exerciseId,
        previousGroupId,
      );
    });
  }

  Future<void> cloneDayToTarget(int weekIndex, int dayIndex) async {
    if (readOnly) return;
    final l10n = AppLocalizations.of(context);
    final targets = <({int weekIndex, int dayIndex, String label})>[];
    for (var wi = 0; wi < _routine.weeks.length; wi++) {
      final week = _routine.weeks[wi];
      for (var di = 0; di < week.days.length; di++) {
        if (wi == weekIndex && di == dayIndex) continue;
        targets.add((
          weekIndex: wi,
          dayIndex: di,
          label: '${week.name} · ${week.days[di].name}',
        ));
      }
    }
    if (targets.isEmpty || !context.mounted) return;

    final selected = await showDialog<({int weekIndex, int dayIndex})>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.workoutBuilderCloneDayTargetTitle),
        content: SizedBox(
          width: double.maxFinite,
          height: 320,
          child: ListView.separated(
            itemCount: targets.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final target = targets[index];
              return ListTile(
                title: Text(target.label),
                onTap: () => Navigator.of(ctx).pop((
                  weekIndex: target.weekIndex,
                  dayIndex: target.dayIndex,
                )),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.customerCancel),
          ),
        ],
      ),
    );
    if (selected == null || !context.mounted) return;
    session.cloneDayToTarget(
      sourceWeekIndex: weekIndex,
      sourceDayIndex: dayIndex,
      targetWeekIndex: selected.weekIndex,
      targetDayIndex: selected.dayIndex,
    );
  }
}
