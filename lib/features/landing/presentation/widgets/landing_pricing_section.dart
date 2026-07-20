import 'package:flutter/material.dart';

import '../../../../core/billing/plan_limits.dart';
import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';

/// Public pricing section with Free vs Pro tiers.
class LandingPricingSection extends StatelessWidget {
  const LandingPricingSection({
    super.key,
    required this.l10n,
    required this.isLoggedIn,
    required this.onStartFree,
    required this.onUpgradePro,
  });

  final AppLocalizations l10n;
  final bool isLoggedIn;
  final VoidCallback onStartFree;
  final VoidCallback onUpgradePro;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      color: cs.surface,
      child: Column(
        children: [
          Text(
            l10n.landingPricingLabel.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: StitchM3Theme.accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.landingPricingTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: StitchM3Theme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.landingPricingSubtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: StitchM3Theme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= AppBreakpoints.tablet;
              final cards = [
                _PricingTierCard(
                  title: l10n.landingPricingFreeTitle,
                  price: l10n.landingPricingFreePrice,
                  period: l10n.landingPricingFreePeriod,
                  highlighted: false,
                  features: [
                    l10n.landingPricingFeatureCustomersFree(
                      PlanLimits.maxActiveCustomers,
                    ),
                    l10n.landingPricingFeatureBuilder,
                  ],
                  ctaLabel: l10n.landingPricingFreeCta,
                  onCta: onStartFree,
                ),
                _PricingTierCard(
                  title: l10n.landingPricingProTitle,
                  price: l10n.landingPricingProPriceMonthly,
                  period: l10n.landingPricingProPriceYearly,
                  highlighted: true,
                  features: [
                    l10n.landingPricingFeatureCustomersPro,
                    l10n.landingPricingFeatureBuilder,
                    l10n.landingPricingFeatureExportPro,
                    l10n.landingPricingFeatureHevy,
                  ],
                  ctaLabel: isLoggedIn
                      ? l10n.landingPricingProCtaLoggedIn
                      : l10n.landingPricingProCta,
                  onCta: onUpgradePro,
                ),
              ];

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 24),
                      Expanded(child: cards[i]),
                    ],
                  ],
                );
              }

              return Column(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    cards[i],
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            l10n.landingPricingBetaNote,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PricingTierCard extends StatelessWidget {
  const _PricingTierCard({
    required this.title,
    required this.price,
    required this.period,
    required this.highlighted,
    required this.features,
    required this.ctaLabel,
    required this.onCta,
  });

  final String title;
  final String price;
  final String period;
  final bool highlighted;
  final List<String> features;
  final String ctaLabel;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: highlighted ? 2 : 0,
      color: highlighted ? cs.primaryContainer.withValues(alpha: 0.35) : cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
        side: BorderSide(
          color: highlighted ? cs.primary : cs.outline,
          width: highlighted ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: highlighted ? cs.primary : cs.onSurface,
              ),
            ),
            Text(
              period,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline, size: 20, color: cs.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onCta,
              style: FilledButton.styleFrom(
                backgroundColor: highlighted ? cs.primary : cs.surfaceContainerHighest,
                foregroundColor: highlighted ? cs.onPrimary : cs.onSurface,
                minimumSize: const Size.fromHeight(44),
              ),
              child: Text(ctaLabel),
            ),
          ],
        ),
      ),
    );
  }
}
