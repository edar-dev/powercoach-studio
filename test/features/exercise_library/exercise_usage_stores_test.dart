import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/exercise_library/data/pinned_exercises_store.dart';
import 'package:powercoach_studio/features/exercise_library/data/recent_exercises_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('RecentExercisesStore', () {
    test('recordUse dedupes and moves exercise to front', () async {
      final store = RecentExercisesStore.instance;

      await store.recordUse('a');
      await store.recordUse('b');
      await store.recordUse('a');

      expect(await store.getRecentIds(), ['a', 'b']);
    });

    test('recordUse caps recent ids to maxEntries', () async {
      final store = RecentExercisesStore.instance;

      for (var i = 0; i < RecentExercisesStore.maxEntries + 3; i++) {
        await store.recordUse('ex-$i');
      }

      final ids = await store.getRecentIds();
      expect(ids, hasLength(RecentExercisesStore.maxEntries));
      expect(ids.first, 'ex-${RecentExercisesStore.maxEntries + 2}');
    });

    test('removeIds filters deleted exercise ids', () async {
      final store = RecentExercisesStore.instance;
      await store.recordUse('keep');
      await store.recordUse('drop-a');
      await store.recordUse('drop-b');

      await store.removeIds(['drop-a', 'drop-b', 'missing']);

      expect(await store.getRecentIds(), ['keep']);
    });
  });

  group('PinnedExercisesStore', () {
    test('toggle adds and removes pinned exercise id', () async {
      final store = PinnedExercisesStore.instance;

      await store.toggle('ex-1');
      expect(await store.getPinnedIds(), {'ex-1'});

      await store.toggle('ex-1');
      expect(await store.getPinnedIds(), isEmpty);
    });

    test('removeIds filters deleted exercise ids', () async {
      final store = PinnedExercisesStore.instance;
      await store.toggle('keep');
      await store.toggle('drop-a');
      await store.toggle('drop-b');

      await store.removeIds(['drop-a', 'drop-b', 'missing']);

      expect(await store.getPinnedIds(), {'keep'});
    });
  });
}
