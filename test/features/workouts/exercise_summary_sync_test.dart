import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/exercise_summary_sync.dart';

void main() {
  test('apply syncs legacy summary fields from setDetails', () {
    const exercise = Exercise(
      id: 'e1',
      name: 'Bench Press',
      sets: '1',
      reps: 'legacy',
      rpe: 'legacy',
      setDetails: [
        ExerciseSet(reps: '5', rpe: '77.5'),
        ExerciseSet(reps: '4', rpe: '82.5'),
      ],
    );

    final synced = ExerciseSummarySync.apply(exercise);
    expect(synced.sets, '2');
    expect(synced.reps, '1x5 77.5 | 1x4 82.5');
    expect(synced.rpe, '');
  });

  test('apply sums block size for single ExerciseSet(sets:3, reps:8)', () {
    const exercise = Exercise(
      id: 'e1',
      name: 'Squat',
      sets: '1',
      reps: 'legacy',
      rpe: '',
      setDetails: [
        ExerciseSet(sets: '3', reps: '8'),
      ],
    );

    final synced = ExerciseSummarySync.apply(exercise);
    expect(synced.sets, '3');
    expect(synced.reps, contains('3x8'));
    expect(synced.rpe, '');
  });

  test('totalSetsFromDetails sums physical block sizes', () {
    const details = [
      ExerciseSet(sets: '3', reps: '5'),
      ExerciseSet(sets: '4', reps: '8'),
    ];
    expect(ExerciseSummarySync.totalSetsFromDetails(details), 7);
  });

  test('totalSetsFromExercises sums physical sets not row count', () {
    const exercises = [
      Exercise(
        id: 'e1',
        name: 'Bench',
        sets: '1',
        reps: '',
        rpe: '',
        setDetails: [
          ExerciseSet(sets: '3', reps: '5'),
          ExerciseSet(sets: '4', reps: '8'),
        ],
      ),
      Exercise(
        id: 'e2',
        name: 'Squat',
        sets: '1',
        reps: '',
        rpe: '',
        setDetails: [
          ExerciseSet(sets: '2', reps: '3'),
        ],
      ),
    ];
    // Physical sum: 3+4+2 = 9 (not row count 3).
    expect(ExerciseSummarySync.totalSetsFromExercises(exercises), 9);
  });
}
