import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import 'workout_mobility_tab_widgets.dart';

/// Mobilità tab: vertical list of day-style section cards (Allenamento parity).
///
/// Items live inside the section editor opened via [onOpenSection]; the tab
/// only shows section previews and the dashed add-section CTA.
class WorkoutMobilityTab extends StatelessWidget {
  const WorkoutMobilityTab({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.sections,
    required this.itemsForSection,
    required this.onOpenSection,
    required this.onAddSection,
    required this.onEditSection,
    required this.onDeleteSection,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final List<MobilitySection> sections;
  final List<MobilityItem> Function(String sectionId) itemsForSection;
  final void Function(int sectionIndex) onOpenSection;
  final VoidCallback onAddSection;
  final void Function(int sectionIndex) onEditSection;
  final void Function(int sectionIndex) onDeleteSection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.workoutBuilderMobilityRoutineTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == sections.length) {
                  return Padding(
                    padding: EdgeInsets.only(
                      top: sections.isEmpty ? 0 : 12,
                    ),
                    child: MobilityAddSectionCard(
                      label: l10n.workoutBuilderSectionHeading,
                      onTap: onAddSection,
                    ),
                  );
                }
                final section = sections[index];
                final items = itemsForSection(section.id);
                return Padding(
                  padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
                  child: MobilitySectionCard(
                    label: mobilitySectionDisplayName(
                      name: section.name,
                      index: index,
                      l10n: l10n,
                    ),
                    items: items,
                    scheduleHint: section.scheduleHint,
                    onOpen: () => onOpenSection(index),
                    onEdit: () => onEditSection(index),
                    onDelete: sections.length > 1
                        ? () => onDeleteSection(index)
                        : null,
                  ),
                );
              },
              childCount: sections.length + 1,
            ),
          ),
        ),
      ],
    );
  }
}
