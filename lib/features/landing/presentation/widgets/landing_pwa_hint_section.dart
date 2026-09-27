import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../landing_colors.dart';

/// Web-only hint for installing the PWA / Add to Home Screen.
class LandingPwaHintSection extends StatelessWidget {
  const LandingPwaHintSection({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: LandingColors.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(LandingColors.radius2xl),
          border: Border.all(color: LandingColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.install_mobile,
              color: LandingColors.brandLight,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.landingPwaTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.landingPwaMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: LandingColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
