import 'package:flutter/material.dart';

import '../../../../../core/billing/plan_limits.dart';
import '../../../../../core/theme/marketing_dark_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// Standalone usage card (kept for reuse / tests). Primary UI embeds usage in
/// [SubscriptionStatusCard].
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
    final max = PlanLimits.maxActiveCustomers;
    final progress = (activeCustomerCount / max).clamp(0.0, 1.0);
    final progressColor = atLimit
        ? theme.colorScheme.error
        : nearLimit
            ? MarketingDarkColors.amber
            : MarketingDarkColors.brandMid;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MarketingDarkColors.stitchCardElevated,
        borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl),
        border: Border.all(color: MarketingDarkColors.stitchBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.subscriptionUsageClients,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.subscriptionUsageCustomers(activeCustomerCount, max),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: MarketingDarkColors.slate300,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: MarketingDarkColors.stitchPageBg,
              color: progressColor,
            ),
          ),
          if (atLimit) ...[
            const SizedBox(height: 12),
            Text(
              l10n.subscriptionUsageAtLimit,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ] else if (nearLimit) ...[
            const SizedBox(height: 12),
            Text(
              l10n.subscriptionUsageNearLimit,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: MarketingDarkColors.slate400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
