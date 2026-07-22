import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/auth/auth_redirect_urls.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/ui/widgets/stitch_secondary_app_bar.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../l10n/app_localizations.dart';

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerHighest,
      appBar: StitchSecondaryAppBar(title: l10n.registrationCheckEmailTitle),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: StitchM3Theme.authCardMaxWidth,
              ),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                border: Border.all(color: cs.outline),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.mark_email_unread_outlined, size: 48, color: cs.primary),
                  const SizedBox(height: 16),
                  Text(
                    l10n.registrationCheckEmailTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.registrationCheckEmailBody(widget.email),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.registrationCheckEmailSpamHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isResending ? null : _resend,
                    style: FilledButton.styleFrom(
                      backgroundColor: StitchM3Theme.accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, StitchM3Theme.inputHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          StitchM3Theme.radiusMd,
                        ),
                      ),
                    ),
                    child: _isResending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.registrationResendEmail),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      context.go('/login');
                    },
                    child: Text(l10n.registrationGoToLogin),
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
