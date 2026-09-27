import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Dark marketing chrome shared by login, register, forgot, and check-email.
class AuthDarkFormShell extends StatelessWidget {
  const AuthDarkFormShell({
    super.key,
    required this.backLabel,
    required this.onBack,
    required this.topBadge,
    required this.child,
    this.maxCardWidth = MarketingDarkColors.authCardMaxWidthLogin,
    this.cardHeader,
    this.belowCard,
    this.pageFooter,
    this.centerBrand = true,
  });

  final String backLabel;
  final VoidCallback onBack;
  final Widget topBadge;
  final Widget child;
  final double maxCardWidth;
  final Widget? cardHeader;
  final Widget? belowCard;
  final Widget? pageFooter;

  /// When false, brand sits next to the back link (register layout).
  final bool centerBrand;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: MarketingDarkColors.bg,
        body: Stack(
          children: [
            const Positioned.fill(child: _AuthAmbientBackground()),
            SafeArea(
              child: Column(
                children: [
                  _AuthTopBar(
                    backLabel: backLabel,
                    onBack: onBack,
                    topBadge: topBadge,
                    centerBrand: centerBrand,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: maxCardWidth,
                              ),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: MarketingDarkColors.surfaceElevated
                                      .withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(
                                    MarketingDarkColors.radius2xl,
                                  ),
                                  border: Border.all(
                                    color: MarketingDarkColors.borderMuted
                                        .withValues(alpha: 0.6),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.55,
                                      ),
                                      blurRadius: 32,
                                      offset: const Offset(0, 16),
                                    ),
                                    BoxShadow(
                                      color: MarketingDarkColors.brand
                                          .withValues(alpha: 0.12),
                                      blurRadius: 40,
                                      spreadRadius: -8,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 28,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (cardHeader != null) ...[
                                        cardHeader!,
                                        const SizedBox(height: 20),
                                      ],
                                      child,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (belowCard != null) ...[
                            const SizedBox(height: 16),
                            belowCard!,
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (pageFooter != null) pageFooter!,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthAmbientBackground extends StatelessWidget {
  const _AuthAmbientBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AuthGridPainter(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.35),
            radius: 0.85,
            colors: [
              MarketingDarkColors.brand.withValues(alpha: 0.16),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.035)
      ..strokeWidth = 1;
    const step = 36.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AuthTopBar extends StatelessWidget {
  const _AuthTopBar({
    required this.backLabel,
    required this.onBack,
    required this.topBadge,
    required this.centerBrand,
  });

  final String backLabel;
  final VoidCallback onBack;
  final Widget topBadge;
  final bool centerBrand;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: MarketingDarkColors.bg.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: MarketingDarkColors.border.withValues(alpha: 0.8),
              ),
            ),
          ),
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: centerBrand
                  ? Row(
                      children: [
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _BackLink(
                              label: backLabel,
                              onTap: onBack,
                            ),
                          ),
                        ),
                        const _AuthBrandMark(),
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: topBadge,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        _BackLink(label: backLabel, onTap: onBack),
                        const SizedBox(width: 12),
                        Container(
                          width: 1,
                          height: 16,
                          color: MarketingDarkColors.border,
                        ),
                        const SizedBox(width: 12),
                        const Flexible(child: _AuthBrandMark()),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: topBadge,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackLink extends StatelessWidget {
  const _BackLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: MarketingDarkColors.surface800,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: MarketingDarkColors.borderMuted.withValues(alpha: 0.5),
                ),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 16,
                color: MarketingDarkColors.slate400,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: MarketingDarkColors.slate400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthBrandMark extends StatelessWidget {
  const _AuthBrandMark();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                MarketingDarkColors.brand,
                MarketingDarkColors.brandLight,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: MarketingDarkColors.brand.withValues(alpha: 0.3),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Icon(Icons.bolt, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: l10n.landingBrandPowerCoach,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: -0.2,
                  ),
                ),
                TextSpan(
                  text: ' ${l10n.landingBrandStudio}',
                  style: const TextStyle(
                    color: MarketingDarkColors.brandLight,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Emerald encryption / status pill used in login top bar.
class AuthEncryptionBadge extends StatelessWidget {
  const AuthEncryptionBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 600;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: MarketingDarkColors.emeraldBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: MarketingDarkColors.emeraldBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: MarketingDarkColors.emerald,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              wide
                  ? l10n.authEncryptionBadge
                  : l10n.authEncryptionBadgeShort,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: MarketingDarkColors.emerald,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact compliance footer for auth pages.
class AuthPageFooter extends StatelessWidget {
  const AuthPageFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: MarketingDarkColors.border.withValues(alpha: 0.6),
          ),
        ),
        color: MarketingDarkColors.bg.withValues(alpha: 0.6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          '${l10n.authFooterCompliance} · ${locale.languageCode.toUpperCase()}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: MarketingDarkColors.slate500,
          ),
        ),
      ),
    );
  }
}
