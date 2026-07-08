import 'package:flutter/material.dart';

import '../../../../core/ui/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'landing_step_item.dart';

/// "How it works" steps on the landing page.
class LandingHowItWorksSection extends StatelessWidget {
  const LandingHowItWorksSection({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final steps = [
      l10n.landingHowItWorksStep1,
      l10n.landingHowItWorksStep2,
      l10n.landingHowItWorksStep3,
      l10n.landingHowItWorksStep4,
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
            l10n.landingHowItWorksLabel.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: StitchM3Theme.accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.landingHowItWorksTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: StitchM3Theme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > AppBreakpoints.tablet;
              return isWide
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        4,
                        (i) => LandingStepItem(
                          step: steps[i],
                          number: i + 1,
                          colorScheme: colorScheme,
                          theme: theme,
                        ),
                      ),
                    )
                  : Column(
                      children: List.generate(
                        4,
                        (i) => LandingStepItem(
                          step: steps[i],
                          number: i + 1,
                          colorScheme: colorScheme,
                          theme: theme,
                        ),
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }
}
