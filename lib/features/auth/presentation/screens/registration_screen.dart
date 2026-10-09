import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/auth_dark_form_shell.dart';
import '../widgets/auth_social_buttons.dart';

/// Invite-only access info — public self-serve registration is not offered.
/// Route remains `/register` for bookmarks and login footer links.
class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AuthDarkFormShell(
      backLabel: l10n.authBackHome,
      onBack: () {
        HapticFeedback.mediumImpact();
        navigateTo(context, '/');
      },
      centerBrand: false,
      maxCardWidth: MarketingDarkColors.authCardMaxWidthRegister,
      topBadge: _InviteOnlyBadge(label: l10n.authInviteOnlyBadge),
      pageFooter: const AuthPageFooter(),
      cardHeader: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MarketingDarkColors.brandMid,
                  Color(0xFF1D4ED8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: MarketingDarkColors.brand.withValues(alpha: 0.25),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(Icons.mail_outline, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.authInviteOnlyHeadline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.authInviteOnlyBody,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: MarketingDarkColors.textMuted,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthPrimaryCta(
            label: l10n.authInviteOnlyLoginCta,
            onPressed: () {
              navigateTo(context, '/login');
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              navigateTo(context, '/');
            },
            style: TextButton.styleFrom(
              foregroundColor: MarketingDarkColors.slate400,
              padding: const EdgeInsets.symmetric(vertical: 8),
              minimumSize: const Size(0, 40),
            ),
            child: Text(l10n.authBackHome),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.authInviteOnlyProNote,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: MarketingDarkColors.slate500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteOnlyBadge extends StatelessWidget {
  const _InviteOnlyBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: MarketingDarkColors.brand.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: MarketingDarkColors.brand.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: MarketingDarkColors.brandLight,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: MarketingDarkColors.brandLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
