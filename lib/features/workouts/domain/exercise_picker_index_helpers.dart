import '../../exercise_library/data/custom_exercise_item.dart';
import '../../exercise_library/domain/exercise_catalog_source.dart';

class ExercisePickerIndex {
  const ExercisePickerIndex({
    required this.flat,
    required this.depthById,
    required this.parentNameById,
  });

  final List<CustomExerciseItem> flat;
  final Map<String, int> depthById;
  final Map<String, String> parentNameById;
}

ExercisePickerIndex buildExercisePickerIndex(List<CustomExerciseItem> roots) {
  final flat = <CustomExerciseItem>[];
  final depthById = <String, int>{};
  final parentNameById = <String, String>{};

  void visit(CustomExerciseItem node, int depth, String? parentName) {
    flat.add(node);
    depthById[node.id] = depth;
    if (parentName != null) parentNameById[node.id] = parentName;
    for (final c in node.children) {
      visit(c, depth + 1, node.name);
    }
  }

  for (final root in roots) {
    visit(root, 0, null);
  }

  final dedupedFlat = dedupeExercisePickerFlat(
    flat,
    parentNameById: parentNameById,
  );
  final keptIds = {for (final item in dedupedFlat) item.id};

  return ExercisePickerIndex(
    flat: dedupedFlat,
    depthById: {
      for (final entry in depthById.entries)
        if (keptIds.contains(entry.key)) entry.key: entry.value,
    },
    parentNameById: {
      for (final entry in parentNameById.entries)
        if (keptIds.contains(entry.key)) entry.key: entry.value,
    },
  );
}

/// Deduplicates picker options before display.
///
/// 1. Unique by [CustomExerciseItem.id] (keep first).
/// 2. For [ExerciseCatalogSource.powercoach] rows only, unique by picker
///    display path (`Parent › Variant` / root name), keeping the oldest
///    [CustomExerciseItem.createdAt] then stable id order.
/// 3. Non-powercoach rows with colliding labels are left alone.
List<CustomExerciseItem> dedupeExercisePickerFlat(
  List<CustomExerciseItem> flat, {
  required Map<String, String> parentNameById,
}) {
  final uniqueById = <CustomExerciseItem>[];
  final seenIds = <String>{};
  for (final item in flat) {
    if (!seenIds.add(item.id)) continue;
    uniqueById.add(item);
  }

  final bestPowercoachByLabel = <String, CustomExerciseItem>{};
  for (final item in uniqueById) {
    if (item.catalogSource != ExerciseCatalogSource.powercoach) continue;
    final label = exercisePickerDisplayName(item, parentNameById);
    final existing = bestPowercoachByLabel[label];
    if (existing == null || _preferPickerDedupeCandidate(item, existing)) {
      bestPowercoachByLabel[label] = item;
    }
  }

  final keptPowercoachIds = bestPowercoachByLabel.values.map((e) => e.id).toSet();
  return [
    for (final item in uniqueById)
      if (item.catalogSource != ExerciseCatalogSource.powercoach ||
          keptPowercoachIds.contains(item.id))
        item,
  ];
}

/// Prefer older [createdAt], then lexicographically smaller [id].
bool _preferPickerDedupeCandidate(
  CustomExerciseItem candidate,
  CustomExerciseItem incumbent,
) {
  final createdCmp = candidate.createdAt.compareTo(incumbent.createdAt);
  if (createdCmp != 0) return createdCmp < 0;
  return candidate.id.compareTo(incumbent.id) < 0;
}

String exercisePickerDisplayName(
  CustomExerciseItem exercise,
  Map<String, String> parentNameById,
) {
  final parentName = parentNameById[exercise.id];
  return parentName != null ? '$parentName › ${exercise.name}' : exercise.name;
}

List<CustomExerciseItem> sortExercisePickerOptions({
  required List<CustomExerciseItem> flat,
  required Set<String> pinnedIds,
  required List<String> recentIds,
  required String Function(CustomExerciseItem exercise) displayName,
}) {
  return List<CustomExerciseItem>.from(flat)
    ..sort((a, b) {
      final aPinned = pinnedIds.contains(a.id);
      final bPinned = pinnedIds.contains(b.id);
      if (aPinned != bPinned) return aPinned ? -1 : 1;
      final ai = recentIds.indexOf(a.id);
      final bi = recentIds.indexOf(b.id);
      if (ai >= 0 || bi >= 0) {
        if (ai < 0) return 1;
        if (bi < 0) return -1;
        return ai.compareTo(bi);
      }
      return displayName(
        a,
      ).toLowerCase().compareTo(displayName(b).toLowerCase());
    });
}
