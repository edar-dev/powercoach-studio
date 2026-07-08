import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

/// Hero block on the landing page (badge, title, CTAs).
class LandingHeroSection extends StatelessWidget {
  const LandingHeroSection({
    super.key,
    required this.heroBadge,
    required this.titlePrefix,
    required this.titleSuffix,
    required this.subtitle,
    required this.ctaPrimary,
    required this.ctaSecondary,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String heroBadge;
  final String titlePrefix;
  final String titleSuffix;
  final String subtitle;
  final String ctaPrimary;
  final String ctaSecondary;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [StitchM3Theme.accentLight, StitchM3Theme.bg],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: StitchM3Theme.bg,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: StitchM3Theme.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: StitchM3Theme.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        heroBadge,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: StitchM3Theme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                titlePrefix,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: StitchM3Theme.textPrimary,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              Text(
                titleSuffix,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: StitchM3Theme.accent,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                subtitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: StitchM3Theme.textMuted,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    onPressed: onPrimary,
                    style: FilledButton.styleFrom(
                      backgroundColor: StitchM3Theme.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      minimumSize: const Size(44, 44),
                      textStyle: theme.textTheme.titleMedium,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                      ),
                    ),
                    child: Text(ctaPrimary),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: onSecondary,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: StitchM3Theme.accent,
                      side: const BorderSide(color: StitchM3Theme.border),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      minimumSize: const Size(44, 44),
                      textStyle: theme.textTheme.titleMedium,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                      ),
                    ),
                    child: Text(ctaSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
