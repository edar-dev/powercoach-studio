import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/pdf/pdf_dense_day_rows.dart';
import 'package:powercoach_studio/core/pdf/pdf_programming_rows.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/exercise_prescription_scope.dart';

void main() {
  test('buildDenseDayRows aligns exercises by customExerciseId across weeks', () {
    final weeks = [
      Week(
        id: 'w1',
        name: 'S1',
        days: [
          Day(
            id: 'd1',
            name: 'Day 1',
            exercises: [
              const Exercise(
                id: 'e1',
                name: 'Squat',
                sets: '1',
                reps: '4x3',
                rpe: '100',
                customExerciseId: 'cex_squat',
              ),
            ],
          ),
        ],
      ),
      Week(
        id: 'w2',
        name: 'S2',
        days: [
          Day(
            id: 'd2',
            name: 'Day 1',
            exercises: [
              const Exercise(
                id: 'e2',
                name: 'Squat (Barbell)',
                sets: '1',
                reps: '5x3',
                rpe: '100',
                customExerciseId: 'cex_squat',
              ),
            ],
          ),
        ],
      ),
    ];

    final rows = buildDenseDayRows(weeks: weeks, dayIndex: 0);
    expect(rows.length, 1);
    expect(rows.first.weekBlocks.every((block) => block != null), isTrue);
  });

  test('denseShouldMergeWeekCells honors explicit allWeeks scope', () {
    const exercise = Exercise(
      id: 'e1',
      name: 'Leg Press',
      sets: '1',
      reps: '3x8',
      rpe: '',
      prescriptionScope: ExercisePrescriptionScope.allWeeks,
    );
    const content = PdfDenseCellContent(prescription: '3x8', note: '');

    expect(
      denseShouldMergeWeekCells(
        labelBlock: exercise,
        weekContents: [content, null, null, null],
      ),
      isTrue,
    );
  });
}
