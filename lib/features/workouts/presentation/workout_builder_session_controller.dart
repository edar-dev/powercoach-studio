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
  int _selectedWeekIndex = 0;
  int _selectedDayIndex = 0;

  WorkoutRoutine get routine => _routine;
  int get selectedWeekIndex => _selectedWeekIndex;
  int get selectedDayIndex => _selectedDayIndex;

  void setRoutine(
    WorkoutRoutine routine, {
    int? selectedWeekIndex,
    int? selectedDayIndex,
  }) {
    _routine = routine;
    _selectedWeekIndex = _clampWeek(selectedWeekIndex ?? _selectedWeekIndex);
    _selectedDayIndex = _clampDay(
      _selectedWeekIndex,
      selectedDayIndex ?? _selectedDayIndex,
    );
    notifyListeners();
  }

  void selectWeek(int index, {bool resetDay = false}) {
    _selectedWeekIndex = _clampWeek(index);
    _selectedDayIndex = resetDay
        ? 0
        : _clampDay(_selectedWeekIndex, _selectedDayIndex);
    notifyListeners();
  }

  void selectDay(int index) {
    _selectedDayIndex = _clampDay(_selectedWeekIndex, index);
    notifyListeners();
  }

  void selectWeekDay(int weekIndex, int dayIndex) {
    _selectedWeekIndex = _clampWeek(weekIndex);
    _selectedDayIndex = _clampDay(_selectedWeekIndex, dayIndex);
    notifyListeners();
  }

  void addWeek({
    required String weekId,
    required String weekName,
    required String firstDayId,
    required String firstDayName,
  }) {
    _routine = addWeekToRoutine(
      routine: _routine,
      weekId: weekId,
      weekName: weekName,
      firstDayId: firstDayId,
      firstDayName: firstDayName,
    );
    _selectedWeekIndex = _routine.weeks.length - 1;
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
    _selectedWeekIndex = _routine.weeks.length - 1;
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
    _selectedWeekIndex = _clampWeek(_selectedWeekIndex);
    _selectedDayIndex = _clampDay(_selectedWeekIndex, _selectedDayIndex);
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
    _selectedWeekIndex = _clampWeek(weekIndex);
    _selectedDayIndex = _clampDay(_selectedWeekIndex, _selectedDayIndex);
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
    _selectedWeekIndex = _clampWeek(_selectedWeekIndex);
    _selectedDayIndex = _clampDay(_selectedWeekIndex, _selectedDayIndex);
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
    _selectedWeekIndex = _clampWeek(weekIndex);
    _selectedDayIndex = _routine.weeks[_selectedWeekIndex].days.length - 1;
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
    _selectedWeekIndex = _clampWeek(targetWeekIndex);
    _selectedDayIndex = _clampDay(_selectedWeekIndex, targetDayIndex);
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

  bool _replace(WorkoutRoutine? updated) {
    if (updated == null) return false;
    _routine = updated;
    _selectedWeekIndex = _clampWeek(_selectedWeekIndex);
    _selectedDayIndex = _clampDay(_selectedWeekIndex, _selectedDayIndex);
    notifyListeners();
    return true;
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
