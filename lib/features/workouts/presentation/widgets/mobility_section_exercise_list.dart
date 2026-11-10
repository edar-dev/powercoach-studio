import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import 'workout_day_exercise_list.dart';
import 'workout_mobility_tab_widgets.dart';

/// Scrollable mobility item list with single expand-in-place editing.
///
/// Mirrors [WorkoutDayExerciseList]: parent owns `_expandedItemId`, newly
/// added items auto-expand, and the first item expands on open when non-empty.
class MobilitySectionExerciseList extends StatefulWidget {
  const MobilitySectionExerciseList({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.items,
    required this.onUpdateItem,
    required this.onDeleteItem,
    required this.onReorderItems,
    this.onAddItem,
    this.pinBottomCtas = false,
    this.expandFirstOnOpen = true,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final List<MobilityItem> items;
  final void Function(
    String itemId,
    String title,
    String subtitle,
    String shortTitle,
  ) onUpdateItem;
  final void Function(String itemId) onDeleteItem;
  final void Function(int oldIndex, int newIndex) onReorderItems;
  final VoidCallback? onAddItem;

  /// When true, omit trailing CTAs from the scroll view so a sticky footer
  /// can own them. Empty-state CTAs stay in the empty body.
  final bool pinBottomCtas;

  /// When true and [items] is non-empty on first build, expand the first item.
  final bool expandFirstOnOpen;

  @override
  State<MobilitySectionExerciseList> createState() =>
      _MobilitySectionExerciseListState();
}

class _MobilitySectionExerciseListState
    extends State<MobilitySectionExerciseList> {
  String? _expandedItemId;

  @override
  void initState() {
    super.initState();
    if (widget.expandFirstOnOpen && widget.items.isNotEmpty) {
      _expandedItemId = widget.items.first.id;
    }
  }

  @override
  void didUpdateWidget(covariant MobilitySectionExerciseList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIds = {for (final e in oldWidget.items) e.id};
    final added = widget.items
        .where((e) => !oldIds.contains(e.id))
        .toList(growable: false);
    if (added.isEmpty) return;
    // Append is the common path; when several appear at once, expand the last.
    _expandedItemId = added.last.id;
  }

  void _setExpanded(String? id) {
    setState(() => _expandedItemId = id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final colorScheme = widget.colorScheme;
    final items = widget.items;
    final l10n = AppLocalizations.of(context);
    final showTrailingCta =
        items.isNotEmpty && widget.onAddItem != null && !widget.pinBottomCtas;

    if (items.isEmpty) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.self_improvement_outlined,
                size: 40,
                color: colorScheme.onSurface.withValues(alpha: 0.72),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.workoutBuilderMobilityEmptyTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.workoutBuilderMobilityEmptyMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
              if (widget.onAddItem != null) ...[
                const SizedBox(height: 20),
                SessionDayBottomCtas(
                  l10n: l10n,
                  onAddFromLibrary: widget.onAddItem,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            buildDefaultDragHandles: false,
            // ignore: deprecated_member_use
            onReorder: widget.onReorderItems,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return MobilityItemCard(
                key: ValueKey(item.id),
                theme: theme,
                colorScheme: colorScheme,
                index: index,
                title: item.title,
                subtitle: item.subtitle,
                shortTitle: item.shortTitle,
                expanded: _expandedItemId == item.id,
                onExpandedChanged: (value) {
                  _setExpanded(value ? item.id : null);
                },
                onUpdate: (t, s, short) =>
                    widget.onUpdateItem(item.id, t, s, short),
                onDelete: () => widget.onDeleteItem(item.id),
              );
            },
          ),
        ),
        if (showTrailingCta)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SessionDayBottomCtas(
              l10n: l10n,
              onAddFromLibrary: widget.onAddItem,
            ),
          ),
      ],
    );
  }
}
