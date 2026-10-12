import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_training_superset_helpers.dart';
import 'package:powercoach_studio/features/workouts/presentation/widgets/workout_training_week_expansion.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';

void main() {
  group('nextExpandedWeeksAfterToggle', () {
    test('collapse removes only the toggled week', () {
      expect(
        nextExpandedWeeksAfterToggle(
          current: {0, 2, 4},
          globalWeek: 2,
          currentlyExpanded: true,
          singleExpand: true,
        ),
        {0, 4},
      );
    });

    test('desktop expand collapses siblings (singleExpand)', () {
      expect(
        nextExpandedWeeksAfterToggle(
          current: {0, 1},
          globalWeek: 3,
          currentlyExpanded: false,
          singleExpand: true,
        ),
        {3},
      );
    });

    test('mobile expand keeps other weeks (multiExpand)', () {
      expect(
        nextExpandedWeeksAfterToggle(
          current: {0, 1},
          globalWeek: 3,
          currentlyExpanded: false,
          singleExpand: false,
        ),
        {0, 1, 3},
      );
    });
  });

  group('nextExpandedWeeksAfterSelect', () {
    test('desktop select replaces expanded set', () {
      expect(
        nextExpandedWeeksAfterSelect(
          current: {0, 2},
          globalWeek: 5,
          singleExpand: true,
        ),
        {5},
      );
    });

    test('mobile select adds without collapsing', () {
      expect(
        nextExpandedWeeksAfterSelect(
          current: {0, 2},
          globalWeek: 5,
          singleExpand: false,
        ),
        {0, 2, 5},
      );
    });
  });

  group('getSupersetGroupOptions', () {
    test('builds unique group options once for a dense day', () {
      final day = Day(
        id: 'd1',
        name: 'Day',
        exercises: [
          const Exercise(
            id: 'e1',
            name: 'A',
            sets: '3',
            reps: '8',
            rpe: '',
            supersetGroupId: 'ss1',
          ),
          const Exercise(
            id: 'e2',
            name: 'B',
            sets: '3',
            reps: '8',
            rpe: '',
            supersetGroupId: 'ss1',
          ),
          const Exercise(
            id: 'e3',
            name: 'C',
            sets: '3',
            reps: '10',
            rpe: '',
            supersetGroupId: 'ss2',
          ),
          const Exercise(
            id: 'e4',
            name: 'D',
            sets: '3',
            reps: '10',
            rpe: '',
          ),
          for (var i = 5; i <= 20; i++)
            Exercise(
              id: 'e$i',
              name: 'Ex $i',
              sets: '3',
              reps: '8',
              rpe: '',
            ),
        ],
      );

      final options = getSupersetGroupOptions(day);
      expect(options.length, 2);
      expect(options.map((o) => o.id).toSet(), {'ss1', 'ss2'});
      expect(options.firstWhere((o) => o.id == 'ss1').label, 'A + B');

      // Per-card filter (same path WorkoutDayExerciseList now uses).
      final forSs1Member =
          options.where((o) => o.id != 'ss1').toList(growable: false);
      expect(forSs1Member.map((o) => o.id), ['ss2']);
    });
  });
}
