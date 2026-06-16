import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/exercise_library/data/pinned_exercises_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('toggle adds then removes pin', () async {
    final store = PinnedExercisesStore.instance;
    await store.toggle('x');
    expect(await store.getPinnedIds(), {'x'});
    await store.toggle('x');
    expect(await store.getPinnedIds(), isEmpty);
  });
}

