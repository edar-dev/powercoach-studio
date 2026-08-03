import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';

void main() {
  test('effectiveSetDetails legacy fallback includes exercise sets', () {
    const exercise = Exercise(
      id: 'e1',
      name: 'Good Morning',
      sets: '3',
      reps: '10',
      rpe: '',
    );

    final details = exercise.effectiveSetDetails;
    expect(details, hasLength(1));
    expect(details.single.sets, '3');
    expect(details.single.reps, '10');
    expect(details.single.displayText, '3x10');
  });

  test('displayText stays empty when prescription fields are blank', () {
    const set = ExerciseSet(sets: '', reps: '', rpe: '');
    expect(set.displayText, isEmpty);
  });
}
