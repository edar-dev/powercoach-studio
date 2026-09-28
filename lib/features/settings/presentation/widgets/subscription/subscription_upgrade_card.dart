import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/billing/entitlement_models.dart';
import '../../../../../core/theme/marketing_dark_colors.dart';
import '../../../../../core/theme/stitch_mobile_colors.dart';
import '../../../../../core/ui/breakpoints.dart';
import '../../../../../l10n/app_localizations.dart';

/// Pro upgrade highlight card (right column of subscription hero).
class SubscriptionUpgradeCard extends StatelessWidget {
  const SubscriptionUpgradeCard({
    super.key,
    required this.busy,
    required this.yearly,
    required this.onCheckoutStarted,
    this.onYearlyChanged,
  });

  final bool busy;
  final bool yearly;
  final Future<void> Function(BillingInterval interval) onCheckoutStarted;
  final ValueChanged<bool>? onYearlyChanged;

  @override
  Widget build(BuildContext context) {
    final phone = !Breakpoints.isTabletOrWider(context);
    return phone ? _buildPhone(context) : _buildDesktop(context);
  }

  Widget _buildPhone(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bullets = [
      l10n.subscriptionFeatureUnlimitedClients,
      l10n.subscriptionFeaturePdfLogo,
      l10n.subscriptionFeatureMetrics,
      l10n.subscriptionFeatureCloudSync,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StitchMobileColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(StitchMobileColors.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: StitchMobileColors.primaryContainer.withValues(
                  alpha: 0.2,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                l10n.subscriptionRecommendedBadge,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: StitchMobileColors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.subscriptionUpgradeHighlightTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              color: StitchMobileColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: StitchMobileColors.headlineSize,
            ),
          ),
          const SizedBox(height: 12),
          if (onYearlyChanged != null)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: StitchMobileColors.surfaceContainerLowest,
                borderRadius:
                    BorderRadius.circular(StitchMobileColors.radiusXl),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _PhoneBillingTab(
                      label: l10n.subscriptionBillingMonthly,
                      selected: !yearly,
                      onTap: () => onYearlyChanged!(false),
                    ),
                  ),
                  Expanded(
                    child: _PhoneBillingTab(
                      label: l10n.subscriptionBillingYearly,
                      selected: yearly,
                      onTap: () => onYearlyChanged!(true),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Center(
            child: Text.rich(
              TextSpan(
                text: yearly
                    ? l10n.subscriptionPriceYearlyAmount
                    : l10n.subscriptionPriceMonthlyAmount,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: StitchMobileColors.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 30,
                ),
                children: [
                  TextSpan(
                    text: yearly
                        ? ' ${l10n.subscriptionRenewPerYear}'
                        : ' ${l10n.subscriptionRenewPerMonth}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: StitchMobileColors.onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final bullet in bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '✓ $bullet',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: StitchMobileColors.onSurface,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(height: 8),
          if (!kIsWeb)
            Text(
              l10n.subscriptionWebOnlyHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: StitchMobileColors.onSurfaceVariant,
              ),
            )
          else
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: busy
                    ? null
                    : () => onCheckoutStarted(
                          yearly
                              ? BillingInterval.yearly
                              : BillingInterval.monthly,
                        ),
                style: FilledButton.styleFrom(
                  backgroundColor: StitchMobileColors.primaryContainer,
                  foregroundColor: StitchMobileColors.onPrimaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(StitchMobileColors.radiusLg),
                  ),
                ),
                child: Text(
                  l10n.subscriptionUpgradeHighlightCta,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
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

class _PhoneBillingTab extends StatelessWidget {
  const _PhoneBillingTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? StitchMobileColors.surfaceContainerHigh
          : Colors.transparent,
      borderRadius: BorderRadius.circular(StitchMobileColors.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StitchMobileColors.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: selected
                  ? StitchMobileColors.onSurface
                  : StitchMobileColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
