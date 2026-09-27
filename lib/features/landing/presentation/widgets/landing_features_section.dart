import 'package:flutter/material.dart';

import '../../../../core/ui/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../landing_colors.dart';
import 'landing_feature_card.dart';

/// Features grid — 4 rich cards from Stitch dark landing (`#funzionalita`).
class LandingFeaturesSection extends StatelessWidget {
  const LandingFeaturesSection({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cards = [
      LandingFeatureCard(
        icon: Icons.people_outline,
        iconColor: LandingColors.brandLight,
        iconBg: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
        iconBorder: LandingColors.brandMid.withValues(alpha: 0.3),
        title: l10n.landingFeature1Title,
        eyebrow: l10n.landingFeature1Eyebrow,
        body: l10n.landingFeature1Body,
        bullets: [
          l10n.landingFeature1Bullet1,
          l10n.landingFeature1Bullet2,
          l10n.landingFeature1Bullet3,
        ],
        footerLeft: l10n.landingFeature1FooterLeft,
        footerRight: l10n.landingFeature1FooterRight,
      ),
      LandingFeatureCard(
        icon: Icons.bar_chart_outlined,
        iconColor: LandingColors.indigo,
        iconBg: const Color(0xFF312E81).withValues(alpha: 0.3),
        iconBorder: LandingColors.indigo.withValues(alpha: 0.3),
        title: l10n.landingFeature2Title,
        eyebrow: l10n.landingFeature2Eyebrow,
        body: l10n.landingFeature2Body,
        bullets: [
          l10n.landingFeature2Bullet1,
          l10n.landingFeature2Bullet2,
          l10n.landingFeature2Bullet3,
        ],
        footerLeft: l10n.landingFeature2FooterLeft,
        footerRight: l10n.landingFeature2FooterRight,
      ),
      LandingFeatureCard(
        icon: Icons.view_module_outlined,
        iconColor: LandingColors.cyan,
        iconBg: const Color(0xFF083344).withValues(alpha: 0.4),
        iconBorder: LandingColors.cyan.withValues(alpha: 0.3),
        title: l10n.landingFeature3Title,
        eyebrow: l10n.landingFeature3Eyebrow,
        body: l10n.landingFeature3Body,
        bullets: [
          l10n.landingFeature3Bullet1,
          l10n.landingFeature3Bullet2,
          l10n.landingFeature3Bullet3,
        ],
        footerLeft: l10n.landingFeature3FooterLeft,
        footerRight: l10n.landingFeature3FooterRight,
        bulletColor: LandingColors.cyan,
      ),
      LandingFeatureCard(
        icon: Icons.storage_outlined,
        iconColor: LandingColors.emerald,
        iconBg: LandingColors.emeraldBg,
        iconBorder: LandingColors.emeraldBorder,
        title: l10n.landingFeature4Title,
        eyebrow: l10n.landingFeature4Eyebrow,
        body: l10n.landingFeature4Body,
        bullets: [
          l10n.landingFeature4Bullet1,
          l10n.landingFeature4Bullet2,
          l10n.landingFeature4Bullet3,
        ],
        footerLeft: l10n.landingFeature4FooterLeft,
        footerRight: l10n.landingFeature4FooterRight,
        bulletColor: LandingColors.emerald,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      decoration: BoxDecoration(
        color: LandingColors.bg,
        border: Border(
          top: BorderSide(color: LandingColors.border.withValues(alpha: 0.8)),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF172554).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFF1E40AF).withValues(alpha: 0.6),
              ),
            ),
            child: Text(
              l10n.landingFeaturesTitle.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                color: LandingColors.brandLight,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.landingFeaturesHeadline,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              l10n.landingFeaturesDesc,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: LandingColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= AppBreakpoints.tablet;
              if (!wide) {
                return Column(
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(height: 16),
                      cards[i],
                    ],
                  ],
                );
              }
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 20),
                      Expanded(child: cards[1]),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cards[2]),
                      const SizedBox(width: 20),
                      Expanded(child: cards[3]),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
