import 'package:flutter/material.dart';

import '../../../exercise_library/data/custom_exercise_item.dart';

/// Dense expandable tree for the exercise pick panel.
///
/// Title/row tap selects; chevron expands/collapses when the node has children.
/// Leaf/node [CustomExerciseItem.name] only — callers keep path display names
/// for [onPick] via their own parent-name map.
class ExercisePickerTreeList extends StatefulWidget {
  const ExercisePickerTreeList({
    super.key,
    required this.roots,
    required this.pinnedIds,
    required this.onPick,
    this.forceExpandAll = false,
    this.expandedIds,
  });

  final List<CustomExerciseItem> roots;
  final Set<String> pinnedIds;
  final ValueChanged<CustomExerciseItem> onPick;

  /// When true, every non-leaf starts (and stays) expanded.
  final bool forceExpandAll;

  /// Explicit expand set (e.g. search results). Ignored when [forceExpandAll].
  final Set<String>? expandedIds;

  @override
  State<ExercisePickerTreeList> createState() => _ExercisePickerTreeListState();
}

class _ExercisePickerTreeListState extends State<ExercisePickerTreeList> {
  late Set<String> _expandedIds;

  @override
  void initState() {
    super.initState();
    _expandedIds = _resolveExpandedIds();
  }

  @override
  void didUpdateWidget(covariant ExercisePickerTreeList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final searchModeChanged =
        oldWidget.forceExpandAll != widget.forceExpandAll ||
        oldWidget.expandedIds != widget.expandedIds;
    final rootsChanged = !identical(oldWidget.roots, widget.roots);
    if (searchModeChanged || (widget.forceExpandAll && rootsChanged)) {
      _expandedIds = _resolveExpandedIds();
    } else if (widget.expandedIds != null && rootsChanged) {
      _expandedIds = _resolveExpandedIds();
    }
  }

  Set<String> _resolveExpandedIds() {
    if (widget.forceExpandAll) {
      return _collectParentIds(widget.roots);
    }
    if (widget.expandedIds != null) {
      return Set<String>.from(widget.expandedIds!);
    }
    return <String>{};
  }

  static Set<String> _collectParentIds(List<CustomExerciseItem> roots) {
    final ids = <String>{};
    void visit(CustomExerciseItem node) {
      if (node.children.isEmpty) return;
      ids.add(node.id);
      for (final child in node.children) {
        visit(child);
      }
    }

    for (final root in roots) {
      visit(root);
    }
    return ids;
  }

  void _toggle(String id) {
    if (widget.forceExpandAll) return;
    setState(() {
      if (!_expandedIds.add(id)) {
        _expandedIds.remove(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.roots.length,
      itemBuilder: (context, index) {
        return _ExercisePickerTreeNode(
          item: widget.roots[index],
          depth: 0,
          pinnedIds: widget.pinnedIds,
          expandedIds: _expandedIds,
          forceExpandAll: widget.forceExpandAll,
          onToggle: _toggle,
          onPick: widget.onPick,
        );
      },
    );
  }
}

class _ExercisePickerTreeNode extends StatelessWidget {
  const _ExercisePickerTreeNode({
    required this.item,
    required this.depth,
    required this.pinnedIds,
    required this.expandedIds,
    required this.forceExpandAll,
    required this.onToggle,
    required this.onPick,
  });

  final CustomExerciseItem item;
  final int depth;
  final Set<String> pinnedIds;
  final Set<String> expandedIds;
  final bool forceExpandAll;
  final ValueChanged<String> onToggle;
  final ValueChanged<CustomExerciseItem> onPick;

  static const double _indentPerLevel = 24;
  static const double _minRowHeight = 48;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasChildren = item.children.isNotEmpty;
    final expanded = forceExpandAll || expandedIds.contains(item.id);
    final pinned = pinnedIds.contains(item.id);
    final indent = depth * _indentPerLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minRowHeight),
          child: Padding(
            padding: EdgeInsets.only(left: indent, right: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasChildren)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    tooltip: expanded
                        ? MaterialLocalizations.of(context).expandedIconTapHint
                        : MaterialLocalizations.of(context).collapsedIconTapHint,
                    onPressed:
                        forceExpandAll ? null : () => onToggle(item.id),
                    icon: Icon(
                      expanded ? Icons.expand_more : Icons.chevron_right,
                      color: cs.onSurfaceVariant,
                    ),
                  )
                else
                  const SizedBox(width: 48, height: 48),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onPick(item),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  item.name,
                                  style: theme.textTheme.bodyLarge,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if (pinned)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(
                                  Icons.push_pin,
                                  size: 18,
                                  color: cs.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasChildren && expanded)
          for (final child in item.children)
            _ExercisePickerTreeNode(
              item: child,
              depth: depth + 1,
              pinnedIds: pinnedIds,
              expandedIds: expandedIds,
              forceExpandAll: forceExpandAll,
              onToggle: onToggle,
              onPick: onPick,
            ),
      ],
    );
  }
}
