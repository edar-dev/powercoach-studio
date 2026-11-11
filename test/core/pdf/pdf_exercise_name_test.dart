import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/pdf/pdf_exercise_name.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';

void main() {
  test('resolveExerciseDisplayNameForPdf prefers shortName', () {
    const exercise = Exercise(
      id: 'e1',
      name: 'Seated Cable Row - V Grip (Cable)',
      sets: '1',
      reps: '4x8',
      rpe: '',
      shortName: 'Cable Row (V)',
    );

    expect(resolveExerciseDisplayNameForPdf(exercise), 'Cable Row (V)');
  });

  test('resolveExerciseDisplayNameForPdf sanitizes tofu separators in shortName', () {
    const exercise = Exercise(
      id: 'e2',
      name: 'Good Morning (Barbell)',
      sets: '1',
      reps: '3x6',
      rpe: '',
      shortName: 'Good morning \u22C5 Safety bar',
    );

    expect(
      resolveExerciseDisplayNameForPdf(exercise),
      'Good morning - Safety bar',
    );
  });

  test('abbreviateExerciseNameForPdf strips equipment suffix', () {
    expect(
      abbreviateExerciseNameForPdf('Bench Press (Barbell)'),
      'Bench Press',
    );
    expect(
      abbreviateExerciseNameForPdf('Seated Cable Row - V Grip (Cable)'),
      'Cable Row (V)',
    );
    expect(
      abbreviateExerciseNameForPdf('Seated Overhead Press (Dumbbell)'),
      'OHP DB',
    );
    expect(
      abbreviateExerciseNameForPdf('Chest Press (Machine)'),
      'Chest Press',
    );
  });

  test(
    'resolveExerciseDisplayNameForPdf keeps clear > path for hierarchical names',
    () {
      const exercise = Exercise(
        id: 'e3',
        name: 'Good morning › Safety bar',
        sets: '1',
        reps: '3x6',
        rpe: '',
      );

      expect(
        resolveExerciseDisplayNameForPdf(exercise),
        'Good morning > Safety bar',
      );
      expect(
        abbreviateExerciseNameForPdf('Good morning › Safety bar'),
        'Good morning > Safety bar',
      );
      expect(
        abbreviateExerciseNameForPdf('Good morning › Safety bar (Barbell)'),
        'Good morning > Safety bar',
      );
    },
  );
}
