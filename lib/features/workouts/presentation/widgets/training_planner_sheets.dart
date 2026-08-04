import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

typedef TrainingPlannerMenuAction = ({
  IconData icon,
  String label,
  VoidCallback onTap,
  bool destructive,
});

void showTrainingPlannerMenuSheet(
  BuildContext context, {
  required List<TrainingPlannerMenuAction> actions,
}) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: actions
            .map(
              (a) => ListTile(
                leading: Icon(
                  a.icon,
                  color: a.destructive ? StitchM3Theme.danger : null,
                ),
                title: Text(
                  a.label,
                  style: a.destructive
                      ? const TextStyle(color: StitchM3Theme.danger)
                      : null,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  a.onTap();
                },
              ),
            )
            .toList(),
      ),
    ),
  );
}

void showTrainingAddWeekMenuSheet(
  BuildContext context,
  AppLocalizations l10n,
  int weekIndex, {
  required VoidCallback onNewWeek,
  required void Function(int) onCloneWeek,
}) {
  showTrainingPlannerMenuSheet(
    context,
    actions: [
      (
        icon: Icons.add,
        label: l10n.workoutBuilderNewWeek,
        onTap: onNewWeek,
        destructive: false,
      ),
      (
        icon: Icons.copy,
        label: l10n.workoutBuilderDuplicateWeek,
        onTap: () => onCloneWeek(weekIndex),
        destructive: false,
      ),
    ],
  );
}
