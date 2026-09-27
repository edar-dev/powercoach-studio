import 'package:flutter/material.dart';

import '../../../../core/constants/legal_urls.dart';
import '../../../../core/platform/open_external_url.dart';
import '../../../../l10n/app_localizations.dart';
import '../landing_colors.dart';

/// Footer with legal links for the public landing page (dark Stitch chrome).
class LandingFooterSection extends StatelessWidget {
  const LandingFooterSection({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final year = DateTime.now().year;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      decoration: const BoxDecoration(
        color: LandingColors.bgDeep,
        border: Border(top: BorderSide(color: LandingColors.border)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LandingColors.brand,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PC',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.appTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              l10n.landingFooterTagline,
              style: theme.textTheme.bodySmall?.copyWith(
                color: LandingColors.textMuted,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              TextButton(
                onPressed: () => openExternalUrl(LegalUrls.privacyPolicy),
                style: TextButton.styleFrom(
                  foregroundColor: LandingColors.textMuted,
                ),
                child: Text(l10n.landingFooterPrivacy),
              ),
              TextButton(
                onPressed: () => openExternalUrl(LegalUrls.termsOfService),
                style: TextButton.styleFrom(
                  foregroundColor: LandingColors.textMuted,
                ),
                child: Text(l10n.landingFooterTerms),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.landingFooterCopyright(year),
            style: theme.textTheme.bodySmall?.copyWith(
              color: LandingColors.textDim,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: LandingColors.emerald,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.landingFooterSystemsOk,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: LandingColors.emerald,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
