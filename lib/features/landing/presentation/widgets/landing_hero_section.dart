import 'package:flutter/material.dart';

import '../landing_colors.dart';
import 'landing_app_preview.dart';

/// Hero block matching Stitch dark landing first viewport.
class LandingHeroSection extends StatelessWidget {
  const LandingHeroSection({
    super.key,
    required this.earlyAccessLabel,
    required this.betaVersionLabel,
    required this.titlePrefix,
    required this.titleSuffix,
    required this.leadBefore,
    required this.leadEmphasis,
    required this.leadAfter,
    required this.supporting,
    required this.ctaPrimary,
    required this.ctaSecondary,
    required this.trustExercises,
    required this.trustOffline,
    required this.trustExport,
    required this.previewEditorLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String earlyAccessLabel;
  final String betaVersionLabel;
  final String titlePrefix;
  final String titleSuffix;
  final String leadBefore;
  final String leadEmphasis;
  final String leadAfter;
  final String supporting;
  final String ctaPrimary;
  final String ctaSecondary;
  final String trustExercises;
  final String trustOffline;
  final String trustExport;
  final String previewEditorLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = width >= 900
        ? 64.0
        : width >= 600
            ? 52.0
            : 36.0;

    return Container(
      width: double.infinity,
      color: LandingColors.bg,
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      LandingColors.brand.withValues(alpha: 0.18),
                      LandingColors.bg.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
              child: Column(
                children: [
                  _AnnouncementPill(
                    earlyAccess: earlyAccessLabel,
                    betaVersion: betaVersionLabel,
                    theme: theme,
                  ),
                  const SizedBox(height: 28),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Column(
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '$titlePrefix ',
                                style: theme.textTheme.displayMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: titleSize,
                                  height: 1.08,
                                  letterSpacing: -1,
                                ),
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [
                                      Color(0xFF60A5FA),
                                      Color(0xFF3B82F6),
                                      Color(0xFF818CF8),
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    titleSuffix,
                                    style:
                                        theme.textTheme.displayMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: titleSize,
                                      height: 1.08,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text.rich(
                          TextSpan(
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: LandingColors.slate300,
                              fontWeight: FontWeight.w400,
                              height: 1.45,
                            ),
                            children: [
                              TextSpan(text: leadBefore),
                              TextSpan(
                                text: leadEmphasis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(text: leadAfter),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: Text(
                            supporting,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: LandingColors.textMuted,
                              height: 1.45,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 14,
                          runSpacing: 12,
                          children: [
                            FilledButton(
                              onPressed: onPrimary,
                              style: FilledButton.styleFrom(
                                backgroundColor: LandingColors.brand,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 18,
                                ),
                                minimumSize: const Size(44, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    LandingColors.radiusXl,
                                  ),
                                ),
                                elevation: 0,
                                shadowColor: LandingColors.brand.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    ctaPrimary,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              onPressed: onSecondary,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: LandingColors.slate300,
                                backgroundColor: LandingColors.surface,
                                side: BorderSide(
                                  color: LandingColors.borderMuted.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 18,
                                ),
                                minimumSize: const Size(44, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    LandingColors.radiusXl,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.play_circle_outline,
                                    size: 18,
                                    color: LandingColors.brandLight,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    ctaSecondary,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: LandingColors.slate300,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 36),
                        Divider(
                          color: LandingColors.border.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 28,
                          runSpacing: 12,
                          children: [
                            _TrustItem(label: trustExercises),
                            _TrustItem(label: trustOffline),
                            _TrustItem(label: trustExport),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  LandingAppPreview(editorLabel: previewEditorLabel),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementPill extends StatelessWidget {
  const _AnnouncementPill({
    required this.earlyAccess,
    required this.betaVersion,
    required this.theme,
  });

  final String earlyAccess;
  final String betaVersion;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: LandingColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: LandingColors.brandMid.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: LandingColors.brandLight.withValues(alpha: 0.35),
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: LandingColors.brandMid,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            earlyAccess,
            style: theme.textTheme.labelLarge?.copyWith(
              color: LandingColors.brandSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '|',
              style: theme.textTheme.labelLarge?.copyWith(
                color: LandingColors.textDim,
              ),
            ),
          ),
          Text(
            betaVersion,
            style: theme.textTheme.labelLarge?.copyWith(
              color: LandingColors.slate300,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.open_in_new,
            size: 14,
            color: LandingColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, size: 16, color: LandingColors.brandLight),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: LandingColors.textMuted,
          ),
        ),
      ],
    );
  }
}
