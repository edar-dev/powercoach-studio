import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../data/workout_routine_model.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.workoutBuilderMobilityRoutineTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton.icon(
                onPressed: onAddItem,
                icon: Icon(Icons.add, size: 18, color: StitchM3Theme.accent),
                label: Text(
                  l10n.workoutBuilderAddShort,
                  style: TextStyle(
                    color: StitchM3Theme.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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
                    label: sections[i].name,
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
                InkWell(
                  onTap: onAddSection,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18, color: StitchM3Theme.accent),
                        const SizedBox(width: 4),
                        Text(
                          l10n.workoutBuilderSectionHeading,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: StitchM3Theme.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
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
                onEdit: (t, s, short) => onUpdateItem(item.id, t, s, short),
                onDelete: () => onDeleteItem(item.id),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: MobilityDashedButton(
            icon: Icons.add,
            label: l10n.workoutBuilderAddExercise,
            onPressed: sections.isNotEmpty ? onAddItem : null,
          ),
        ),
      ],
    );
  }
}
