import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

/// Bottom call-to-action block on the landing page.
class LandingCtaSection extends StatelessWidget {
  const LandingCtaSection({
    super.key,
    required this.title,
    required this.subtext,
    required this.buttonLabel,
    required this.onCta,
  });

  final String title;
  final String subtext;
  final String buttonLabel;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: StitchM3Theme.accent,
          borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: StitchM3Theme.accent.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtext,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onCta,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: StitchM3Theme.accent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  minimumSize: const Size(44, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: Text(buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
