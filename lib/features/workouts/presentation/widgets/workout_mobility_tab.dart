import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../theme/stitch_m3_theme.dart';
import '../../../../widgets/app_sheet.dart';
import '../../data/workout_routine_model.dart';

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
                  _MobilitySectionChip(
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
            onReorder: (oldIndex, newIndex) {
              var target = newIndex;
              if (target > oldIndex) target--;
              onReorderItems(oldIndex, target);
            },
            itemCount: itemsForSelectedSection.length,
            itemBuilder: (context, index) {
              final item = itemsForSelectedSection[index];
              return Padding(
                key: ValueKey(item.id),
                padding: EdgeInsets.only(
                  bottom: index < itemsForSelectedSection.length - 1 ? 8 : 0,
                ),
                child: _MobilityItem(
                  theme: theme,
                  colorScheme: colorScheme,
                  index: index,
                  title: item.title,
                  subtitle: item.subtitle,
                  shortTitle: item.shortTitle,
                  onEdit: (t, s, short) => onUpdateItem(item.id, t, s, short),
                  onDelete: () => onDeleteItem(item.id),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _DashedButton(
            icon: Icons.add,
            label: l10n.workoutBuilderAddExercise,
            onPressed: sections.isNotEmpty ? onAddItem : null,
          ),
        ),
      ],
    );
  }
}

class _MobilitySectionChip extends StatelessWidget {
  const _MobilitySectionChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    this.onDelete,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? cs.onSurface : cs.onSurfaceVariant,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.edit,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                if (onDelete != null) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: StitchM3Theme.danger,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            width: 60,
            color: selected ? StitchM3Theme.accent : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _MobilityItem extends StatelessWidget {
  const _MobilityItem({
    required this.theme,
    required this.colorScheme,
    required this.index,
    required this.title,
    required this.subtitle,
    this.shortTitle = '',
    this.onEdit,
    this.onDelete,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final int index;
  final String title;
  final String subtitle;
  final String shortTitle;
  final void Function(String title, String subtitle, String shortTitle)? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_indicator,
              size: 20,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 20, color: cs.onSurfaceVariant),
            padding: EdgeInsets.zero,
            onSelected: (value) {
              if (value == 'edit' && onEdit != null) {
                _showEditMobilityDialog(
                  context,
                  title,
                  subtitle,
                  shortTitle,
                  onEdit!,
                );
              } else if (value == 'delete') {
                onDelete?.call();
              }
            },
            itemBuilder: (ctx) {
              final l10n = AppLocalizations.of(ctx);
              return [
                if (onEdit != null)
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(l10n.workoutBuilderEditExercise),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    l10n.workoutBuilderDeleteExercise,
                    style: const TextStyle(color: StitchM3Theme.danger),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}

void _showEditMobilityDialog(
  BuildContext context,
  String initialTitle,
  String initialSubtitle,
  String initialShortTitle,
  void Function(String title, String subtitle, String shortTitle) onSave,
) {
  final l10n = AppLocalizations.of(context);
  final titleController = TextEditingController(text: initialTitle);
  final subtitleController = TextEditingController(text: initialSubtitle);
  final shortTitleController = TextEditingController(text: initialShortTitle);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderEditMobilityExerciseTitle,
    fullScreen: false,
    bodyBuilder: (sheetContext) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: titleController,
          decoration: InputDecoration(labelText: l10n.mobilityTitle),
          autofocus: false,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: shortTitleController,
          decoration: InputDecoration(labelText: l10n.mobilityShortTitleLabel),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: subtitleController,
          decoration: InputDecoration(labelText: l10n.mobilitySubtitle),
          maxLines: 2,
        ),
      ],
    ),
    primaryActionLabel: l10n.customerSave,
    onPrimaryAction: () {
      onSave(
        titleController.text.trim(),
        subtitleController.text.trim(),
        shortTitleController.text.trim(),
      );
      Navigator.of(context).pop();
    },
  );
}

class _DashedButton extends StatelessWidget {
  const _DashedButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: onPressed != null
              ? StitchM3Theme.accent.withValues(alpha: 0.5)
              : cs.outline.withValues(alpha: 0.35),
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        ),
        foregroundColor: onPressed != null
            ? StitchM3Theme.accent
            : cs.onSurfaceVariant,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
