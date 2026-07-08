import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';

enum CoachHubToolsMenuAction { diary, stats }

/// Overflow menu for diary and coach stats entry points.
class CoachHubToolsMenu extends StatelessWidget {
  const CoachHubToolsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopupMenuButton<CoachHubToolsMenuAction>(
      tooltip: l10n.dashboardCoachToolsTitle,
      onSelected: (action) {
        HapticFeedback.mediumImpact();
        switch (action) {
          case CoachHubToolsMenuAction.diary:
            navigateTo(context, workoutDiaryPath());
          case CoachHubToolsMenuAction.stats:
            navigateTo(context, '/workouts/stats');
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: CoachHubToolsMenuAction.diary,
          child: Text(l10n.dashboardDiaryAction),
        ),
        PopupMenuItem(
          value: CoachHubToolsMenuAction.stats,
          child: Text(l10n.dashboardStatsAction),
        ),
      ],
    );
  }
}
