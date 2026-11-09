import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/exercise_library/domain/exercise_query_match.dart';

void main() {
  group('normalizeExerciseSearchText', () {
    test('folds diacritics and punctuation', () {
      expect(
        normalizeExerciseSearchText('Panca‐piana › presa stretta!'),
        'panca piana presa stretta',
      );
      expect(normalizeExerciseSearchText('Déadlìft'), 'deadlift');
    });
  });

  group('exerciseTextMatchesQuery', () {
    test('token AND matches non-adjacent words (panca stretta)', () {
      const name = 'Panca piana presa stretta';
      expect(exerciseTextMatchesQuery(name, 'panca stretta'), isTrue);
      expect(exerciseTextMatchesQuery(name, 'Panca  Stretta'), isTrue);
    });

    test('requires every token', () {
      const name = 'Panca piana presa stretta';
      expect(exerciseTextMatchesQuery(name, 'panca stretta inclinata'), isFalse);
      expect(exerciseTextMatchesQuery(name, 'squat'), isFalse);
    });

    test('empty query matches everything', () {
      expect(exerciseTextMatchesQuery('Anything', '   '), isTrue);
    });

    test('synonyms help IT/EN and short forms', () {
      expect(exerciseTextMatchesQuery('Bench press', 'panca'), isTrue);
      expect(exerciseTextMatchesQuery('Panca piana', 'bench'), isTrue);
      expect(exerciseTextMatchesQuery('Stacco da terra', 'deadlift'), isTrue);
      expect(
        exerciseTextMatchesQuery('Panca piana presa stretta', 'panca grip'),
        isTrue,
      );
      expect(exerciseTextMatchesQuery('Bench press', 'bp'), isTrue);
    });

    test('accent-insensitive', () {
      expect(exerciseTextMatchesQuery('Déadlìft rumeno', 'deadlift'), isTrue);
      expect(exerciseTextMatchesQuery('Panca piana', 'pànca'), isTrue);
    });
  });

  group('scoreExerciseQueryMatch / filterAndRankByExerciseQuery', () {
    test('prefers prefix and token-order matches', () {
      final ranked = filterAndRankByExerciseQuery<String>(
        query: 'panca stretta',
        options: const [
          'Curl presa stretta panca invertita',
          'Panca piana presa stretta',
          'Curl manubri',
        ],
        searchableText: (v) => v,
      ).toList();

      // Both match token AND; prefix on leading "panca" ranks first.
      expect(ranked, [
        'Panca piana presa stretta',
        'Curl presa stretta panca invertita',
      ]);
    });

    test('returns empty when nothing matches', () {
      expect(
        filterAndRankByExerciseQuery<String>(
          query: 'xyz',
          options: const ['Squat'],
          searchableText: (v) => v,
        ),
        isEmpty,
      );
    });
  });
}
