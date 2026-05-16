import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/integrations/hevy/data/hevy_api_models.dart';
import 'package:powercoach_studio/features/integrations/hevy/domain/hevy_catalog_hierarchy_builder.dart';

void main() {
  group('HevyCatalogHierarchyBuilder', () {
    test('groups by muscle and family when titles share base', () {
      final nodes = HevyCatalogHierarchyBuilder().build([
        const HevyExerciseTemplateDto(
          id: 'A1',
          title: 'Bench Press (Barbell)',
          primaryMuscleGroup: 'chest',
        ),
        const HevyExerciseTemplateDto(
          id: 'A2',
          title: 'Bench Press (Dumbbell)',
          primaryMuscleGroup: 'chest',
        ),
        const HevyExerciseTemplateDto(
          id: 'B1',
          title: 'Cable Fly',
          primaryMuscleGroup: 'chest',
        ),
      ]);

      expect(nodes.any((n) => n.stableKey == 'hevy_grp_chest' && n.isFolder), isTrue);
      expect(
        nodes.any((n) => n.stableKey.contains('hevy_fam') && n.name == 'Bench Press'),
        isTrue,
      );
      final leaves = nodes.where((n) => !n.isFolder).toList();
      expect(leaves.length, 3);
      expect(leaves.every((n) => n.hevyTemplateId != null), isTrue);
    });

    test('single exercise stays direct child of muscle group', () {
      final nodes = HevyCatalogHierarchyBuilder().build([
        const HevyExerciseTemplateDto(
          id: 'X1',
          title: 'Plank',
          primaryMuscleGroup: 'abs',
        ),
      ]);

      final plank = nodes.firstWhere((n) => n.hevyTemplateId == 'X1');
      expect(plank.parentStableKey, 'hevy_grp_abs');
    });
  });
}
