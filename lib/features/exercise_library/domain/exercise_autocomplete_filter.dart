import 'dart:async';

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
  Timer? _timer;
  void Function()? _settlePending;

  Future<Iterable<T>> optionsFor<T>({
    required String query,
    required Iterable<T> options,
    required String Function(T item) displayName,
    required bool Function() isActive,
  }) {
    final tokens = tokenizeExerciseSearchQuery(query);
    if (tokens.isEmpty) {
      _clearPending(completeEmpty: true);
      return Future<Iterable<T>>.value(options);
    }

    final generation = ++_generation;
    _clearPending(completeEmpty: true);

    final completer = Completer<Iterable<T>>();
    _settlePending = () {
      if (!completer.isCompleted) {
        completer.complete(const []);
      }
    };

    _timer = Timer(debounceDelay, () {
      _timer = null;
      _settlePending = null;
      if (!isActive() || generation != _generation) {
        if (!completer.isCompleted) {
          completer.complete(const []);
        }
        return;
      }
      if (!completer.isCompleted) {
        completer.complete(
          filterExercisesByQuery(
            query: query,
            options: options,
            displayName: displayName,
          ),
        );
      }
    });

    return completer.future;
  }

  void cancel() {
    _generation++;
    _clearPending(completeEmpty: true);
  }

  void _clearPending({required bool completeEmpty}) {
    _timer?.cancel();
    _timer = null;
    final settle = _settlePending;
    _settlePending = null;
    if (completeEmpty) {
      settle?.call();
    }
  }
}
