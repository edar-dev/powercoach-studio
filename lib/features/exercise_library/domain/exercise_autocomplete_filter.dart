import 'exercise_query_match.dart';

/// Filters exercise options for autocomplete search fields.
///
/// Uses shared token-AND matching with light relevance ranking so multi-word
/// queries like `panca stretta` hit names such as `Panca piana presa stretta`.
Iterable<T> filterExercisesByQuery<T>({
  required String query,
  required Iterable<T> options,
  required String Function(T item) displayName,
}) {
  return filterAndRankByExerciseQuery<T>(
    query: query,
    options: options,
    searchableText: displayName,
  );
}

/// Debounces autocomplete queries to avoid filtering large lists on every keystroke.
class DebouncedExerciseAutocompleteFilter {
  DebouncedExerciseAutocompleteFilter({
    this.debounceDelay = const Duration(milliseconds: 200),
  });

  final Duration debounceDelay;
  int _generation = 0;

  Future<Iterable<T>> optionsFor<T>({
    required String query,
    required Iterable<T> options,
    required String Function(T item) displayName,
    required bool Function() isActive,
  }) async {
    final tokens = tokenizeExerciseSearchQuery(query);
    if (tokens.isEmpty) {
      return options;
    }

    final generation = ++_generation;
    await Future<void>.delayed(debounceDelay);
    if (!isActive() || generation != _generation) {
      return const [];
    }

    return filterExercisesByQuery(
      query: query,
      options: options,
      displayName: displayName,
    );
  }

  void cancel() {
    _generation++;
  }
}
