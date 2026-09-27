import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Primary blue CTA with trailing arrow (Stitch auth).
class AuthPrimaryCta extends StatelessWidget {
  const AuthPrimaryCta({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
          gradient: const LinearGradient(
            colors: [
              MarketingDarkColors.brand,
              MarketingDarkColors.brandMid,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: MarketingDarkColors.brand.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading || onPressed == null
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    onPressed!();
                  },
            borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Colors.white,
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

/// Google / Apple buttons — visual only; shows unavailable snackbar.
class AuthSocialButtons extends StatelessWidget {
  const AuthSocialButtons({
    super.key,
    required this.dividerLabel,
  });

  final String dividerLabel;

  void _showUnavailable(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.authSocialUnavailable),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Divider(color: MarketingDarkColors.border, height: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                dividerLabel.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: MarketingDarkColors.slate500,
                ),
              ),
            ),
            const Expanded(
              child: Divider(color: MarketingDarkColors.border, height: 1),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                label: l10nGoogle,
                leading: const _GoogleMark(),
                onTap: () => _showUnavailable(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SocialButton(
                label: l10nApple,
                leading: const Icon(
                  Icons.apple,
                  size: 18,
                  color: Colors.white,
                ),
                onTap: () => _showUnavailable(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const l10nGoogle = 'Google';
const l10nApple = 'Apple';

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.leading,
    required this.onTap,
  });

  final String label;
  final Widget leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MarketingDarkColors.surface800.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
            border: Border.all(
              color: MarketingDarkColors.borderMuted.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              leading,
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: MarketingDarkColors.slate300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      height: 16,
      child: ColoredBox(
        color: Colors.transparent,
        child: Icon(Icons.g_mobiledata, size: 20, color: Color(0xFF4285F4)),
      ),
    );
  }
}
