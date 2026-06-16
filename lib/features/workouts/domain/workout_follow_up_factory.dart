import '../../dashboard/domain/plan_calendar_event.dart';
import '../data/workout_routine_model.dart';
import 'session_execution.dart';

/// Options when cloning a follow-up routine from a completed mesocycle.
class FollowUpOptions {
  const FollowUpOptions({this.applyExecutedLoads = false});

  final bool applyExecutedLoads;
}

/// Builds a follow-up routine from an existing plan routine.
///
/// The returned routine keeps structure/content while resetting completion state
/// and assignment window markers for a new planning cycle.
WorkoutRoutine prepareFollowUpRoutine({
  required WorkoutRoutine source,
  DateTime? newStartDate,
  List<SessionExecution> executions = const [],
  FollowUpOptions options = const FollowUpOptions(),
}) {
  final cloned = WorkoutRoutine.fromJson(source.toJson());
  final resolvedStart = newStartDate != null
      ? DateTime(newStartDate.year, newStartDate.month, newStartDate.day)
      : cloned.startDate;

  var weeks = cloned.weeks;
  if (options.applyExecutedLoads && executions.isNotEmpty) {
    weeks = _applyExecutedLoadsToWeeks(weeks, executions);
  }

  return WorkoutRoutine(
    name: cloned.name,
    mobilitySections: cloned.mobilitySections,
    mobilityItems: cloned.mobilityItems,
    weeks: weeks,
    startDate: resolvedStart,
    endDate: null,
    currentWeek: 1,
    sessionCompletionByKey: const {},
    sessionSkippedByKey: const {},
    sessionOverrides: const {},
    sessionExecutions: const {},
  );
}

List<Week> _applyExecutedLoadsToWeeks(
  List<Week> weeks,
  List<SessionExecution> executions,
) {
  final completed = executions
      .where((e) => e.status == PlanSessionStatus.completed)
      .toList()
    ..sort((a, b) {
      final aDate = a.completedAt ?? a.sessionDate;
      final bDate = b.completedAt ?? b.sessionDate;
      return bDate.compareTo(aDate);
    });

  if (completed.isEmpty) return weeks;

  final latestByExerciseId = <String, ExecutedExercise>{};
  for (final session in completed) {
    for (final exercise in session.exercises) {
      if (!exercise.completed) continue;
      final key = exercise.exerciseId.isNotEmpty
          ? exercise.exerciseId
          : exercise.name.trim().toLowerCase();
      if (key.isEmpty) continue;
      latestByExerciseId.putIfAbsent(key, () => exercise);
    }
  }

  if (latestByExerciseId.isEmpty) return weeks;

  return weeks
      .map(
        (week) => week.copyWith(
          days: week.days
              .map(
                (day) => day.copyWith(
                  exercises: day.exercises
                      .map((e) => _mergeExerciseLoads(e, latestByExerciseId))
                      .toList(),
                ),
              )
              .toList(),
        ),
      )
      .toList();
}

Exercise _mergeExerciseLoads(
  Exercise planned,
  Map<String, ExecutedExercise> latestByExerciseId,
) {
  final keys = <String>[
    if (planned.id.isNotEmpty) planned.id,
    if (planned.name.trim().isNotEmpty) planned.name.trim().toLowerCase(),
  ];
  ExecutedExercise? executed;
  for (final key in keys) {
    executed = latestByExerciseId[key];
    if (executed != null) break;
  }
  if (executed == null || executed.sets.isEmpty) return planned;

  final setDetails = planned.setDetails ?? const [];
  if (setDetails.isEmpty) {
    final first = executed.sets.first;
    return planned.copyWith(
      reps: first.reps.isNotEmpty ? first.reps : planned.reps,
      setDetails: [
        ExerciseSet(
          reps: first.reps.isNotEmpty ? first.reps : planned.reps,
          rpe: first.load.isNotEmpty ? first.load : planned.rpe,
        ),
      ],
    );
  }

  final mergedSets = <ExerciseSet>[];
  for (var i = 0; i < setDetails.length; i++) {
    final plannedSet = setDetails[i];
    final executedSet = i < executed.sets.length ? executed.sets[i] : null;
    mergedSets.add(
      plannedSet.copyWith(
        reps: executedSet != null && executedSet.reps.isNotEmpty
            ? executedSet.reps
            : plannedSet.reps,
        rpe: executedSet != null && executedSet.load.isNotEmpty
            ? executedSet.load
            : plannedSet.rpe,
      ),
    );
  }

  return planned.copyWith(setDetails: mergedSets);
}

/// Count of completed sessions available for follow-up load copy.
int countCompletedExecutions(List<SessionExecution> executions) =>
    executions.where((e) => e.status == PlanSessionStatus.completed).length;
