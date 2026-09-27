import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/auth/auth_redirect_urls.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../widgets/auth_dark_form_shell.dart';
import '../widgets/auth_social_buttons.dart';

/// Shown after sign-up when email confirmation is required before first login.
class RegistrationCheckEmailScreen extends StatefulWidget {
  const RegistrationCheckEmailScreen({super.key, required this.email});

  final String email;

  @override
  State<RegistrationCheckEmailScreen> createState() =>
      _RegistrationCheckEmailScreenState();
}

class _RegistrationCheckEmailScreenState
    extends State<RegistrationCheckEmailScreen> {
  bool _isResending = false;

  Future<void> _resend() async {
    await SupabaseBootstrap.ensureInitialized();
    if (!mounted) return;

    setState(() => _isResending = true);
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
        emailRedirectTo: AuthRedirectUrls.emailConfirmation,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.registrationResendEmailSuccess),
          backgroundColor: cs.primaryContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on AuthException catch (e) {
      await Sentry.captureException(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.registrationResendEmailError),
          backgroundColor: cs.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.registrationResendEmailError),
          backgroundColor: cs.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AuthDarkFormShell(
      backLabel: l10n.authBackLogin,
      onBack: () {
        HapticFeedback.mediumImpact();
        context.go('/login');
      },
      topBadge: const AuthEncryptionBadge(),
      pageFooter: const AuthPageFooter(),
      cardHeader: Column(
        children: [
          const Icon(
            Icons.mark_email_unread_outlined,
            size: 48,
            color: MarketingDarkColors.brandLight,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.registrationCheckEmailTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.registrationCheckEmailBody(widget.email),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: MarketingDarkColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.registrationCheckEmailSpamHint,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: MarketingDarkColors.slate500,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthPrimaryCta(
            label: l10n.registrationResendEmail,
            isLoading: _isResending,
            onPressed: _resend,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.go('/login');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: MarketingDarkColors.slate300,
              side: BorderSide(
                color: MarketingDarkColors.borderMuted.withValues(alpha: 0.8),
              ),
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(MarketingDarkColors.radiusXl),
              ),
            ),
            child: Text(l10n.registrationGoToLogin),
          ),
        ],
      ),
    );
  }
}
