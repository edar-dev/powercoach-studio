import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/workout_plan_api_model.dart';
import '../../domain/session_execution_service.dart';
import '../../domain/workout_follow_up_factory.dart';

typedef WorkoutFollowUpDraft = ({
  String name,
  DateTime? startDate,
  bool applyExecutedLoads,
});

/// Slim follow-up dialog: name + optional start date.
/// When executions exist, applied loads default on without toggle chrome.
Future<WorkoutFollowUpDraft?> showWorkoutFollowUpDialog(
  BuildContext context, {
  required WorkoutPlanApiModel plan,
  required SessionExecutionService executionService,
}) async {
  final l10n = AppLocalizations.of(context);
  final executions = await executionService.listForPlan(plan.id);
  if (!context.mounted) return null;
  final completedCount = countCompletedExecutions(executions);
  final applyExecutedLoads = completedCount > 0;
  return showDialog<WorkoutFollowUpDraft>(
    context: context,
    builder: (ctx) => _WorkoutFollowUpDialog(
      l10n: l10n,
      initialName: '${plan.name} - ${l10n.workoutFollowUpDefaultSuffix}',
      applyExecutedLoads: applyExecutedLoads,
      completedExecutionCount: completedCount,
    ),
  );
}

class _WorkoutFollowUpDialog extends StatefulWidget {
  const _WorkoutFollowUpDialog({
    required this.l10n,
    required this.initialName,
    required this.applyExecutedLoads,
    required this.completedExecutionCount,
  });

  final AppLocalizations l10n;
  final String initialName;
  final bool applyExecutedLoads;
  final int completedExecutionCount;

  @override
  State<_WorkoutFollowUpDialog> createState() => _WorkoutFollowUpDialogState();
}

class _WorkoutFollowUpDialogState extends State<_WorkoutFollowUpDialog> {
  late final TextEditingController _controller;
  DateTime? _selectedStartDate;

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
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.workoutFollowUpTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: l10n.workoutFollowUpNameHint,
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(
              _selectedStartDate != null
                  ? MaterialLocalizations.of(
                      context,
                    ).formatFullDate(_selectedStartDate!)
                  : l10n.workoutFollowUpStartDateOptional,
            ),
            trailing: _selectedStartDate != null
                ? IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: l10n.workoutFollowUpStartDateClear,
                    onPressed: () => setState(() => _selectedStartDate = null),
                  )
                : null,
            onTap: () async {
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
                _selectedStartDate = DateTime(
                  picked.year,
                  picked.month,
                  picked.day,
                );
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            widget.applyExecutedLoads
                ? l10n.workoutFollowUpFromExecutionHint(
                    widget.completedExecutionCount,
                  )
                : l10n.workoutFollowUpNoExecutionData,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.customerCancel),
        ),
        FilledButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isEmpty) return;
            Navigator.of(context).pop((
              name: name,
              startDate: _selectedStartDate,
              applyExecutedLoads: widget.applyExecutedLoads,
            ));
          },
          child: Text(l10n.workoutFollowUpCreateAction),
        ),
      ],
    );
  }
}
