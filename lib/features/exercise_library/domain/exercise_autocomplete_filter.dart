/// Filters exercise options for autocomplete search fields.
Iterable<T> filterExercisesByQuery<T>({
  required String query,
  required Iterable<T> options,
  required String Function(T item) displayName,
}) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) {
    return options;
  }
  return options.where(
    (item) => displayName(item).toLowerCase().contains(normalized),
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
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return options;
    }

    final generation = ++_generation;
    await Future<void>.delayed(debounceDelay);
    if (!isActive() || generation != _generation) {
      return const [];
    }

    return filterExercisesByQuery(
      query: normalized,
      options: options,
      displayName: displayName,
    );
  }

  void cancel() {
    _generation++;
  }
}
