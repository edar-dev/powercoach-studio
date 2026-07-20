import 'package:flutter/material.dart';

import '../../../../core/constants/legal_urls.dart';
import '../../../../core/platform/open_external_url.dart';
import '../../../../l10n/app_localizations.dart';

/// Footer with legal links for the public landing page.
class LandingFooterSection extends StatelessWidget {
  const LandingFooterSection({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final year = DateTime.now().year;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: () => openExternalUrl(LegalUrls.privacyPolicy),
                child: Text(l10n.landingFooterPrivacy),
              ),
              TextButton(
                onPressed: () => openExternalUrl(LegalUrls.termsOfService),
                child: Text(l10n.landingFooterTerms),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.landingFooterCopyright(year),
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
