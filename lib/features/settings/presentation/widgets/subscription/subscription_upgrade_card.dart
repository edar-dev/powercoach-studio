import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/billing/entitlement_models.dart';
import '../../../../../core/theme/marketing_dark_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// Pro upgrade highlight card (right column of subscription hero).
class SubscriptionUpgradeCard extends StatelessWidget {
  const SubscriptionUpgradeCard({
    super.key,
    required this.busy,
    required this.yearly,
    required this.onCheckoutStarted,
  });

  final bool busy;
  final bool yearly;
  final Future<void> Function(BillingInterval interval) onCheckoutStarted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final priceLabel = yearly
        ? l10n.subscriptionUpgradeYearly
        : l10n.subscriptionUpgradeMonthly;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF172554),
            MarketingDarkColors.stitchCardElevated,
          ],
        ),
        borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl),
        border: Border.all(
          color: MarketingDarkColors.brandMid.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: MarketingDarkColors.brand.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: MarketingDarkColors.brand.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: MarketingDarkColors.brandMid.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                l10n.subscriptionRecommendedBadge,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: MarketingDarkColors.brandSoft,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.subscriptionUpgradeHighlightTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.subscriptionUpgradeHighlightBody,
            style: theme.textTheme.bodySmall?.copyWith(
              color: MarketingDarkColors.slate300,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: MarketingDarkColors.stitchBorder),
          const SizedBox(height: 16),
          Text(
            priceLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          if (!kIsWeb)
            Text(
              l10n.subscriptionWebOnlyHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: MarketingDarkColors.slate400,
              ),
            )
          else
            FilledButton(
              onPressed: busy
                  ? null
                  : () => onCheckoutStarted(
                        yearly
                            ? BillingInterval.yearly
                            : BillingInterval.monthly,
                      ),
              style: FilledButton.styleFrom(
                backgroundColor: MarketingDarkColors.brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(MarketingDarkColors.radiusXl),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.subscriptionUpgradeHighlightCta,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
