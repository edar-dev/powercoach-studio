import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Primary create actions at the bottom of the coach dashboard.
class DashboardSummaryFooter extends StatelessWidget {
  const DashboardSummaryFooter({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.l10n,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // Metrics live in [DashboardHeroMetrics]; keep only create CTAs here.
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              navigateTo(context, '/workouts/builder');
            },
            icon: const Icon(Icons.add, size: 20),
            label: Text(l10n.dashboardCreateWorkout),
            style: FilledButton.styleFrom(
              backgroundColor: StitchM3Theme.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              navigateTo(context, '/customers/new');
            },
            icon: const Icon(Icons.person_add, size: 20),
            label: Text(l10n.customersAddCustomer),
            style: OutlinedButton.styleFrom(
              foregroundColor: StitchM3Theme.accent,
              side: const BorderSide(color: StitchM3Theme.accent),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
