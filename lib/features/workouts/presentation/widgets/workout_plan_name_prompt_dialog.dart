import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Prompts for a non-empty workout plan name; returns null when cancelled.
Future<String?> showWorkoutPlanNamePromptDialog(
  BuildContext context, {
  required String title,
  required String nameLabel,
  required String confirmLabel,
  required String initialName,
}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => _WorkoutPlanNamePromptDialog(
      title: title,
      nameLabel: nameLabel,
      confirmLabel: confirmLabel,
      initialName: initialName,
    ),
  );
}

class _WorkoutPlanNamePromptDialog extends StatefulWidget {
  const _WorkoutPlanNamePromptDialog({
    required this.title,
    required this.nameLabel,
    required this.confirmLabel,
    required this.initialName,
  });

  final String title;
  final String nameLabel;
  final String confirmLabel;
  final String initialName;

  @override
  State<_WorkoutPlanNamePromptDialog> createState() =>
      _WorkoutPlanNamePromptDialogState();
}

class _WorkoutPlanNamePromptDialogState
    extends State<_WorkoutPlanNamePromptDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(labelText: widget.nameLabel),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.customerCancel),
        ),
        FilledButton(
          onPressed: () {
            final value = _controller.text.trim();
            if (value.isEmpty) return;
            Navigator.of(context).pop(value);
          },
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
