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
import '../widgets/auth_dark_text_field.dart';
import '../widgets/auth_social_buttons.dart';

/// Forgot Password — dark shell aligned with login/register.
/// Sends reset link via Supabase Auth resetPasswordForEmail.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await SupabaseBootstrap.ensureInitialized();
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
        redirectTo: AuthRedirectUrls.passwordRecovery,
      );

      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.forgotPasswordSuccessMessage,
            style: TextStyle(color: cs.onPrimaryContainer),
          ),
          backgroundColor: cs.primaryContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/login');
    } on AuthException catch (e) {
      await Sentry.captureException(e);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.forgotPasswordError,
            style: TextStyle(color: cs.onErrorContainer),
          ),
          backgroundColor: cs.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.forgotPasswordError,
            style: TextStyle(color: cs.onErrorContainer),
          ),
          backgroundColor: cs.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MarketingDarkColors.brand.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: MarketingDarkColors.brand.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.lock_reset,
              size: 28,
              color: MarketingDarkColors.brandLight,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.forgotPasswordTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.forgotPasswordInstruction,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: MarketingDarkColors.textMuted,
            ),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthDarkTextField(
              label: l10n.forgotPasswordEmailLabel,
              controller: _emailController,
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: (value) {
                final t = value?.trim() ?? '';
                if (t.isEmpty) return l10n.loginErrorInvalidEmail;
                if (!_emailRegex.hasMatch(t)) return l10n.loginErrorInvalidEmail;
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            AuthPrimaryCta(
              label: l10n.forgotPasswordSubmit,
              isLoading: _isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.go('/login');
              },
              style: TextButton.styleFrom(
                foregroundColor: MarketingDarkColors.brandLight,
              ),
              child: Text(l10n.forgotPasswordBackToLogin),
            ),
          ],
        ),
      ),
    );
  }
}
