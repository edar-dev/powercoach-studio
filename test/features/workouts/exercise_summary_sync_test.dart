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
}
