import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/exercise_library/data/default_exercise_catalog.dart';

void main() {
  test('default catalog includes powerlifting competition lifts and variants', () {
    final items = buildDefaultExerciseCatalogJson();
    expect(items, isNotEmpty);
    expect(defaultExerciseCatalogNodeCount(), items.length);

    final rootNames = items
        .where((e) => e['parentId'] == null)
        .map((e) => e['name'] as String)
        .toSet();

    expect(rootNames, contains('Panca piana'));
    expect(rootNames, contains('Good morning'));
    expect(rootNames, contains('Stacco da terra'));
    expect(rootNames, contains('Squat con bilanciere'));
    expect(rootNames, contains('Safety bar squat (SSB)'));
    expect(rootNames, contains('Floor press'));
    expect(rootNames, contains('Trap bar deadlift'));

    String? rootIdFor(String name) {
      for (final e in items) {
        if (e['parentId'] == null && e['name'] == name) {
          return e['id'] as String;
        }
      }
      return null;
    }

    final benchRoot = rootIdFor('Panca piana')!;
    final benchVariants = items
        .where((e) => e['parentId'] == benchRoot)
        .map((e) => e['name'] as String)
        .toSet();
    expect(benchVariants, containsAll(['Spoto press', 'Pin press', 'Board press', 'Floor press', 'Presa stretta']));

    final gmRoot = rootIdFor('Good morning')!;
    final gmVariants = items
        .where((e) => e['parentId'] == gmRoot)
        .map((e) => e['name'] as String)
        .toSet();
    expect(gmVariants, contains('Bilanciere in piedi'));
  });
}
