import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/workouts/data/workout_draft_store.dart';
import 'package:powercoach_studio/features/workouts/data/workout_routine_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SharedPrefsWorkoutDraftStore', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('loads empty routine when no draft exists', () async {
      final store = const SharedPrefsWorkoutDraftStore();

      final routine = await store.load();

      expect(routine.name, WorkoutRoutine.empty().name);
      expect(routine.weeks, isEmpty);
    });

    test('saves and loads routine draft', () async {
      final store = const SharedPrefsWorkoutDraftStore();
      final routine = WorkoutRoutine.empty().copyWith(name: 'Draft A');

      await store.save(routine);
      final restored = await store.load();

      expect(restored.name, 'Draft A');
    });

    test('falls back to empty routine for malformed draft', () async {
      SharedPreferences.setMockInitialValues({
        workoutRoutineDraftPrefsKey: '{bad-json',
      });
      final store = const SharedPrefsWorkoutDraftStore();

      final restored = await store.load();

      expect(restored.name, WorkoutRoutine.empty().name);
    });
  });
}
