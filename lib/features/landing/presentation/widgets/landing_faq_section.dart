import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../landing_colors.dart';

/// FAQ accordion for the public landing page (dark chrome).
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      color: LandingColors.bgDeep,
      child: Column(
        children: [
          Text(
            l10n.landingFaqLabel.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: LandingColors.brandLight,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.landingFaqTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: LandingColors.surface.withValues(alpha: 0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(LandingColors.radiusXl),
                          side: const BorderSide(color: LandingColors.border),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Theme(
                          data: theme.copyWith(
                            dividerColor: Colors.transparent,
                            expansionTileTheme: const ExpansionTileThemeData(
                              iconColor: LandingColors.brandLight,
                              collapsedIconColor: LandingColors.textMuted,
                            ),
                          ),
                          child: ExpansionTile(
                            title: Text(
                              item.question,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
                                      color: LandingColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
