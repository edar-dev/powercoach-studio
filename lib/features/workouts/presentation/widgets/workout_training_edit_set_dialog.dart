import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';

void showEditSetDialog(
  BuildContext context,
  ThemeData theme,
  ColorScheme cs,
  String initialSets,
  String initialReps,
  String initialLoad,
  String initialNote,
  void Function(String sets, String reps, String load, String note) onSave,
) {
  final setsController = TextEditingController(text: initialSets);
  final repsController = TextEditingController(text: initialReps);
  final loadController = TextEditingController(text: initialLoad);
  final noteController = TextEditingController(text: initialNote);
  final l10n = AppLocalizations.of(context);
  const denseDecoration = InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderEditSetTitle,
    wrapContent: true,
    maxHeightFraction: 0.55,
    bodyBuilder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: setsController,
                decoration: denseDecoration.copyWith(
                  labelText: l10n.workoutBuilderSetLabel,
                  hintText: '1',
                ),
                keyboardType: TextInputType.number,
                autofocus: false,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: repsController,
                decoration: denseDecoration.copyWith(
                  labelText: l10n.workoutBuilderRepsLabel,
                  hintText: '3',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: loadController,
                decoration: denseDecoration.copyWith(
                  labelText: l10n.workoutBuilderLoadLabel,
                  hintText: '75kg',
                ),
                keyboardType: TextInputType.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: noteController,
          decoration: denseDecoration.copyWith(
            labelText: l10n.workoutBuilderNoteLabel,
          ),
          maxLines: 2,
        ),
      ],
    ),
    primaryActionLabel: l10n.customerSave,
    onPrimaryAction: () {
      onSave(
        setsController.text.trim(),
        repsController.text.trim(),
        loadController.text.trim(),
        noteController.text.trim(),
      );
      Navigator.of(context).pop();
    },
  );
}
