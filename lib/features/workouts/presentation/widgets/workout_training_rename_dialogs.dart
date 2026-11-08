import 'package:flutter/material.dart';

import '../../../../core/ui/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/app_sheet.dart';

void showRenameDayDialog(
  BuildContext context,
  String initialName,
  void Function(String) onSave,
) {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: initialName);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderRenameDayTitle,
    bodyBuilder: (sheetContext) => TextField(
      controller: controller,
      decoration: InputDecoration(labelText: l10n.workoutBuilderDayNameLabel),
      autofocus: false,
      onSubmitted: (_) {
        final name = controller.text.trim();
        if (name.isEmpty) return;
        onSave(name);
        Navigator.of(sheetContext).pop();
      },
    ),
    primaryActionLabel: l10n.customerSave,
    onPrimaryAction: () {
      final name = controller.text.trim();
      if (name.isEmpty) return;
      onSave(name);
      Navigator.of(context).pop();
    },
  );
}

Future<String?> showDuplicateWeekDialog(
  BuildContext context,
  String defaultName,
) async {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: defaultName);
  try {
    if (!AppBreakpoints.isTabletOrWider(context)) {
      return showAppBottomSheet<String>(
        context: context,
        title: l10n.workoutBuilderDuplicateWeekTitle,
        wrapContent: true,
        bodyBuilder: (sheetContext) => TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.workoutBuilderDuplicateWeekHint,
          ),
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            final trimmed = controller.text.trim();
            if (trimmed.isEmpty) return;
            Navigator.of(sheetContext).pop(trimmed);
          },
        ),
        primaryActionLabel: l10n.workoutBuilderDuplicateWeek,
        onPrimaryAction: () {
          final trimmed = controller.text.trim();
          if (trimmed.isEmpty) return;
          Navigator.of(context).pop(trimmed);
        },
      );
    }

    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.workoutBuilderDuplicateWeekTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.workoutBuilderDuplicateWeekHint,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () {
              final trimmed = controller.text.trim();
              if (trimmed.isEmpty) return;
              Navigator.of(ctx).pop(trimmed);
            },
            child: Text(l10n.workoutBuilderDuplicateWeek),
          ),
        ],
      ),
    );
  } finally {
    controller.dispose();
  }
}

void showRenameWeekDialog(
  BuildContext context,
  String initialName,
  void Function(String) onSave,
) {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: initialName);
  showAppBottomSheet<void>(
    context: context,
    title: l10n.workoutBuilderRenameWeekTitle,
    bodyBuilder: (sheetContext) => TextField(
      controller: controller,
      decoration: InputDecoration(labelText: l10n.workoutBuilderWeekNameLabel),
      autofocus: false,
      onSubmitted: (_) {
        final name = controller.text.trim();
        if (name.isEmpty) return;
        onSave(name);
        Navigator.of(sheetContext).pop();
      },
    ),
    primaryActionLabel: l10n.customerSave,
    onPrimaryAction: () {
      final name = controller.text.trim();
      if (name.isEmpty) return;
      onSave(name);
      Navigator.of(context).pop();
    },
  );
}
