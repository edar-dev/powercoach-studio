import '../../exercise_library/data/custom_exercise_item.dart';

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

  return ExercisePickerIndex(
    flat: flat,
    depthById: depthById,
    parentNameById: parentNameById,
  );
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
