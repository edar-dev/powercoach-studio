import 'package:flutter/material.dart';

import '../../../../core/ui/widgets/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../data/workout_routine_model.dart';
import 'mobility_builder_controller.dart';
import 'widgets/exercise_library_pick_panel.dart';
import 'widgets/mobility_section_edit_sheet.dart';
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
    showAppSnackBar(
      context,
      content: Text(message),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: l10n.workoutBuilderUndo,
        onPressed: onUndo,
      ),
    );
  }

  /// Opens the exercise library side panel and appends a mobility item.
  ///
  /// When [sectionId] is null, uses the currently selected section.
  void addMobilityItem({String? sectionId}) {
    if (readOnly) return;
    final sections = mobilityController.sections;
    if (sections.isEmpty) return;

    String targetSectionId;
    if (sectionId != null) {
      final exists = sections.any((s) => s.id == sectionId);
      if (!exists) return;
      targetSectionId = sectionId;
      final index = sections.indexWhere((s) => s.id == sectionId);
      if (index >= 0) mobilityController.selectSection(index);
    } else {
      final selected = mobilityController.selectedSectionId;
      if (selected == null) return;
      targetSectionId = selected;
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    showExerciseLibraryPickPanel(
      context: context,
      theme: theme,
      cs: cs,
      onPicked: (item, displayName) {
        final id = 'm_${DateTime.now().millisecondsSinceEpoch}';
        final title = displayName.trim().isEmpty
            ? l10n.workoutBuilderNewExerciseDefault
            : displayName.trim();
        mobilityController.addItem(
          MobilityItem(
            id: id,
            title: title,
            subtitle: '',
            sectionId: targetSectionId,
            customExerciseId: item.id,
          ),
        );
      },
    );
  }

  /// Opens the fullscreen section editor (Allenamento session-edit parity).
  void openMobilitySectionEditor(int sectionIndex) {
    final sections = mobilityController.sections;
    if (sectionIndex < 0 || sectionIndex >= sections.length) return;
    final section = sections[sectionIndex];
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    showMobilitySectionEditSheet(
      context: context,
      theme: theme,
      cs: cs,
      mobilityController: mobilityController,
      sectionId: section.id,
      readOnly: readOnly,
      onRenameSection: editMobilitySection,
      onDeleteSection: deleteMobilitySection,
      onUpdateItem: (itemId, title, subtitle, {shortTitle = ''}) {
        updateMobilityItem(itemId, title, subtitle, shortTitle: shortTitle);
      },
      onDeleteItem: removeMobilityItem,
      onReorderItems: reorderMobility,
    );
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
