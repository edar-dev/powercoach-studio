import 'package:flutter/foundation.dart';

import '../data/workout_routine_model.dart';
import '../domain/exercise_prescription_scope.dart';
import '../domain/workout_exercise_mutations.dart';
import '../domain/workout_routine_mutations.dart';

/// Lightweight state holder for the workout builder editing session.
///
/// This keeps routine and week/day selection rules outside the screen while the
/// larger builder UI is migrated incrementally.
class WorkoutBuilderSessionController extends ChangeNotifier {
  WorkoutBuilderSessionController({WorkoutRoutine? routine})
    : _routine = routine ?? WorkoutRoutine.empty();

  WorkoutRoutine _routine;
  int _selectedPhaseIndex = 0;
  int _selectedWeekInPhase = 0;
  int _selectedDayIndex = 0;

  WorkoutRoutine get routine => _routine;
  int get selectedPhaseIndex => _selectedPhaseIndex;
  int get selectedWeekInPhase => _selectedWeekInPhase;
  int get selectedDayIndex => _selectedDayIndex;

  /// Global week index (calendar / session keys).
  int get selectedWeekIndex {
    final global = _routine.globalWeekIndex(
      _selectedPhaseIndex,
      _selectedWeekInPhase,
    );
    return global ?? 0;
  }

  void setRoutine(
    WorkoutRoutine routine, {
    int? selectedWeekIndex,
    int? selectedDayIndex,
    int? selectedPhaseIndex,
    int? selectedWeekInPhase,
  }) {
    _routine = routine;
    if (selectedPhaseIndex != null || selectedWeekInPhase != null) {
      _selectedPhaseIndex = _clampPhase(
        selectedPhaseIndex ?? _selectedPhaseIndex,
      );
      _selectedWeekInPhase = _clampWeekInPhase(
        _selectedPhaseIndex,
        selectedWeekInPhase ?? _selectedWeekInPhase,
      );
    } else if (selectedWeekIndex != null) {
      _setFromGlobalWeek(selectedWeekIndex);
    } else {
      _syncSelectionFromRoutine();
    }
    _selectedDayIndex = _clampDay(
      this.selectedWeekIndex,
      selectedDayIndex ?? _selectedDayIndex,
    );
    notifyListeners();
  }

  void selectPhase(int index, {bool resetWeek = true}) {
    _selectedPhaseIndex = _clampPhase(index);
    if (resetWeek) {
      _selectedWeekInPhase = 0;
      _selectedDayIndex = 0;
    } else {
      _selectedWeekInPhase = _clampWeekInPhase(
        _selectedPhaseIndex,
        _selectedWeekInPhase,
      );
      _selectedDayIndex = _clampDay(selectedWeekIndex, _selectedDayIndex);
    }
    notifyListeners();
  }

  void selectWeekInPhase(int weekInPhase, {bool resetDay = false}) {
    _selectedWeekInPhase = _clampWeekInPhase(
      _selectedPhaseIndex,
      weekInPhase,
    );
    _selectedDayIndex = resetDay
        ? 0
        : _clampDay(selectedWeekIndex, _selectedDayIndex);
    notifyListeners();
  }

  void selectWeek(int index, {bool resetDay = false}) {
    _setFromGlobalWeek(index);
    _selectedDayIndex = resetDay
        ? 0
        : _clampDay(selectedWeekIndex, _selectedDayIndex);
    notifyListeners();
  }

  void selectDay(int index) {
    _selectedDayIndex = _clampDay(selectedWeekIndex, index);
    notifyListeners();
  }

  void selectWeekDay(int weekIndex, int dayIndex) {
    _setFromGlobalWeek(weekIndex);
    _selectedDayIndex = _clampDay(selectedWeekIndex, dayIndex);
    notifyListeners();
  }

  void addWeek({
    required String weekId,
    required String weekName,
    required String firstDayId,
    required String firstDayName,
    int? phaseIndex,
  }) {
    final targetPhase = phaseIndex ?? _selectedPhaseIndex;
    _routine = addWeekToRoutine(
      routine: _routine,
      weekId: weekId,
      weekName: weekName,
      firstDayId: firstDayId,
      firstDayName: firstDayName,
      phaseIndex: _routine.phases.isEmpty
          ? null
          : (targetPhase < _routine.phases.length ? targetPhase : null),
    );
    _selectedPhaseIndex = _clampPhase(
      _routine.phases.isEmpty ? 0 : targetPhase,
    );
    final phaseWeeks = _routine.phases.isEmpty
        ? const <Week>[]
        : _routine.phases[_selectedPhaseIndex].weeks;
    _selectedWeekInPhase = phaseWeeks.isEmpty ? 0 : phaseWeeks.length - 1;
    _selectedDayIndex = 0;
    notifyListeners();
  }

  bool cloneWeek({
    required int weekIndex,
    required String newWeekName,
    required String newWeekId,
  }) {
    final updated = cloneWeekInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      newWeekName: newWeekName,
      newWeekId: newWeekId,
    );
    if (updated == null) return false;
    _routine = updated;
    final loc = _routine.locateWeek(weekIndex);
    if (loc != null) {
      _selectedPhaseIndex = loc.phaseIndex;
      _selectedWeekInPhase =
          _routine.phases[loc.phaseIndex].weeks.length - 1;
    } else {
      _setFromGlobalWeek(_routine.weeks.length - 1);
    }
    _selectedDayIndex = 0;
    notifyListeners();
    return true;
  }

  bool deleteWeek(int weekIndex) {
    final updated = deleteWeekFromRoutine(
      routine: _routine,
      weekIndex: weekIndex,
    );
    if (updated == null) return false;
    _routine = updated;
    _syncSelectionFromRoutine();
    notifyListeners();
    return true;
  }

  bool insertWeekAtIndex({required int weekIndex, required Week week}) {
    final updated = insertWeekAtIndexInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      week: week,
    );
    if (updated == null) return false;
    _routine = updated;
    _setFromGlobalWeek(weekIndex);
    _selectedDayIndex = _clampDay(selectedWeekIndex, _selectedDayIndex);
    notifyListeners();
    return true;
  }

  bool addPhase({
    required String phaseId,
    required String phaseName,
    String? objective,
    List<Week>? weeks,
  }) {
    _routine = addPhaseToRoutine(
      routine: _routine,
      phaseId: phaseId,
      phaseName: phaseName,
      objective: objective,
      weeks: weeks,
    );
    _selectedPhaseIndex = _routine.phases.length - 1;
    _selectedWeekInPhase = 0;
    _selectedDayIndex = 0;
    notifyListeners();
    return true;
  }

  bool renamePhase(int phaseIndex, String newName) {
    return _replacePhaseSelection(
      renamePhaseInRoutine(
        routine: _routine,
        phaseIndex: phaseIndex,
        newName: newName,
      ),
      preferredPhaseIndex: phaseIndex,
    );
  }

  bool setPhaseObjective(int phaseIndex, String? objective) {
    return _replacePhaseSelection(
      setPhaseObjectiveInRoutine(
        routine: _routine,
        phaseIndex: phaseIndex,
        objective: objective,
      ),
      preferredPhaseIndex: phaseIndex,
    );
  }

  bool duplicatePhase({
    required int phaseIndex,
    required String newPhaseId,
    String? newPhaseName,
  }) {
    final updated = duplicatePhaseInRoutine(
      routine: _routine,
      phaseIndex: phaseIndex,
      newPhaseId: newPhaseId,
      newPhaseName: newPhaseName,
    );
    if (updated == null) return false;
    _routine = updated;
    _selectedPhaseIndex = _clampPhase(phaseIndex + 1);
    _selectedWeekInPhase = 0;
    _selectedDayIndex = 0;
    notifyListeners();
    return true;
  }

  bool deletePhase(int phaseIndex) {
    final updated = deletePhaseFromRoutine(
      routine: _routine,
      phaseIndex: phaseIndex,
    );
    if (updated == null) return false;
    _routine = updated;
    _syncSelectionFromRoutine();
    notifyListeners();
    return true;
  }

  bool insertPhaseAtIndex({required int phaseIndex, required Phase phase}) {
    final updated = insertPhaseAtIndexInRoutine(
      routine: _routine,
      phaseIndex: phaseIndex,
      phase: phase,
    );
    if (updated == null) return false;
    _routine = updated;
    _selectedPhaseIndex = _clampPhase(phaseIndex);
    _selectedWeekInPhase = 0;
    _selectedDayIndex = 0;
    notifyListeners();
    return true;
  }

  bool renameWeek(int weekIndex, String newName) {
    return _replace(
      renameWeekInRoutine(
        routine: _routine,
        weekIndex: weekIndex,
        newName: newName,
      ),
    );
  }

  bool renameDay(int weekIndex, int dayIndex, String newName) {
    return _replace(
      renameDayInRoutine(
        routine: _routine,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        newName: newName,
      ),
    );
  }

  bool deleteDay(int weekIndex, int dayIndex) {
    final updated = deleteDayFromRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayIndex: dayIndex,
    );
    if (updated == null) return false;
    _routine = updated;
    _setFromGlobalWeek(weekIndex);
    _selectedDayIndex = _clampDay(selectedWeekIndex, _selectedDayIndex);
    notifyListeners();
    return true;
  }

  bool addDayToWeek({
    required int weekIndex,
    required String dayId,
    required String dayName,
  }) {
    final updated = addDayToWeekInRoutine(
      routine: _routine,
      weekIndex: weekIndex,
      dayId: dayId,
      dayName: dayName,
    );
    if (updated == null) return false;
    _routine = updated;
    _setFromGlobalWeek(weekIndex);
    final days = _routine.weeks[selectedWeekIndex].days;
    _selectedDayIndex = days.isEmpty ? 0 : days.length - 1;
    notifyListeners();
    return true;
  }

  bool cloneDayToTarget({
    required int sourceWeekIndex,
    required int sourceDayIndex,
    required int targetWeekIndex,
    required int targetDayIndex,
  }) {
    final updated = cloneDayToTargetInRoutine(
      routine: _routine,
      sourceWeekIndex: sourceWeekIndex,
      sourceDayIndex: sourceDayIndex,
      targetWeekIndex: targetWeekIndex,
      targetDayIndex: targetDayIndex,
    );
    if (updated == null) return false;
    _routine = updated;
    _setFromGlobalWeek(targetWeekIndex);
    _selectedDayIndex = _clampDay(selectedWeekIndex, targetDayIndex);
    notifyListeners();
    return true;
  }

  bool addExerciseToDay({
    required int weekIndex,
    required int dayIndex,
    required Exercise exercise,
  }) {
    return _replace(
      addExerciseToDayInRoutine(
        routine: _routine,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        exercise: exercise,
      ),
    );
  }

  bool duplicateExercise({
    required int weekIndex,
    required int dayIndex,
    required Exercise source,
    required String newExerciseId,
  }) {
    return addExerciseToDay(
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      exercise: source.copyWith(id: newExerciseId),
    );
  }

  bool removeExercise({
    required int weekIndex,
    required int dayIndex,
    required String exerciseId,
  }) {
    return _replace(
      removeExerciseFromDayInRoutine(
        routine: _routine,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        exerciseId: exerciseId,
      ),
    );
  }

  bool moveExercise({
    required int weekIndex,
    required int dayIndex,
    required String exerciseId,
    required bool up,
  }) {
    return _replace(
      moveExerciseInDayInRoutine(
        routine: _routine,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        exerciseId: exerciseId,
        up: up,
      ),
    );
  }

  bool moveExerciseWithinSuperset({
    required int weekIndex,
    required int dayIndex,
    required String exerciseId,
    required bool up,
  }) {
    return _replace(
      moveExerciseWithinSupersetInRoutine(
        routine: _routine,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        exerciseId: exerciseId,
        up: up,
      ),
    );
  }

  bool updateExercise({
    required int weekIndex,
    required int dayIndex,
    required String exerciseId,
    String? name,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
    String? shortName,
    ExercisePrescriptionScope? prescriptionScope,
    List<ExerciseSet>? setDetails,
  }) {
    return _replace(
      updateExerciseInRoutine(
        routine: _routine,
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
      ),
    );
  }

  bool addSetToExercise({
    required int weekIndex,
    required int dayIndex,
    required String exerciseId,
  }) {
    return _replace(
      addSetToExerciseInRoutine(
        routine: _routine,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        exerciseId: exerciseId,
      ),
    );
  }

  bool updateExerciseSet({
    required int weekIndex,
    required int dayIndex,
    required String exerciseId,
    required int setIndex,
    String? line,
    String? sets,
    String? reps,
    String? rpe,
    String? note,
  }) {
    return _replace(
      updateExerciseSetInRoutine(
        routine: _routine,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        exerciseId: exerciseId,
        setIndex: setIndex,
        line: line,
        sets: sets,
        reps: reps,
        rpe: rpe,
        note: note,
      ),
    );
  }

  bool removeExerciseSet({
    required int weekIndex,
    required int dayIndex,
    required String exerciseId,
    required int setIndex,
  }) {
    return _replace(
      removeExerciseSetInRoutine(
        routine: _routine,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        exerciseId: exerciseId,
        setIndex: setIndex,
      ),
    );
  }

  bool setDayScheduledWeekday({
    required int weekIndex,
    required int dayIndex,
    required int weekday,
  }) {
    return _replace(
      setDayScheduledWeekdayInRoutine(
        routine: _routine,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        weekday: weekday,
      ),
    );
  }

  bool clearDayScheduledWeekday({
    required int weekIndex,
    required int dayIndex,
  }) {
    return _replace(
      clearDayScheduledWeekdayInRoutine(
        routine: _routine,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
      ),
    );
  }

  bool setDayCoachingNote({
    required int weekIndex,
    required int dayIndex,
    required String coachingNote,
  }) {
    return _replace(
      setDayCoachingNoteInRoutine(
        routine: _routine,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        coachingNote: coachingNote,
      ),
    );
  }

  bool _replace(WorkoutRoutine? updated) {
    if (updated == null) return false;
    _routine = updated;
    _syncSelectionFromRoutine();
    notifyListeners();
    return true;
  }

  bool _replacePhaseSelection(
    WorkoutRoutine? updated, {
    required int preferredPhaseIndex,
  }) {
    if (updated == null) return false;
    _routine = updated;
    _selectedPhaseIndex = _clampPhase(preferredPhaseIndex);
    _selectedWeekInPhase = _clampWeekInPhase(
      _selectedPhaseIndex,
      _selectedWeekInPhase,
    );
    _selectedDayIndex = _clampDay(selectedWeekIndex, _selectedDayIndex);
    notifyListeners();
    return true;
  }

  void _setFromGlobalWeek(int globalWeekIndex) {
    final loc = _routine.locateWeek(_clampWeek(globalWeekIndex));
    if (loc == null) {
      _selectedPhaseIndex = _clampPhase(0);
      _selectedWeekInPhase = 0;
      return;
    }
    _selectedPhaseIndex = loc.phaseIndex;
    _selectedWeekInPhase = loc.weekIndexInPhase;
  }

  void _syncSelectionFromRoutine() {
    if (_routine.phases.isEmpty) {
      _selectedPhaseIndex = 0;
      _selectedWeekInPhase = 0;
      _selectedDayIndex = 0;
      return;
    }
    _selectedPhaseIndex = _clampPhase(_selectedPhaseIndex);
    _selectedWeekInPhase = _clampWeekInPhase(
      _selectedPhaseIndex,
      _selectedWeekInPhase,
    );
    _selectedDayIndex = _clampDay(selectedWeekIndex, _selectedDayIndex);
  }

  int _clampPhase(int index) {
    if (_routine.phases.isEmpty) return 0;
    return index.clamp(0, _routine.phases.length - 1);
  }

  int _clampWeekInPhase(int phaseIndex, int weekInPhase) {
    if (_routine.phases.isEmpty) return 0;
    final weeks = _routine.phases[_clampPhase(phaseIndex)].weeks;
    if (weeks.isEmpty) return 0;
    return weekInPhase.clamp(0, weeks.length - 1);
  }

  int _clampWeek(int index) {
    if (_routine.weeks.isEmpty) return 0;
    return index.clamp(0, _routine.weeks.length - 1);
  }

  int _clampDay(int weekIndex, int index) {
    if (_routine.weeks.isEmpty) return 0;
    final days = _routine.weeks[_clampWeek(weekIndex)].days;
    if (days.isEmpty) return 0;
    return index.clamp(0, days.length - 1);
  }
}
