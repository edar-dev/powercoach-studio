import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/integrations/hevy/domain/hevy_prescription_parser.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';

void main() {
  group('HevyPrescriptionParser', () {
    final parser = HevyPrescriptionParser();

    test('parses 3x8 with load', () {
      final sets = parser.parseExercise(
        const Exercise(
          id: '1',
          name: 'Squat',
          sets: '3',
          reps: '8',
          rpe: '80kg',
        ),
      );
      expect(sets.length, greaterThanOrEqualTo(1));
      expect(sets.first.reps, 8);
      expect(sets.first.weightKg, closeTo(80, 0.01));
    });

    test('parses setDetails line', () {
      final sets = parser.parseExercise(
        Exercise(
          id: '1',
          name: 'Press',
          sets: '1',
          reps: '',
          rpe: '',
          setDetails: const [ExerciseSet(line: '3x5 100kg', sets: '3')],
        ),
      );
      expect(sets.length, 3);
      expect(sets.first.reps, 5);
      expect(sets.first.weightKg, closeTo(100, 0.01));
    });
  });
}
