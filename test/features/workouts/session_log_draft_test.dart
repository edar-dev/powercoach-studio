import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/session_execution.dart';
import 'package:powercoach_studio/features/workouts/domain/session_log_draft.dart';

void main() {
  Exercise planned({
    required String id,
    List<ExerciseSet>? setDetails,
  }) {
    return Exercise(
      id: id,
      name: 'Bench press',
      sets: '3',
      reps: '8',
      rpe: '80kg',
      setDetails: setDetails,
    );
  }

  test('buildSessionLogDrafts seeds sets from plan prescriptions', () {
    final drafts = buildSessionLogDrafts(
      plannedExercises: [
        planned(
          id: 'e1',
          setDetails: const [
            ExerciseSet(reps: '8', rpe: '80kg'),
            ExerciseSet(reps: '6', rpe: '85kg'),
          ],
        ),
      ],
    );

    expect(drafts, hasLength(1));
    expect(drafts.first.sets, hasLength(2));
    expect(drafts.first.sets.first.reps, '8');
    expect(drafts.first.sets.first.load, '80kg');
  });

  test('buildSessionLogDrafts prefers existing execution sets', () {
    final drafts = buildSessionLogDrafts(
      plannedExercises: [planned(id: 'e1')],
      initialExercises: const [
        ExecutedExercise(
          exerciseId: 'e1',
          name: 'Bench press',
          completed: true,
          sets: [
            ExecutedSet(reps: '10', load: '70kg', completed: true),
          ],
        ),
      ],
    );

    expect(drafts.first.sets.single.reps, '10');
    expect(drafts.first.sets.single.load, '70kg');
  });

  test('sessionLogDraftsToExecuted preserves edited values', () {
    final drafts = [
      SessionLogExerciseDraft(
        exerciseId: 'e1',
        name: 'Squat',
        completed: true,
        sets: [
          SessionLogSetDraft(reps: '5', load: '100kg'),
        ],
      ),
    ];

    final executed = sessionLogDraftsToExecuted(drafts);
    expect(executed.single.sets.single.reps, '5');
    expect(executed.single.sets.single.load, '100kg');
  });
}
