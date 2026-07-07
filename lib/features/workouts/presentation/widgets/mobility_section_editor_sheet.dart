import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';

/// Bottom sheet to rename a mobility section and edit its schedule hint.
void showEditMobilitySectionSheet(
  BuildContext context, {
  required String initialName,
  required String initialScheduleHint,
  required void Function(String name, String scheduleHint) onSave,
}) {
  final l10n = AppLocalizations.of(context);
  final nameController = TextEditingController(text: initialName);
  final scheduleController = TextEditingController(text: initialScheduleHint);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderEditSectionTitle,
    bodyBuilder: (sheetContext) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: l10n.workoutBuilderSectionNameLabel,
            ),
            autofocus: false,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: scheduleController,
            decoration: InputDecoration(
              labelText: l10n.mobilitySectionScheduleHintLabel,
            ),
            maxLines: 2,
          ),
        ],
      );
    },
    primaryActionLabel: l10n.customerSave,
    onPrimaryAction: () {
      onSave(nameController.text.trim(), scheduleController.text.trim());
      Navigator.of(context).pop();
    },
  );
}
