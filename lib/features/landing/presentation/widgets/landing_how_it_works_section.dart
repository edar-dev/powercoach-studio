import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../landing_colors.dart';

/// Periodization / phase-planning banner (`#programmazione`).
class LandingHowItWorksSection extends StatelessWidget {
  const LandingHowItWorksSection({
    super.key,
    required this.l10n,
    this.onPrimary,
    this.onSecondary,
  });

  final AppLocalizations l10n;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      decoration: BoxDecoration(
        color: LandingColors.surfaceSubtle.withValues(alpha: 0.4),
        border: const Border.symmetric(
          vertical: BorderSide(color: LandingColors.border),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LandingColors.radius3xl),
            border: Border.all(color: LandingColors.border),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0D1322),
                Color(0xFF101B31),
                Color(0xFF0D1322),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFF1D4ED8).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  l10n.landingPhasesBadge.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: LandingColors.brandSoft,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.landingPhasesTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Text(
                  l10n.landingPhasesBody,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: LandingColors.slate300,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton(
                    onPressed: onPrimary,
                    style: FilledButton.styleFrom(
                      backgroundColor: LandingColors.brand,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(LandingColors.radiusXl),
                      ),
                    ),
                    child: Text(l10n.landingPhasesCtaPrimary),
                  ),
                  OutlinedButton(
                    onPressed: onSecondary,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: LandingColors.slate300,
                      side: const BorderSide(color: LandingColors.borderMuted),
                      backgroundColor:
                          const Color(0xFF1E293B).withValues(alpha: 0.8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(LandingColors.radiusXl),
                      ),
                    ),
                    child: Text(l10n.landingPhasesCtaSecondary),
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
