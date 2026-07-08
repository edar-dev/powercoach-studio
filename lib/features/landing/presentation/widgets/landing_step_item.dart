import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';

/// Single numbered step in the landing "how it works" section.
class LandingStepItem extends StatelessWidget {
  const LandingStepItem({
    super.key,
    required this.step,
    required this.number,
    required this.colorScheme,
    required this.theme,
  });

  final String step;
  final int number;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            child: Text(
              '$number',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 200,
            child: Text(
              step,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: StitchM3Theme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
