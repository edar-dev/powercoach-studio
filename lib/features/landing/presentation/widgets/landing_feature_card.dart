import 'package:flutter/material.dart';

import '../landing_colors.dart';

/// Rich feature card for the dark landing features grid.
class LandingFeatureCard extends StatelessWidget {
  const LandingFeatureCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.iconBorder,
    required this.title,
    required this.eyebrow,
    required this.body,
    required this.bullets,
    required this.footerLeft,
    required this.footerRight,
    this.bulletColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color iconBorder;
  final String title;
  final String eyebrow;
  final String body;
  final List<String> bullets;
  final String footerLeft;
  final String footerRight;
  final Color? bulletColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dot = bulletColor ?? LandingColors.brandLight;

    return Container(
      constraints: const BoxConstraints(minHeight: 280),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: LandingColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(LandingColors.radius2xl),
        border: Border.all(color: LandingColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(LandingColors.radiusXl),
              border: Border.all(color: iconBorder),
            ),
            child: Icon(icon, size: 28, color: iconColor),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            eyebrow,
            style: theme.textTheme.labelLarge?.copyWith(
              color: LandingColors.brandLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: LandingColors.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          for (final bullet in bullets) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: dot,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    bullet,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: LandingColors.slate300,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
          Divider(color: LandingColors.border.withValues(alpha: 0.8)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  footerLeft,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: LandingColors.textMuted,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              Text(
                footerRight,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w700,
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
