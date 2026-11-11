import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/exercise_set_patch.dart';

void main() {
  group('exercise_set_patch', () {
    test('patchExerciseSet applies structured sets/reps/rpe', () {
      const cur = ExerciseSet(sets: '1', reps: '', rpe: '');
      final patched = patchExerciseSet(
        cur,
        sets: '3',
        reps: '30s',
        rpe: '8',
        note: 'slow',
      );
      expect(patched.line, isEmpty);
      expect(patched.sets, '3');
      expect(patched.reps, '30s');
      expect(patched.rpe, '8');
      expect(patched.note, 'slow');
    });

    test('patchExerciseSet prefers free-form line when non-empty', () {
      const cur = ExerciseSet(sets: '3', reps: '10', rpe: '7');
      final patched = patchExerciseSet(cur, line: ' 3x30s @8 ');
      expect(patched.line, '3x30s @8');
      expect(patched.sets, '1');
      expect(patched.reps, isEmpty);
      expect(patched.rpe, isEmpty);
    });

    test('patchExerciseSetAt returns null when index is out of range', () {
      expect(
        patchExerciseSetAt(const [ExerciseSet()], 1, reps: '10'),
        isNull,
      );
    });

    test('exerciseSetDetailsAreMeaningful ignores empty seed rows', () {
      expect(exerciseSetDetailsAreMeaningful(null), isFalse);
      expect(exerciseSetDetailsAreMeaningful(const []), isFalse);
      expect(
        exerciseSetDetailsAreMeaningful(const [ExerciseSet()]),
        isFalse,
      );
      expect(
        exerciseSetDetailsAreMeaningful(const [
          ExerciseSet(sets: '3', reps: '30s'),
        ]),
        isTrue,
      );
    });
  });
}
