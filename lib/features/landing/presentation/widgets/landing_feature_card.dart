import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

/// Single feature card on the landing page.
class LandingFeatureCard extends StatelessWidget {
  const LandingFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Container(
        decoration: BoxDecoration(
          color: StitchM3Theme.bg,
          borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
          border: Border.all(color: StitchM3Theme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: StitchM3Theme.accentLight,
                  borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                ),
                child: Icon(icon, size: 28, color: StitchM3Theme.accent),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: StitchM3Theme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: StitchM3Theme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
