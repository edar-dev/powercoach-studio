import 'package:flutter/material.dart';

import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// FAQ accordion for the public landing page.
class LandingFaqSection extends StatelessWidget {
  const LandingFaqSection({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      _FaqItem(l10n.landingFaqLocalDataQ, l10n.landingFaqLocalDataA),
      _FaqItem(l10n.landingFaqDeskGymQ, l10n.landingFaqDeskGymA),
      _FaqItem(l10n.landingFaqFreeProQ, l10n.landingFaqFreeProA),
      _FaqItem(l10n.landingFaqBetaQ, l10n.landingFaqBetaA),
      _FaqItem(l10n.landingFaqBrowserQ, l10n.landingFaqBrowserA),
      _FaqItem(l10n.landingFaqBillingQ, l10n.landingFaqBillingA),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: const BoxDecoration(
        color: StitchM3Theme.bgSecondary,
      ),
      child: Column(
        children: [
          Text(
            l10n.landingFaqLabel.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: StitchM3Theme.accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.landingFaqTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: StitchM3Theme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: items
                  .map(
                    (item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                        side: BorderSide(color: theme.colorScheme.outline),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          item.question,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                item.answer,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem(this.question, this.answer);

  final String question;
  final String answer;
}
