import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';
import 'mobility_add_sheet_content.dart';

export 'mobility_add_sheet_content.dart';

/// Shows the "Add mobility exercise" dialog: create on the fly, from mobility library, or from exercise library.
void showAddMobilityExerciseDialog(
  BuildContext context,
  ThemeData theme,
  ColorScheme cs,
  void Function(String title, String subtitle, String? customExerciseId) onSave,
) {
  final l10n = AppLocalizations.of(context);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderAddMobilityExerciseTitle,
    fullScreen: true,
    bodyBuilder: (sheetContext) => AddMobilityExerciseDialogContent(
      theme: theme,
      cs: cs,
      onSave: onSave,
      onCancel: () => Navigator.of(sheetContext).pop(),
    ),
  );
}
