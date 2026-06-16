import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/exercise_library/data/recent_exercises_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('recordUse keeps most recent first and unique', () async {
    final store = RecentExercisesStore.instance;
    await store.recordUse('a');
    await store.recordUse('b');
    await store.recordUse('a');
    final ids = await store.getRecentIds();
    expect(ids, ['a', 'b']);
  });
}

