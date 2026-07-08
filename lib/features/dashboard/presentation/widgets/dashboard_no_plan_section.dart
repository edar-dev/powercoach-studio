import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../domain/dashboard_snapshot.dart';
import 'dashboard_empty_placeholder.dart';

/// "Clients without a program" section for the coach dashboard.
class DashboardNoPlanSection extends StatelessWidget {
  const DashboardNoPlanSection({
    super.key,
    required this.theme,
    required this.colorScheme,
    required this.l10n,
    required this.snapshot,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.customersWithoutPlan.isEmpty) {
      return DashboardEmptyPlaceholder(
        message: l10n.dashboardNoCustomersWithoutPlan,
        icon: Icons.people_outline,
      );
    }
    return Column(
      children: snapshot.customersWithoutPlan.map((c) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
            child: InkWell(
              borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
              onTap: () {
                HapticFeedback.mediumImpact();
                navigateTo(context, '/customers/${c.customerId}');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        c.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
