import '../data/custom_exercise_item.dart';

/// Root-list sort modes for the exercise library screen.
enum ExerciseLibrarySortMode {
  alphabetical,
  variantCount,
}

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

/// Number of top-level folders (roots that have children).
int countExerciseFolders(List<CustomExerciseItem> roots) {
  return roots.where((r) => r.children.isNotEmpty).length;
}

CustomExerciseItem copyExerciseNode(
  CustomExerciseItem node, {
  List<CustomExerciseItem>? children,
}) {
  return CustomExerciseItem(
    id: node.id,
    name: node.name,
    description: node.description,
    parentId: node.parentId,
    sortOrder: node.sortOrder,
    isMobility: node.isMobility,
    catalogSource: node.catalogSource,
    createdAt: node.createdAt,
    updatedAt: node.updatedAt,
    rowVersion: node.rowVersion,
    children: children ?? node.children,
  );
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

List<CustomExerciseItem> filterExerciseNodeByMobility(
  CustomExerciseItem node,
  bool isMobility,
) {
  final filteredChildren = <CustomExerciseItem>[];
  for (final c in node.children) {
    filteredChildren.addAll(filterExerciseNodeByMobility(c, isMobility));
  }

  if (node.isMobility == isMobility) {
    return [copyExerciseNode(node, children: filteredChildren)];
  }

  return filteredChildren;
}

/// Keeps matching leaves and ancestors of matches.
///
/// When a node itself matches, its full child list is preserved so folder-name
/// searches still show all variants. When only descendants match, only the
/// matching subtrees are kept.
List<CustomExerciseItem> filterExerciseTreeByQuery(
  List<CustomExerciseItem> roots,
  String query,
) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return roots;

  CustomExerciseItem? filterNode(CustomExerciseItem node) {
    final selfMatch = node.name.toLowerCase().contains(q) ||
        (node.description?.toLowerCase().contains(q) ?? false);

    final filteredChildren = <CustomExerciseItem>[];
    for (final child in node.children) {
      final filtered = filterNode(child);
      if (filtered != null) filteredChildren.add(filtered);
    }

    if (selfMatch) {
      return copyExerciseNode(node, children: node.children);
    }
    if (filteredChildren.isNotEmpty) {
      return copyExerciseNode(node, children: filteredChildren);
    }
    return null;
  }

  final out = <CustomExerciseItem>[];
  for (final root in roots) {
    final filtered = filterNode(root);
    if (filtered != null) out.add(filtered);
  }
  return out;
}

/// Sorts roots (and nested children) with pinned items first.
List<CustomExerciseItem> sortExerciseTree(
  List<CustomExerciseItem> roots, {
  required ExerciseLibrarySortMode mode,
  required bool Function(CustomExerciseItem item) isPinned,
}) {
  int compare(CustomExerciseItem a, CustomExerciseItem b) {
    final aPinned = isPinned(a);
    final bPinned = isPinned(b);
    if (aPinned != bPinned) return aPinned ? -1 : 1;

    switch (mode) {
      case ExerciseLibrarySortMode.alphabetical:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      case ExerciseLibrarySortMode.variantCount:
        final byCount = b.children.length.compareTo(a.children.length);
        if (byCount != 0) return byCount;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    }
  }

  CustomExerciseItem sortNode(CustomExerciseItem node) {
    final children = node.children.map(sortNode).toList()..sort(compare);
    return copyExerciseNode(node, children: children);
  }

  final sorted = roots.map(sortNode).toList()..sort(compare);
  return sorted;
}
