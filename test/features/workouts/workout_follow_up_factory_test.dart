import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/workout_follow_up_factory.dart';

void main() {
  test('prepareFollowUpRoutine resets progress and assignment markers', () {
    final source = WorkoutRoutine(
      name: 'Strength block',
      mobilitySections: WorkoutRoutine.empty().mobilitySections,
      mobilityItems: const [],
      weeks: WorkoutRoutine.defaultWeeks(),
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 2, 1),
      currentWeek: 4,
      sessionCompletionByKey: const {'0-0': true},
      sessionSkippedByKey: const {'0-1': true},
    );

    final followUp = prepareFollowUpRoutine(
      source: source,
      newStartDate: DateTime(2026, 3, 15),
    );

    expect(followUp.name, source.name);
    expect(followUp.weeks.length, source.weeks.length);
    expect(followUp.startDate, DateTime(2026, 3, 15));
    expect(followUp.endDate, isNull);
    expect(followUp.currentWeek, 1);
    expect(followUp.sessionCompletionByKey, isEmpty);
    expect(followUp.sessionSkippedByKey, isEmpty);
  });

  test('prepareFollowUpRoutine keeps source start date when not provided', () {
    final source = WorkoutRoutine(
      name: 'Hypertrophy',
      mobilitySections: WorkoutRoutine.empty().mobilitySections,
      mobilityItems: const [],
      weeks: WorkoutRoutine.defaultWeeks(),
      startDate: DateTime(2026, 4, 10),
    );

    final followUp = prepareFollowUpRoutine(source: source);

    expect(followUp.startDate, DateTime(2026, 4, 10));
    expect(followUp.currentWeek, 1);
    expect(followUp.endDate, isNull);
  });
}
