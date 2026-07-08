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

Future<WorkoutFollowUpDraft?> showWorkoutFollowUpDialog(
  BuildContext context, {
  required WorkoutPlanApiModel plan,
  required SessionExecutionService executionService,
}) async {
  final l10n = AppLocalizations.of(context);
  final executions = await executionService.listForPlan(plan.id);
  if (!context.mounted) return null;
  final completedCount = countCompletedExecutions(executions);
  final controller = TextEditingController(
    text: '${plan.name} - ${l10n.workoutFollowUpDefaultSuffix}',
  );
  DateTime? selectedStartDate;
  var applyExecutedLoads = completedCount > 0;
  try {
    if (!context.mounted) return null;
    return await showDialog<WorkoutFollowUpDraft>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.workoutFollowUpTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
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
                  selectedStartDate != null
                      ? MaterialLocalizations.of(
                          ctx,
                        ).formatFullDate(selectedStartDate!)
                      : l10n.workoutFollowUpStartDateOptional,
                ),
                trailing: selectedStartDate != null
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: l10n.workoutFollowUpStartDateClear,
                        onPressed: () =>
                            setDialogState(() => selectedStartDate = null),
                      )
                    : null,
                onTap: () async {
                  final now = DateTime.now();
                  final initial =
                      selectedStartDate ??
                      DateTime(now.year, now.month, now.day);
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: initial,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(now.year + 10, 12, 31),
                  );
                  if (picked == null) return;
                  setDialogState(() {
                    selectedStartDate = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                    );
                  });
                },
              ),
              if (completedCount > 0)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: applyExecutedLoads,
                  onChanged: (v) =>
                      setDialogState(() => applyExecutedLoads = v ?? false),
                  title: Text(l10n.workoutFollowUpFromExecution),
                  subtitle: Text(
                    l10n.workoutFollowUpFromExecutionHint(completedCount),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.workoutFollowUpNoExecutionData,
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.customerCancel),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                Navigator.of(ctx).pop((
                  name: name,
                  startDate: selectedStartDate,
                  applyExecutedLoads: completedCount > 0 && applyExecutedLoads,
                ));
              },
              child: Text(l10n.workoutFollowUpCreateAction),
            ),
          ],
        ),
      ),
    );
  } finally {
    controller.dispose();
  }
}
