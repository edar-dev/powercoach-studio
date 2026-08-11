// Structural diff between two [WorkoutRoutine] versions of the same plan
// (or between a plan and one of its follow-ups/templates), used by the plan
// version comparison screen. Session state (completion/skip/override/
// execution maps) is stripped before comparing — this is a structure diff,
// not a "who did what" diff.

import '../data/workout_routine_model.dart';

/// Kind of structural change for a diffed node (week/day/exercise/set).
enum WorkoutRoutineDiffKind { unchanged, added, removed, changed }

/// Per-set prescription diff (index-aligned within the matched exercise).
class ExerciseSetDiff {
  const ExerciseSetDiff({
    required this.setIndex,
    required this.kind,
    this.before,
    this.after,
  });

  final int setIndex;
  final WorkoutRoutineDiffKind kind;
  final ExerciseSet? before;
  final ExerciseSet? after;

  bool get hasChange => kind != WorkoutRoutineDiffKind.unchanged;
}

/// Exercise-level diff within a matched day.
class ExerciseDiff {
  const ExerciseDiff({
    required this.name,
    required this.kind,
    this.before,
    this.after,
    this.setDiffs = const [],
  });

  final String name;
  final WorkoutRoutineDiffKind kind;
  final Exercise? before;
  final Exercise? after;
  final List<ExerciseSetDiff> setDiffs;

  bool get hasChange =>
      kind != WorkoutRoutineDiffKind.unchanged ||
      setDiffs.any((d) => d.hasChange);
}

/// Day-level diff within a matched week (by index).
class DayDiff {
  const DayDiff({
    required this.weekIndex,
    required this.dayIndex,
    required this.name,
    required this.kind,
    this.before,
    this.after,
    this.coachingNoteBefore,
    this.coachingNoteAfter,
    this.exerciseDiffs = const [],
  });

  final int weekIndex;
  final int dayIndex;
  final String name;
  final WorkoutRoutineDiffKind kind;
  final Day? before;
  final Day? after;
  final String? coachingNoteBefore;
  final String? coachingNoteAfter;
  final List<ExerciseDiff> exerciseDiffs;

  bool get coachingNoteChanged =>
      (coachingNoteBefore?.trim() ?? '') != (coachingNoteAfter?.trim() ?? '');

  bool get hasChange =>
      kind != WorkoutRoutineDiffKind.unchanged ||
      coachingNoteChanged ||
      exerciseDiffs.any((d) => d.hasChange);
}

/// Week-level diff (by index).
class WeekDiff {
  const WeekDiff({
    required this.weekIndex,
    required this.name,
    required this.kind,
    this.dayDiffs = const [],
  });

  final int weekIndex;
  final String name;
  final WorkoutRoutineDiffKind kind;
  final List<DayDiff> dayDiffs;

  bool get hasChange =>
      kind != WorkoutRoutineDiffKind.unchanged ||
      dayDiffs.any((d) => d.hasChange);
}

/// Full structural diff result between two routine snapshots (A vs B).
class WorkoutRoutineDiffResult {
  const WorkoutRoutineDiffResult({required this.weekDiffs});

  final List<WeekDiff> weekDiffs;

  int get addedDayCount => _countDays(WorkoutRoutineDiffKind.added);
  int get removedDayCount => _countDays(WorkoutRoutineDiffKind.removed);
  int get changedDayCount => _countDays(WorkoutRoutineDiffKind.changed);

  int get addedExerciseCount => _countExercises(WorkoutRoutineDiffKind.added);
  int get removedExerciseCount =>
      _countExercises(WorkoutRoutineDiffKind.removed);
  int get changedExerciseCount =>
      _countExercises(WorkoutRoutineDiffKind.changed);

  bool get hasChanges => weekDiffs.any((w) => w.hasChange);

  int _countDays(WorkoutRoutineDiffKind kind) => weekDiffs
      .expand((w) => w.dayDiffs)
      .where((d) => d.kind == kind)
      .length;

  int _countExercises(WorkoutRoutineDiffKind kind) => weekDiffs
      .expand((w) => w.dayDiffs)
      .expand((d) => d.exerciseDiffs)
      .where((e) => e.kind == kind)
      .length;
}

/// Strips session state (completion/skip/override/execution maps) so the
/// comparison only reflects plan structure and content.
WorkoutRoutine _stripSessionState(WorkoutRoutine routine) => routine.copyWith(
  sessionCompletionByKey: const {},
  sessionSkippedByKey: const {},
  sessionOverrides: const {},
  sessionExecutions: const {},
);

/// Compares [planA] (baseline) against [planB] (other version) and returns a
/// structural diff: weeks/days matched by index, exercises matched by id
/// then normalized name (mirrors [workout_follow_up_factory]'s matching).
WorkoutRoutineDiffResult diffWorkoutRoutines({
  required WorkoutRoutine planA,
  required WorkoutRoutine planB,
}) {
  final a = _stripSessionState(planA);
  final b = _stripSessionState(planB);

  final weekCount = a.weeks.length > b.weeks.length
      ? a.weeks.length
      : b.weeks.length;
  final weekDiffs = <WeekDiff>[];
  for (var weekIndex = 0; weekIndex < weekCount; weekIndex++) {
    final weekA = weekIndex < a.weeks.length ? a.weeks[weekIndex] : null;
    final weekB = weekIndex < b.weeks.length ? b.weeks[weekIndex] : null;
    weekDiffs.add(_diffWeek(weekIndex, weekA, weekB));
  }
  return WorkoutRoutineDiffResult(weekDiffs: weekDiffs);
}

WeekDiff _diffWeek(int weekIndex, Week? weekA, Week? weekB) {
  if (weekA == null && weekB == null) {
    return WeekDiff(
      weekIndex: weekIndex,
      name: '',
      kind: WorkoutRoutineDiffKind.unchanged,
    );
  }
  if (weekA == null) {
    return WeekDiff(
      weekIndex: weekIndex,
      name: weekB!.name,
      kind: WorkoutRoutineDiffKind.added,
      dayDiffs: [
        for (var i = 0; i < weekB.days.length; i++)
          _diffDay(weekIndex, i, null, weekB.days[i]),
      ],
    );
  }
  if (weekB == null) {
    return WeekDiff(
      weekIndex: weekIndex,
      name: weekA.name,
      kind: WorkoutRoutineDiffKind.removed,
      dayDiffs: [
        for (var i = 0; i < weekA.days.length; i++)
          _diffDay(weekIndex, i, weekA.days[i], null),
      ],
    );
  }

  final dayCount = weekA.days.length > weekB.days.length
      ? weekA.days.length
      : weekB.days.length;
  final dayDiffs = <DayDiff>[];
  for (var dayIndex = 0; dayIndex < dayCount; dayIndex++) {
    final dayA = dayIndex < weekA.days.length ? weekA.days[dayIndex] : null;
    final dayB = dayIndex < weekB.days.length ? weekB.days[dayIndex] : null;
    dayDiffs.add(_diffDay(weekIndex, dayIndex, dayA, dayB));
  }
  final kind = dayDiffs.any((d) => d.hasChange)
      ? WorkoutRoutineDiffKind.changed
      : WorkoutRoutineDiffKind.unchanged;
  return WeekDiff(
    weekIndex: weekIndex,
    name: weekB.name.isNotEmpty ? weekB.name : weekA.name,
    kind: kind,
    dayDiffs: dayDiffs,
  );
}

DayDiff _diffDay(int weekIndex, int dayIndex, Day? dayA, Day? dayB) {
  if (dayA == null && dayB == null) {
    return DayDiff(
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      name: '',
      kind: WorkoutRoutineDiffKind.unchanged,
    );
  }
  if (dayA == null) {
    return DayDiff(
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      name: dayB!.name,
      kind: WorkoutRoutineDiffKind.added,
      after: dayB,
      coachingNoteAfter: dayB.coachingNote,
      exerciseDiffs: _matchExercises(const [], dayB.exercises),
    );
  }
  if (dayB == null) {
    return DayDiff(
      weekIndex: weekIndex,
      dayIndex: dayIndex,
      name: dayA.name,
      kind: WorkoutRoutineDiffKind.removed,
      before: dayA,
      coachingNoteBefore: dayA.coachingNote,
      exerciseDiffs: _matchExercises(dayA.exercises, const []),
    );
  }

  final exerciseDiffs = _matchExercises(dayA.exercises, dayB.exercises);
  final coachingNoteChanged =
      (dayA.coachingNote?.trim() ?? '') != (dayB.coachingNote?.trim() ?? '');
  final kind =
      exerciseDiffs.any((e) => e.hasChange) || coachingNoteChanged
      ? WorkoutRoutineDiffKind.changed
      : WorkoutRoutineDiffKind.unchanged;
  return DayDiff(
    weekIndex: weekIndex,
    dayIndex: dayIndex,
    name: dayB.name.isNotEmpty ? dayB.name : dayA.name,
    kind: kind,
    before: dayA,
    after: dayB,
    coachingNoteBefore: dayA.coachingNote,
    coachingNoteAfter: dayB.coachingNote,
    exerciseDiffs: exerciseDiffs,
  );
}

/// Matches exercises by id first, then by normalized name — mirrors the
/// lookup priority used in `workout_follow_up_factory.dart`.
List<ExerciseDiff> _matchExercises(
  List<Exercise> exercisesA,
  List<Exercise> exercisesB,
) {
  final consumedB = List<bool>.filled(exercisesB.length, false);
  final diffs = <ExerciseDiff>[];

  int? findMatch(Exercise planned) {
    if (planned.id.isNotEmpty) {
      for (var i = 0; i < exercisesB.length; i++) {
        if (!consumedB[i] && exercisesB[i].id == planned.id) return i;
      }
    }
    final normalizedName = planned.name.trim().toLowerCase();
    if (normalizedName.isNotEmpty) {
      for (var i = 0; i < exercisesB.length; i++) {
        if (!consumedB[i] &&
            exercisesB[i].name.trim().toLowerCase() == normalizedName) {
          return i;
        }
      }
    }
    return null;
  }

  for (final exerciseA in exercisesA) {
    final matchIndex = findMatch(exerciseA);
    if (matchIndex == null) {
      diffs.add(
        ExerciseDiff(
          name: exerciseA.name,
          kind: WorkoutRoutineDiffKind.removed,
          before: exerciseA,
          setDiffs: _matchSets(exerciseA.effectiveSetDetails, const []),
        ),
      );
      continue;
    }
    consumedB[matchIndex] = true;
    final exerciseB = exercisesB[matchIndex];
    final setDiffs = _matchSets(
      exerciseA.effectiveSetDetails,
      exerciseB.effectiveSetDetails,
    );
    final changed = setDiffs.any((s) => s.hasChange) ||
        exerciseA.name != exerciseB.name ||
        exerciseA.note != exerciseB.note ||
        exerciseA.supersetGroupId != exerciseB.supersetGroupId ||
        exerciseA.prescriptionScope != exerciseB.prescriptionScope;
    diffs.add(
      ExerciseDiff(
        name: exerciseB.name.isNotEmpty ? exerciseB.name : exerciseA.name,
        kind: changed
            ? WorkoutRoutineDiffKind.changed
            : WorkoutRoutineDiffKind.unchanged,
        before: exerciseA,
        after: exerciseB,
        setDiffs: setDiffs,
      ),
    );
  }

  for (var i = 0; i < exercisesB.length; i++) {
    if (consumedB[i]) continue;
    diffs.add(
      ExerciseDiff(
        name: exercisesB[i].name,
        kind: WorkoutRoutineDiffKind.added,
        after: exercisesB[i],
        setDiffs: _matchSets(const [], exercisesB[i].effectiveSetDetails),
      ),
    );
  }

  return diffs;
}

/// Index-aligned set diff (sets don't carry a stable id — position is the
/// only reasonable anchor within a matched exercise).
List<ExerciseSetDiff> _matchSets(
  List<ExerciseSet> setsA,
  List<ExerciseSet> setsB,
) {
  final count = setsA.length > setsB.length ? setsA.length : setsB.length;
  final diffs = <ExerciseSetDiff>[];
  for (var i = 0; i < count; i++) {
    final setA = i < setsA.length ? setsA[i] : null;
    final setB = i < setsB.length ? setsB[i] : null;
    WorkoutRoutineDiffKind kind;
    if (setA == null) {
      kind = WorkoutRoutineDiffKind.added;
    } else if (setB == null) {
      kind = WorkoutRoutineDiffKind.removed;
    } else if (setA.reps != setB.reps ||
        setA.rpe != setB.rpe ||
        setA.sets != setB.sets ||
        setA.line != setB.line ||
        setA.note != setB.note) {
      kind = WorkoutRoutineDiffKind.changed;
    } else {
      kind = WorkoutRoutineDiffKind.unchanged;
    }
    diffs.add(
      ExerciseSetDiff(setIndex: i, kind: kind, before: setA, after: setB),
    );
  }
  return diffs;
}
