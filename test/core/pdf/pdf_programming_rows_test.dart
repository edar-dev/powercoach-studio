import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/pdf/pdf_programming_rows.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_routine_json_codec.dart';

void main() {
  test('bench press pyramid collapses to one compact multiline row', () {
    final exercise = Exercise(
      id: 'e1',
      name: 'Bench Press (Barbell)',
      sets: '7',
      reps: '1x5 77.5 | 1x4 82.5',
      rpe: '',
      note: 'Fermo 1-2"',
      setDetails: const [
        ExerciseSet(reps: '5', rpe: '77.5'),
        ExerciseSet(reps: '4', rpe: '82.5'),
        ExerciseSet(reps: '3', rpe: '85'),
        ExerciseSet(reps: '2', rpe: '87.5'),
        ExerciseSet(reps: '3', rpe: '85'),
        ExerciseSet(reps: '4', rpe: '82.5'),
        ExerciseSet(reps: '5', rpe: '77.5'),
      ],
    );

    final rows = buildProgrammingSetRows(exercise);
    expect(rows.length, 1);
    expect(rows.first.isGrouped, isTrue);
    expect(rows.first.isMultiline, isTrue);
    expect(rows.first.exercise, 'Bench Press (Barbell)');
    expect(rows.first.sets, '1\n2\n3\n4\n5\n6\n7');
    expect(rows.first.reps, '5\n4\n3\n2\n3\n4\n5');
    expect(rows.first.load, '77.5\n82.5\n85\n87.5\n85\n82.5\n77.5');
    expect(rows.first.notes, 'Fermo 1-2"');
  });

  test('dense bench press pyramid uses single-line prescription', () {
    final exercise = Exercise(
      id: 'e1',
      name: 'Bench Press (Barbell)',
      sets: '7',
      reps: '1x5 77.5 | 1x4 82.5',
      rpe: '',
      note: 'Fermo 1-2"',
      setDetails: const [
        ExerciseSet(reps: '5', rpe: '77.5'),
        ExerciseSet(reps: '4', rpe: '82.5'),
        ExerciseSet(reps: '3', rpe: '85'),
      ],
    );

    final rows = buildProgrammingSetRows(exercise, dense: true);
    expect(rows.length, 1);
    expect(rows.first.prescriptionOnly, isTrue);
    expect(rows.first.reps, '1x5 77.5 · 1x4 82.5 · 1x3 85');
    expect(rows.first.notes, 'Fermo 1-2"');
    expect(rows.first.isMultiline, isFalse);
  });

  test('single structured set uses sets x reps x load columns', () {
    final exercise = Exercise(
      id: 'e2',
      name: 'Squat (Barbell)',
      sets: '1',
      reps: '4x3 102.5',
      rpe: '',
      note: 'Low Bar',
      setDetails: const [ExerciseSet(sets: '4', reps: '3', rpe: '102.5')],
    );

    final rows = buildProgrammingSetRows(exercise);
    expect(rows.length, 1);
    expect(rows.first.isGrouped, isFalse);
    expect(rows.first.sets, '4');
    expect(rows.first.reps, '3');
    expect(rows.first.load, '102.5');
    expect(rows.first.notes, 'Low Bar');
  });

  test('dense single structured set collapses prescription column', () {
    final exercise = Exercise(
      id: 'e2',
      name: 'Squat (Barbell)',
      sets: '1',
      reps: '4x3 102.5',
      rpe: '',
      note: 'Low Bar',
      setDetails: const [ExerciseSet(sets: '4', reps: '3', rpe: '102.5')],
    );

    final rows = buildProgrammingSetRows(exercise, dense: true);
    expect(rows.length, 1);
    expect(rows.first.prescriptionOnly, isTrue);
    expect(rows.first.reps, '4x3 102.5');
    expect(rows.first.notes, 'Low Bar');
  });

  test('imported intensificazione json bench press rows are readable', () {
    const jsonText = '''
{
  "schemaVersion": 1,
  "format": "powercoach-workout-routine",
  "routine": {
    "name": "Intensificazione e Volume",
    "mobilitySections": [],
    "mobilityItems": [],
    "weeks": [{
      "id": "w1",
      "name": "SETTIMANA 1",
      "days": [{
        "id": "d1",
        "name": "GIORNO 1",
        "exercises": [{
          "id": "e1",
          "name": "Bench Press (Barbell)",
          "sets": "7",
          "reps": "1x5 77.5",
          "rpe": "",
          "note": "Fermo 1-2\\"",
          "setDetails": [
            {"reps": "5", "rpe": "77.5"},
            {"reps": "4", "rpe": "82.5"}
          ]
        }]
      }]
    }]
  }
}
''';
    final routine = decodeWorkoutRoutineJson(jsonText);
    final bench = routine.weeks.first.days.first.exercises.first;
    final rows = buildProgrammingSetRows(bench);

    expect(rows.length, 1);
    expect(rows.first.load, '77.5\n82.5');
    expect(rows.first.reps, '5\n4');
  });
}
