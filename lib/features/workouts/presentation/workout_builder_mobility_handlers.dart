import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../data/workout_routine_model.dart';
import 'mobility_builder_controller.dart';
import 'widgets/mobility_add_sheet.dart';
import 'widgets/mobility_section_editor_sheet.dart';
import 'widgets/workout_mobility_tab_widgets.dart';
/// Mobility-tab UI actions for the workout builder.
class WorkoutBuilderMobilityHandlers {
  WorkoutBuilderMobilityHandlers({
    required this.context,
    required this.mobilityController,
    this.readOnly = false,
  });

  final BuildContext context;
  final MobilityBuilderController mobilityController;
  final bool readOnly;

  void _showUndoSnackBar(String message, VoidCallback onUndo) {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: l10n.workoutBuilderUndo,
          onPressed: onUndo,
        ),
      ),
    );
  }

  void addMobilityItem() {
    if (readOnly) return;
    final sectionId = mobilityController.selectedSectionId;
    if (sectionId == null) return;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    showAddMobilityExerciseDialog(context, theme, cs, (
      title,
      subtitle,
      customExerciseId,
    ) {
      final t = title.trim();
      final s = subtitle.trim();
      if (t.isEmpty && s.isEmpty) return;
      final id = 'm_${DateTime.now().millisecondsSinceEpoch}';
      mobilityController.addItem(
        MobilityItem(
          id: id,
          title: t.isEmpty ? l10n.workoutBuilderNewExerciseDefault : t,
          subtitle: s,
          sectionId: sectionId,
          customExerciseId: customExerciseId,
        ),
      );
    });
  }

  void removeMobilityItem(String id) {
    if (readOnly) return;
    final items = mobilityController.routine.mobilityItems;
    MobilityItem? removed;
    for (final item in items) {
      if (item.id == id) {
        removed = item;
        break;
      }
    }
    if (removed == null) return;
    final sectionItems =
        items.where((e) => e.sectionId == removed!.sectionId).toList();
    final indexInSection = sectionItems.indexWhere((e) => e.id == id);
    mobilityController.removeItem(id);
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    final snapshot = removed;
    final restoreIndex = indexInSection < 0 ? 0 : indexInSection;
    _showUndoSnackBar(l10n.workoutBuilderMobilityItemRemoved, () {
      mobilityController.insertItemAt(
        item: snapshot,
        indexInSection: restoreIndex,
      );
    });
  }

  void reorderMobility(int oldIndex, int newIndex) {
    if (readOnly) return;
    mobilityController.reorderItems(oldIndex, newIndex);
  }

  void addMobilitySection() {
    if (readOnly) return;
    mobilityController.addSection(name: '');
  }

  void editMobilitySection(int index) {
    if (readOnly) return;
    final sections = mobilityController.sections;
    if (index < 0 || index >= sections.length) return;
    final section = sections[index];
    final l10n = AppLocalizations.of(context);
    final displayName = mobilitySectionDisplayName(
      name: section.name,
      index: index,
      l10n: l10n,
    );
    showEditMobilitySectionSheet(
      context,
      initialName: displayName,
      initialScheduleHint: section.scheduleHint,
      onSave: (newName, scheduleHint) {
        final trimmed = newName.trim();
        if (trimmed.isEmpty) return;
        // Keep unset convention: don't persist locale-specific defaults.
        final defaultLabel = l10n.workoutBuilderSectionNumbered(index + 1);
        final persisted =
            trimmed == defaultLabel || isUnsetMobilitySectionName(trimmed)
                ? ''
                : trimmed;
        mobilityController.updateSection(
          sectionId: section.id,
          name: persisted,
          scheduleHint: scheduleHint,
        );
      },
    );
  }

  void deleteMobilitySection(int index) {
    if (readOnly) return;
    mobilityController.deleteSection(index);
  }

  void updateMobilityItem(
    String id,
    String title,
    String subtitle, {
    String shortTitle = '',
  }) {
    if (readOnly) return;
    mobilityController.updateItem(
      itemId: id,
      title: title,
      subtitle: subtitle,
      shortTitle: shortTitle,
    );
  }
}
