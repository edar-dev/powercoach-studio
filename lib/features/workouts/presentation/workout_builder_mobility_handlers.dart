import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../data/workout_routine_model.dart';
import 'mobility_builder_controller.dart';
import 'widgets/mobility_add_sheet.dart';
import 'widgets/mobility_section_editor_sheet.dart';

/// Mobility-tab UI actions for the workout builder.
class WorkoutBuilderMobilityHandlers {
  WorkoutBuilderMobilityHandlers({
    required this.context,
    required this.mobilityController,
  });

  final BuildContext context;
  final MobilityBuilderController mobilityController;

  void addMobilityItem() {
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
    mobilityController.removeItem(id);
  }

  void reorderMobility(int oldIndex, int newIndex) {
    mobilityController.reorderItems(oldIndex, newIndex);
  }

  void addMobilitySection() {
    final l10n = AppLocalizations.of(context);
    mobilityController.addSection(
      name: l10n.workoutBuilderSectionNumbered(
        mobilityController.sections.length + 1,
      ),
    );
  }

  void editMobilitySection(int index) {
    final sections = mobilityController.sections;
    if (index < 0 || index >= sections.length) return;
    final section = sections[index];
    showEditMobilitySectionSheet(
      context,
      initialName: section.name,
      initialScheduleHint: section.scheduleHint,
      onSave: (newName, scheduleHint) {
        if (newName.trim().isEmpty) return;
        mobilityController.updateSection(
          sectionId: section.id,
          name: newName,
          scheduleHint: scheduleHint,
        );
      },
    );
  }

  void deleteMobilitySection(int index) {
    mobilityController.deleteSection(index);
  }

  void updateMobilityItem(
    String id,
    String title,
    String subtitle, {
    String shortTitle = '',
  }) {
    mobilityController.updateItem(
      itemId: id,
      title: title,
      subtitle: subtitle,
      shortTitle: shortTitle,
    );
  }
}
