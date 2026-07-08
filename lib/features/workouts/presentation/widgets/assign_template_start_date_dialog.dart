import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class AssignTemplateStartDateResult {
  const AssignTemplateStartDateResult._({
    required this.cancelled,
    required this.startDate,
  });

  const AssignTemplateStartDateResult.cancelled()
    : this._(cancelled: true, startDate: null);

  const AssignTemplateStartDateResult.confirmed(DateTime? startDate)
    : this._(cancelled: false, startDate: startDate);

  final bool cancelled;
  final DateTime? startDate;
}

Future<AssignTemplateStartDateResult?> showAssignTemplateStartDateDialog(
  BuildContext context,
) {
  return showDialog<AssignTemplateStartDateResult>(
    context: context,
    builder: (ctx) => const AssignTemplateStartDateDialog(),
  );
}

class AssignTemplateStartDateDialog extends StatefulWidget {
  const AssignTemplateStartDateDialog({super.key});

  @override
  State<AssignTemplateStartDateDialog> createState() =>
      _AssignTemplateStartDateDialogState();
}

class _AssignTemplateStartDateDialogState
    extends State<AssignTemplateStartDateDialog> {
  DateTime? _selectedStartDate;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial =
        _selectedStartDate ?? DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 10, 12, 31),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedStartDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final materialL10n = MaterialLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.workoutTemplatesAssignStartDate),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(
              _selectedStartDate == null
                  ? l10n.workoutTemplatesAssignStartDateHint
                  : materialL10n.formatFullDate(_selectedStartDate!),
            ),
            trailing: _selectedStartDate == null
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: l10n.workoutFollowUpStartDateClear,
                    onPressed: () => setState(() => _selectedStartDate = null),
                  ),
            onTap: _pickDate,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(const AssignTemplateStartDateResult.cancelled()),
          child: Text(materialL10n.cancelButtonLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(const AssignTemplateStartDateResult.confirmed(null)),
          child: Text(l10n.workoutTemplatesAssignStartDateSkip),
        ),
        FilledButton(
          onPressed: _selectedStartDate == null
              ? null
              : () => Navigator.of(context).pop(
                  AssignTemplateStartDateResult.confirmed(_selectedStartDate),
                ),
          child: Text(l10n.workoutTemplatesAssign),
        ),
      ],
    );
  }
}
