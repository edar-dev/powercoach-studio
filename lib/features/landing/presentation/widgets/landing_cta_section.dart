import 'package:flutter/material.dart';

import '../landing_colors.dart';

/// Bottom call-to-action block matching Stitch dark landing.
class LandingCtaSection extends StatelessWidget {
  const LandingCtaSection({
    super.key,
    required this.title,
    required this.subtext,
    required this.buttonLabel,
    required this.onCta,
    this.footnote,
  });

  final String title;
  final String subtext;
  final String buttonLabel;
  final VoidCallback onCta;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(LandingColors.radius3xl),
              border: Border.all(
                color: LandingColors.brandMid.withValues(alpha: 0.3),
              ),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF10192E), Color(0xFF0A0F1D)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: LandingColors.brand.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(LandingColors.radius2xl),
                    border: Border.all(
                      color: LandingColors.brandMid.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Icon(
                    Icons.bolt,
                    size: 32,
                    color: LandingColors.brandLight,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Text(
                    subtext,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: LandingColors.slate300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: onCta,
                  style: FilledButton.styleFrom(
                    backgroundColor: LandingColors.brand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 18,
                    ),
                    minimumSize: const Size(44, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(LandingColors.radiusXl),
                    ),
                  ),
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (footnote != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    footnote!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: LandingColors.textMuted,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
