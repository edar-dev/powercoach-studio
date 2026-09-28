import 'package:flutter/material.dart';

import '../../../../../core/billing/entitlement_models.dart';
import '../../../../../core/billing/entitlement_presentation.dart';
import '../../../../../core/billing/plan_limits.dart';
import '../../../../../core/theme/marketing_dark_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// Current plan hero with usage bar (left/main column).
class SubscriptionStatusCard extends StatelessWidget {
  const SubscriptionStatusCard({
    super.key,
    required this.entitlement,
    required this.planLabel,
    required this.activeCustomerCount,
    required this.nearLimit,
    required this.atLimit,
  });

  final Entitlement entitlement;
  final String planLabel;
  final int activeCustomerCount;
  final bool nearLimit;
  final bool atLimit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = EntitlementPresentation.viewModel(l10n, entitlement);
    final isPro = entitlement.isPro;
    final max = PlanLimits.maxActiveCustomers;
    final progress = isPro
        ? 0.0
        : (activeCustomerCount / max).clamp(0.0, 1.0);
    final remaining = (max - activeCustomerCount).clamp(0, max);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MarketingDarkColors.stitchCardElevated.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl),
        border: Border.all(color: MarketingDarkColors.stitchBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.subscriptionPlanInUse.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: MarketingDarkColors.slate400,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _StatusPill(
                          label: status.chipLabel,
                          tone: status.chipTone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPro ? planLabel : l10n.subscriptionFreeCoachLabel,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (status.detail != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        status.detail!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: MarketingDarkColors.slate400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!isPro) ...[
            const SizedBox(height: 24),
            const Divider(height: 1, color: MarketingDarkColors.stitchBorder),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.subscriptionUsageClients,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: MarketingDarkColors.slate300,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '$activeCustomerCount',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: MarketingDarkColors.brandLight,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(
                        text: ' / $max',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: MarketingDarkColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 14,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: MarketingDarkColors.stitchPageBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: MarketingDarkColors.stitchBorder),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.transparent,
                  color: atLimit
                      ? theme.colorScheme.error
                      : nearLimit
                          ? MarketingDarkColors.amber
                          : MarketingDarkColors.brandMid,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.subscriptionSlotsRemaining(remaining),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: MarketingDarkColors.slate300,
                    ),
                  ),
                ),
                Text(
                  l10n.subscriptionLimitAtFive,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: MarketingDarkColors.amber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.tone});

  final String label;
  final SubscriptionStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (tone) {
      SubscriptionStatusTone.positive => (
          MarketingDarkColors.emerald.withValues(alpha: 0.12),
          MarketingDarkColors.emerald,
          MarketingDarkColors.emeraldBorder,
        ),
      SubscriptionStatusTone.warning => (
          const Color(0x26F43F5E),
          const Color(0xFFFB7185),
          const Color(0x33F43F5E),
        ),
      SubscriptionStatusTone.neutral => (
          MarketingDarkColors.amber.withValues(alpha: 0.1),
          MarketingDarkColors.amber,
          MarketingDarkColors.amber.withValues(alpha: 0.2),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
