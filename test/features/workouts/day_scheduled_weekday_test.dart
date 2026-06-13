import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:powercoach_studio/features/workouts/domain/day_scheduled_weekday.dart';

void main() {
  group('day_scheduled_weekday', () {
    test('effectiveScheduledWeekday falls back to day index', () {
      const day = Day(id: 'd1', name: 'Slot A', exercises: []);
      expect(
        effectiveScheduledWeekday(day: day, dayIndex: 0),
        DateTime.monday,
      );
      expect(
        effectiveScheduledWeekday(day: day, dayIndex: 3),
        DateTime.thursday,
      );
    });

    test('hydrateScheduledWeekdays fills missing weekdays', () {
      final routine = WorkoutRoutine.empty().copyWith(
        weeks: [
          Week(
            id: 'w1',
            name: 'S1',
            days: const [
              Day(id: 'd1', name: 'A', exercises: []),
              Day(id: 'd2', name: 'B', exercises: [], scheduledWeekday: 5),
            ],
          ),
        ],
      );
      final hydrated = hydrateScheduledWeekdays(routine);
      expect(hydrated.weeks.first.days[0].scheduledWeekday, DateTime.monday);
      expect(hydrated.weeks.first.days[1].scheduledWeekday, DateTime.friday);
    });
  });
}
