import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/ui/breakpoints.dart';
import '../../../../l10n/app_localizations.dart';
import '../landing_colors.dart';

/// Sticky translucent header matching Stitch landing dark theme (h-20).
class LandingScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LandingScreenAppBar({
    super.key,
    required this.isLoggedIn,
    this.onScrollToFeatures,
    this.onScrollToLibrary,
    this.onScrollToPhases,
    this.onScrollToPricing,
  });

  final bool isLoggedIn;
  final VoidCallback? onScrollToFeatures;
  final VoidCallback? onScrollToLibrary;
  final VoidCallback? onScrollToPhases;
  final VoidCallback? onScrollToPricing;

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final wide = AppBreakpoints.isTabletOrWider(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Material(
        color: LandingColors.bg.withValues(alpha: 0.8),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: LandingColors.bg.withValues(alpha: 0.8),
                border: Border(
                  bottom: BorderSide(
                    color: LandingColors.border.withValues(alpha: 0.8),
                  ),
                ),
              ),
              child: SizedBox(
                  height: 80,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _BrandMark(l10n: l10n, theme: theme),
                        if (wide) ...[
                          const SizedBox(width: 16),
                          Expanded(
                            child: Center(
                              child: _PillNav(
                                l10n: l10n,
                                onFeatures: onScrollToFeatures,
                                onLibrary: onScrollToLibrary,
                                onPhases: onScrollToPhases,
                                onPricing: onScrollToPricing,
                              ),
                            ),
                          ),
                        ] else
                          const Spacer(),
                        _RightActions(
                          l10n: l10n,
                          theme: theme,
                          isLoggedIn: isLoggedIn,
                          showStatusChip: wide,
                        ),
                      ],
                    ),
                  ),
                ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Color(0xFF1D4ED8),
                LandingColors.brand,
                Color(0xFF22D3EE),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: LandingColors.brand.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(1),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: LandingColors.surfaceElevated,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.bolt,
              size: 20,
              color: LandingColors.brandLight,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: l10n.landingBrandPowerCoach,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              TextSpan(
                text: ' ${l10n.landingBrandStudio}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: LandingColors.brandLight,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PillNav extends StatelessWidget {
  const _PillNav({
    required this.l10n,
    this.onFeatures,
    this.onLibrary,
    this.onPhases,
    this.onPricing,
  });

  final AppLocalizations l10n;
  final VoidCallback? onFeatures;
  final VoidCallback? onLibrary;
  final VoidCallback? onPhases;
  final VoidCallback? onPricing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: LandingColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: LandingColors.border.withValues(alpha: 0.9),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NavChip(label: l10n.landingNavFeatures, onTap: onFeatures),
          _NavChip(label: l10n.landingNavLibrary, onTap: onLibrary),
          _NavChip(label: l10n.landingNavPhases, onTap: onPhases),
          _NavChip(label: l10n.landingNavPricing, onTap: onPricing),
        ],
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  const _NavChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap!();
            },
      style: TextButton.styleFrom(
        foregroundColor: LandingColors.slate300,
        disabledForegroundColor: LandingColors.textDim,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        minimumSize: const Size(44, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _RightActions extends StatelessWidget {
  const _RightActions({
    required this.l10n,
    required this.theme,
    required this.isLoggedIn,
    required this.showStatusChip,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final bool isLoggedIn;
  final bool showStatusChip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showStatusChip) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: LandingColors.emeraldBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: LandingColors.emeraldBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: LandingColors.emerald,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.landingStatusOfflineFirst,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: LandingColors.emerald,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
        if (isLoggedIn) ...[
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              navigateTo(context, '/customers');
            },
            style: TextButton.styleFrom(
              foregroundColor: LandingColors.slate300,
            ),
            child: Text(l10n.customersTitle),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              navigateTo(context, '/profile');
            },
            style: TextButton.styleFrom(
              foregroundColor: LandingColors.slate300,
            ),
            child: Text(l10n.headerProfile),
          ),
          const SizedBox(width: 4),
          FilledButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              navigateTo(context, '/dashboard');
            },
            style: FilledButton.styleFrom(
              backgroundColor: LandingColors.brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LandingColors.radiusXl),
              ),
            ),
            child: Text(l10n.dashboardTitle),
          ),
        ] else ...[
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              navigateTo(context, '/login');
            },
            style: TextButton.styleFrom(
              foregroundColor: LandingColors.slate300,
            ),
            child: Text(l10n.headerLogin),
          ),
          const SizedBox(width: 4),
          FilledButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              navigateTo(context, '/register');
            },
            style: FilledButton.styleFrom(
              backgroundColor: LandingColors.brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LandingColors.radiusXl),
              ),
              elevation: 0,
              shadowColor: LandingColors.brand.withValues(alpha: 0.3),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.landingCtaStartFree),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 16),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
