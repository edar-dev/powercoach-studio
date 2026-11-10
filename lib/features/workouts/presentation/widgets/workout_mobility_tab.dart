import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import 'workout_dashed_button.dart';
import 'workout_mobility_tab_widgets.dart';

class WorkoutMobilityTab extends StatelessWidget {
  const WorkoutMobilityTab({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.sections,
    required this.selectedSectionIndex,
    required this.itemsForSelectedSection,
    required this.onAddItem,
    required this.onAddSection,
    required this.onEditSection,
    required this.onDeleteSection,
    required this.onSelectSection,
    required this.onReorderItems,
    required this.onUpdateItem,
    required this.onDeleteItem,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final List<MobilitySection> sections;
  final int selectedSectionIndex;
  final List<MobilityItem> itemsForSelectedSection;
  final VoidCallback onAddItem;
  final VoidCallback onAddSection;
  final void Function(int sectionIndex) onEditSection;
  final void Function(int sectionIndex) onDeleteSection;
  final void Function(int sectionIndex) onSelectSection;
  final void Function(int oldIndex, int newIndex) onReorderItems;
  final void Function(
    String itemId,
    String title,
    String subtitle,
    String shortTitle,
  )
  onUpdateItem;
  final void Function(String itemId) onDeleteItem;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasItems = itemsForSelectedSection.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            l10n.workoutBuilderMobilityRoutineTitle.toUpperCase(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < sections.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  MobilitySectionChip(
                    label: mobilitySectionDisplayName(
                      name: sections[i].name,
                      index: i,
                      l10n: l10n,
                    ),
                    selected:
                        selectedSectionIndex.clamp(0, sections.length - 1) == i,
                    onTap: () => onSelectSection(i),
                    onEdit: () => onEditSection(i),
                    onDelete: sections.length > 1
                        ? () => onDeleteSection(i)
                        : null,
                  ),
                ],
                const SizedBox(width: 8),
                MobilityDashedSectionChip(
                  label: l10n.workoutBuilderSectionHeading,
                  onTap: onAddSection,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: hasItems
              ? ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  buildDefaultDragHandles: false,
                  // ignore: deprecated_member_use
                  onReorder: onReorderItems,
                  itemCount: itemsForSelectedSection.length,
                  itemBuilder: (context, index) {
                    final item = itemsForSelectedSection[index];
                    return MobilityItemCard(
                      key: ValueKey(item.id),
                      theme: theme,
                      colorScheme: colorScheme,
                      index: index,
                      title: item.title,
                      subtitle: item.subtitle,
                      shortTitle: item.shortTitle,
                      onEdit: (t, s, short) =>
                          onUpdateItem(item.id, t, s, short),
                      onDelete: () => onDeleteItem(item.id),
                    );
                  },
                )
              : Align(
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
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: sections.isNotEmpty ? onAddItem : null,
                          icon: const Icon(Icons.add, size: 20),
                          label: Text(l10n.workoutBuilderEmptyDayCta),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        if (hasItems)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: WorkoutDashedButton(
              icon: Icons.add,
              label: l10n.workoutBuilderAddExercise,
              onPressed: sections.isNotEmpty ? onAddItem : null,
            ),
          ),
      ],
    );
  }
}
