import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/workout_routine_model.dart';
import '../../domain/mobility_session_presentation.dart';
import 'session_preview_card.dart';
import 'training_phase_day_card.dart';

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
                    child: TrainingPhaseAddDayCard(
                      title: l10n.workoutBuilderSectionHeading,
                      onAddDay: onAddSection,
                    ),
                  );
                }
                final section = sections[index];
                final items = itemsForSection(section.id);
                final preview = items
                    .take(SessionPreviewCard.previewLimit)
                    .toList(growable: false);
                final remaining = items.length - preview.length;
                final canDelete = sections.length > 1;
                return Padding(
                  padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
                  child: SessionPreviewCard(
                    title: mobilitySectionDisplayName(
                      name: section.name,
                      index: index,
                      l10n: l10n,
                    ),
                    subtitle: section.scheduleHint,
                    onOpen: () => onOpenSection(index),
                    previewRows: [
                      for (final item in preview)
                        SessionPreviewRowData(
                          title: item.title,
                          detail: item.subtitle.trim().isNotEmpty
                              ? item.subtitle
                              : (item.shortTitle.trim().isNotEmpty
                                  ? item.shortTitle
                                  : null),
                        ),
                    ],
                    remainingCount: remaining,
                    footerMetricLabel:
                        l10n.workoutBuilderExerciseCount(items.length),
                    showMenu: true,
                    onMenuSelected: (value) {
                      if (value == 'edit') {
                        onEditSection(index);
                      } else if (value == 'delete') {
                        onDeleteSection(index);
                      }
                    },
                    menuItems: (ctx) {
                      final menuL10n = AppLocalizations.of(ctx);
                      return [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(menuL10n.workoutBuilderEditSectionTitle),
                        ),
                        if (canDelete)
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              menuL10n.workoutBuilderDeleteSection,
                              style: TextStyle(
                                color: Theme.of(ctx).colorScheme.error,
                              ),
                            ),
                          ),
                      ];
                    },
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
