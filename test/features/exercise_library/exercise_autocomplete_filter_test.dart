import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/exercise_library/domain/exercise_autocomplete_filter.dart';

void main() {
  group('filterExercisesByQuery', () {
    final options = ['Bench Press', 'Squat', 'Deadlift'];

    test('returns all options when query is empty', () {
      expect(
        filterExercisesByQuery<String>(
          query: '   ',
          options: options,
          displayName: (v) => v,
        ),
        options,
      );
    });

    test('filters case-insensitively', () {
      final result = filterExercisesByQuery<String>(
        query: 'bench',
        options: options,
        displayName: (v) => v,
      );
      expect(result, ['Bench Press']);
    });
  });

  group('DebouncedExerciseAutocompleteFilter', () {
    test('waits before returning filtered options', () async {
      final filter = DebouncedExerciseAutocompleteFilter(
        debounceDelay: const Duration(milliseconds: 100),
      );
      var active = true;

      final pending = filter.optionsFor<String>(
        query: 'sq',
        options: const ['Squat', 'Bench'],
        displayName: (v) => v,
        isActive: () => active,
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      final result = await pending;

      expect(result, ['Squat']);
      filter.cancel();
      active = false;
    });

    test('drops stale results after cancel', () async {
      final filter = DebouncedExerciseAutocompleteFilter(
        debounceDelay: const Duration(milliseconds: 80),
      );

      final first = filter.optionsFor<String>(
        query: 'sq',
        options: const ['Squat'],
        displayName: (v) => v,
        isActive: () => true,
      );
      filter.cancel();
      final second = filter.optionsFor<String>(
        query: 'be',
        options: const ['Bench Press'],
        displayName: (v) => v,
        isActive: () => true,
      );

      expect(await first, isEmpty);
      expect(await second, ['Bench Press']);
    });
  });
}
