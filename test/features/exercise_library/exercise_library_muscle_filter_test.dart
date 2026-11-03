import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/exercise_library/data/custom_exercise_item.dart';
import 'package:powercoach_studio/features/exercise_library/domain/exercise_library_muscle_filter.dart';

CustomExerciseItem _item({
  required String id,
  required String name,
  List<CustomExerciseItem> children = const [],
}) {
  final now = DateTime(2026, 1, 1);
  return CustomExerciseItem(
    id: id,
    name: name,
    createdAt: now,
    updatedAt: now,
    children: children,
  );
}

void main() {
  group('guessMuscleGroupFromName', () {
    test('maps chest keywords', () {
      expect(guessMuscleGroupFromName('Panca piana'), ExerciseLibraryMuscleGroup.chest);
      expect(guessMuscleGroupFromName('Bench Press'), ExerciseLibraryMuscleGroup.chest);
      expect(guessMuscleGroupFromName('Chest Fly'), ExerciseLibraryMuscleGroup.chest);
      expect(guessMuscleGroupFromName('Petto manubri'), ExerciseLibraryMuscleGroup.chest);
    });

    test('maps back keywords including stacco', () {
      expect(guessMuscleGroupFromName('Stacco da terra'), ExerciseLibraryMuscleGroup.back);
      expect(guessMuscleGroupFromName('Trazioni'), ExerciseLibraryMuscleGroup.back);
      expect(guessMuscleGroupFromName('Rematore manubrio'), ExerciseLibraryMuscleGroup.back);
      expect(guessMuscleGroupFromName('Lat Pulldown'), ExerciseLibraryMuscleGroup.back);
      expect(guessMuscleGroupFromName('Deadlift'), ExerciseLibraryMuscleGroup.back);
      expect(guessMuscleGroupFromName('Pull-up'), ExerciseLibraryMuscleGroup.back);
    });

    test('maps legs keywords and prefers squat over bare back', () {
      expect(guessMuscleGroupFromName('Squat'), ExerciseLibraryMuscleGroup.legs);
      expect(guessMuscleGroupFromName('Back Squat'), ExerciseLibraryMuscleGroup.legs);
      expect(guessMuscleGroupFromName('Affondi'), ExerciseLibraryMuscleGroup.legs);
      expect(guessMuscleGroupFromName('Leg Press'), ExerciseLibraryMuscleGroup.legs);
      expect(guessMuscleGroupFromName('Hip Thrust glute'), ExerciseLibraryMuscleGroup.legs);
    });

    test('maps shoulders keywords', () {
      expect(
        guessMuscleGroupFromName('Military Press'),
        ExerciseLibraryMuscleGroup.shoulders,
      );
      expect(
        guessMuscleGroupFromName('Alzate laterali'),
        ExerciseLibraryMuscleGroup.shoulders,
      );
      expect(guessMuscleGroupFromName('Spalle'), ExerciseLibraryMuscleGroup.shoulders);
    });

    test('maps arms keywords', () {
      expect(guessMuscleGroupFromName('Curl bilanciere'), ExerciseLibraryMuscleGroup.arms);
      expect(guessMuscleGroupFromName('Tricipiti pushdown'), ExerciseLibraryMuscleGroup.arms);
      expect(guessMuscleGroupFromName('Bicipiti'), ExerciseLibraryMuscleGroup.arms);
    });

    test('maps core keywords', () {
      expect(guessMuscleGroupFromName('Plank'), ExerciseLibraryMuscleGroup.core);
      expect(guessMuscleGroupFromName('Crunch'), ExerciseLibraryMuscleGroup.core);
      expect(guessMuscleGroupFromName('Addome'), ExerciseLibraryMuscleGroup.core);
    });

    test('returns null when no keyword matches', () {
      expect(guessMuscleGroupFromName('Movimento generico'), isNull);
      expect(guessMuscleGroupFromName(''), isNull);
    });
  });

  group('filterExerciseRootsByMuscle', () {
    test('keeps all roots when filter is all', () {
      final roots = [
        _item(id: '1', name: 'Panca'),
        _item(id: '2', name: 'Squat'),
      ];
      expect(
        filterExerciseRootsByMuscle(roots, ExerciseLibraryMuscleGroup.all),
        same(roots),
      );
    });

    test('keeps root when child name matches muscle', () {
      final roots = [
        _item(
          id: 'family',
          name: 'Press famiglia',
          children: [
            _item(id: 'c1', name: 'Panca inclinata'),
          ],
        ),
        _item(id: 'other', name: 'Squat'),
      ];

      final filtered = filterExerciseRootsByMuscle(
        roots,
        ExerciseLibraryMuscleGroup.chest,
      );
      expect(filtered, hasLength(1));
      expect(filtered.single.id, 'family');
      expect(filtered.single.children, hasLength(1));
    });

    test('keeps root when root name matches', () {
      final roots = [
        _item(id: '1', name: 'Rematore'),
        _item(id: '2', name: 'Curl'),
      ];
      final filtered = filterExerciseRootsByMuscle(
        roots,
        ExerciseLibraryMuscleGroup.back,
      );
      expect(filtered.map((e) => e.id), ['1']);
    });
  });
}
