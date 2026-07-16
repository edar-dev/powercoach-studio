import 'package:flutter/material.dart';
import 'package:powercoach_studio/core/billing/plan_limits.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

import '../../../../../l10n/app_localizations.dart';

class SubscriptionUsageCard extends StatelessWidget {
  const SubscriptionUsageCard({
    super.key,
    required this.activeCustomerCount,
    required this.nearLimit,
    required this.atLimit,
  });

  final int activeCustomerCount;
  final bool nearLimit;
  final bool atLimit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final max = PlanLimits.maxActiveCustomers;
    final progress = (activeCustomerCount / max).clamp(0.0, 1.0);
    final progressColor = atLimit
        ? cs.error
        : nearLimit
            ? cs.tertiary
            : cs.primary;

    return Card(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        side: BorderSide(color: cs.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.subscriptionUsageTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.subscriptionUsageCustomers(activeCustomerCount, max),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: cs.surfaceContainerHighest,
                color: progressColor,
              ),
            ),
            if (atLimit) ...[
              const SizedBox(height: 12),
              Text(
                l10n.subscriptionUsageAtLimit,
                style: theme.textTheme.bodyMedium?.copyWith(color: cs.error),
              ),
            ] else if (nearLimit) ...[
              const SizedBox(height: 12),
              Text(
                l10n.subscriptionUsageNearLimit,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
