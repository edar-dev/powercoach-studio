import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/auth/auth_redirect_urls.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/ui/widgets/stitch_secondary_app_bar.dart';

/// Forgot Password – Stitch ID 3563377ad3864dfca42385fcd5ea0840.
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerHighest,
      appBar: StitchSecondaryAppBar(title: l10n.forgotPasswordTitle),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: StitchM3Theme.authCardMaxWidth),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                border: Border.all(color: cs.outline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: StitchM3Theme.authHeaderPadding,
                      child: Column(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: StitchM3Theme.accent,
                              borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                            ),
                            child: const Icon(Icons.lock_reset, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'PowerCoach Studio',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: StitchM3Theme.authCardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.forgotPasswordInstruction,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: l10n.forgotPasswordEmailLabel,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            validator: (value) {
                              final t = value?.trim() ?? '';
                              if (t.isEmpty) return l10n.loginErrorInvalidEmail;
                              if (!_emailRegex.hasMatch(t)) return l10n.loginErrorInvalidEmail;
                              return null;
                            },
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: StitchM3Theme.inputHeight,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: StitchM3Theme.accent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(l10n.forgotPasswordSubmit),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              context.go('/login');
                            },
                            child: Text(l10n.forgotPasswordBackToLogin),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
