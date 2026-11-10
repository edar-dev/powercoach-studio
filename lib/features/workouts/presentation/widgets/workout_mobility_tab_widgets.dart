import 'package:flutter/material.dart';

import '../../../../core/ui/widgets/app_sheet.dart';
import '../../../../l10n/app_localizations.dart';
export '../../domain/mobility_session_presentation.dart'
    show isUnsetMobilitySectionName, mobilitySectionDisplayName;

/// Legacy bottom-sheet editor — kept for callers outside the primary expand path.
@Deprecated('Prefer expand-in-place editing via SessionExerciseEditorCard')
void showEditMobilityItemDialog(
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
