import '../data/workout_routine_model.dart';
import 'session_execution.dart';

/// Editable set row while logging a session.
class SessionLogSetDraft {
  SessionLogSetDraft({
    this.reps = '',
    this.load = '',
    this.completed = true,
  });

  String reps;
  String load;
  bool completed;

  ExecutedSet toExecutedSet() => ExecutedSet(
        reps: reps.trim(),
        load: load.trim(),
        completed: completed,
      );

  static SessionLogSetDraft fromExecutedSet(ExecutedSet set) =>
      SessionLogSetDraft(
        reps: set.reps,
        load: set.load,
        completed: set.completed,
      );
}

/// Editable exercise row while logging a session.
class SessionLogExerciseDraft {
  SessionLogExerciseDraft({
    required this.exerciseId,
    required this.name,
    this.customExerciseId,
    required this.completed,
    required this.sets,
  });

  final String exerciseId;
  final String name;
  final String? customExerciseId;
  bool completed;
  List<SessionLogSetDraft> sets;

  ExecutedExercise toExecutedExercise() => ExecutedExercise(
        exerciseId: exerciseId,
        name: name,
        customExerciseId: customExerciseId,
        completed: completed,
        sets: sets.map((s) => s.toExecutedSet()).toList(),
      );
}

List<SessionLogExerciseDraft> buildSessionLogDrafts({
  required List<Exercise> plannedExercises,
  List<ExecutedExercise>? initialExercises,
}) {
  final initialById = {
    if (initialExercises != null)
      for (final exercise in initialExercises) exercise.exerciseId: exercise,
  };

  return plannedExercises.map((planned) {
    final existing = initialById[planned.id];
    if (existing != null) {
      final sets = existing.sets.isEmpty
          ? [_defaultSetFromPlan(planned)]
          : existing.sets.map(SessionLogSetDraft.fromExecutedSet).toList();
      return SessionLogExerciseDraft(
        exerciseId: planned.id,
        name: planned.name,
        customExerciseId: planned.customExerciseId ?? existing.customExerciseId,
        completed: existing.completed,
        sets: sets,
      );
    }

    final plannedSets = planned.effectiveSetDetails;
    final sets = plannedSets
        .map(
          (detail) => SessionLogSetDraft(
            reps: detail.reps,
            load: detail.rpe,
            completed: true,
          ),
        )
        .toList();
    if (sets.isEmpty) {
      sets.add(SessionLogSetDraft());
    }

    return SessionLogExerciseDraft(
      exerciseId: planned.id,
      name: planned.name,
      customExerciseId: planned.customExerciseId,
      completed: true,
      sets: sets,
    );
  }).toList();
}

SessionLogSetDraft _defaultSetFromPlan(Exercise planned) {
  final details = planned.effectiveSetDetails;
  if (details.isEmpty) return SessionLogSetDraft();
  final detail = details.first;
  return SessionLogSetDraft(
    reps: detail.reps,
    load: detail.rpe,
    completed: true,
  );
}

List<ExecutedExercise> sessionLogDraftsToExecuted(
  List<SessionLogExerciseDraft> drafts,
) {
  return drafts.map((draft) => draft.toExecutedExercise()).toList();
}
