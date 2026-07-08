import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'landing_feature_card.dart';

/// Features grid on the landing page.
class LandingFeaturesSection extends StatelessWidget {
  const LandingFeaturesSection({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: const BoxDecoration(
        color: StitchM3Theme.bg,
      ),
      child: Column(
        children: [
          Text(
            l10n.landingFeaturesTitle.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: StitchM3Theme.accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.landingFeaturesHeadline,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: StitchM3Theme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.landingFeaturesDesc,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: StitchM3Theme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              LandingFeatureCard(
                icon: Icons.people_outline,
                title: l10n.landingFeaturesCustomers,
                subtitle: l10n.landingFeaturesEditor,
              ),
              LandingFeatureCard(
                icon: Icons.analytics_outlined,
                title: l10n.landingFeaturesClientData,
                subtitle: l10n.landingFeaturesExport,
              ),
              LandingFeatureCard(
                icon: Icons.picture_as_pdf_outlined,
                title: l10n.landingFeaturesExport,
                subtitle: l10n.landingFeaturesEditor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
