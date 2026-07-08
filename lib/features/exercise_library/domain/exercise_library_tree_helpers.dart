import '../../integrations/hevy/domain/exercise_catalog_source.dart';
import '../data/custom_exercise_item.dart';

List<CustomExerciseItem> flattenExerciseTree(List<CustomExerciseItem> roots) {
  final out = <CustomExerciseItem>[];
  void visit(CustomExerciseItem node) {
    out.add(node);
    for (final c in node.children) {
      visit(c);
    }
  }

  for (final r in roots) {
    visit(r);
  }
  return out;
}

/// Filters the tree so that the tab shows only exercises matching [isMobility].
///
/// If a node doesn't match but some descendants do, we "lift" matching descendants
/// to the current level. This avoids showing the wrong category while keeping
/// the list readable.
List<CustomExerciseItem> filterExerciseRootsByMobility(
  List<CustomExerciseItem> items,
  bool isMobility,
) {
  final out = <CustomExerciseItem>[];
  for (final r in items) {
    out.addAll(filterExerciseNodeByMobility(r, isMobility));
  }
  return out;
}

List<CustomExerciseItem> filterHevyExerciseRoots(List<CustomExerciseItem> items) {
  return items
      .where((root) => root.catalogSource == ExerciseCatalogSource.hevy)
      .toList();
}

List<CustomExerciseItem> filterExerciseNodeByMobility(
  CustomExerciseItem node,
  bool isMobility,
) {
  if (node.catalogSource == ExerciseCatalogSource.hevy) {
    return const [];
  }
  final filteredChildren = <CustomExerciseItem>[];
  for (final c in node.children) {
    filteredChildren.addAll(filterExerciseNodeByMobility(c, isMobility));
  }

  if (node.isMobility == isMobility) {
    return [
      CustomExerciseItem(
        id: node.id,
        name: node.name,
        description: node.description,
        parentId: node.parentId,
        sortOrder: node.sortOrder,
        isMobility: node.isMobility,
        catalogSource: node.catalogSource,
        hevyTemplateId: node.hevyTemplateId,
        hevyStableKey: node.hevyStableKey,
        isHevyFolder: node.isHevyFolder,
        createdAt: node.createdAt,
        updatedAt: node.updatedAt,
        rowVersion: node.rowVersion,
        children: filteredChildren,
      ),
    ];
  }

  return filteredChildren;
}
