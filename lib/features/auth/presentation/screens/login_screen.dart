import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/analytics/product_analytics.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/billing/entitlement_repository.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/routing/route_redirect.dart';
import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../utils/auth_error_message.dart';
import '../widgets/auth_dark_form_shell.dart';
import '../widgets/auth_dark_text_field.dart';
import '../widgets/auth_social_buttons.dart';

/// Login — dark Stitch parity (`design/stitch-assets/auth/login-dark`).
/// Uses Supabase Auth [signInWithPassword].
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _staySignedIn = true;
  bool _coachRole = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  void _onSelectAthlete() {
    setState(() => _coachRole = false);
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.loginAthleteUnavailable),
        behavior: SnackBarBehavior.floating,
      ),
    );
    // Revert selection — product is coach-only.
    Future<void>.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _coachRole = true);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await SupabaseBootstrap.ensureInitialized();
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      ProductAnalytics.loginCompleted();
      await EntitlementRepository.instance.refresh();

      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.loginSuccessMessage,
            style: TextStyle(color: colorScheme.onPrimaryContainer),
          ),
          backgroundColor: colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
      final redirect = safePostLoginRedirect(
        GoRouterState.of(context).uri.queryParameters['redirect'],
      );
      context.go(redirect ?? '/dashboard');
    } on AuthException catch (e) {
      await Sentry.captureException(e);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authErrorMessage(e, l10n),
            style: TextStyle(color: colorScheme.onErrorContainer),
          ),
          backgroundColor: colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.loginErrorGeneric,
            style: TextStyle(color: colorScheme.onErrorContainer),
          ),
          backgroundColor: colorScheme.errorContainer,
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
      backLabel: l10n.authBackHome,
      onBack: () {
        HapticFeedback.mediumImpact();
        navigateTo(context, '/');
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
              Icons.bolt,
              size: 28,
              color: MarketingDarkColors.brandLight,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.loginHeadline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.loginSubtitle,
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
            _RoleSegment(
              coachSelected: _coachRole,
              coachLabel: l10n.loginRoleCoach,
              athleteLabel: l10n.loginRoleAthlete,
              onCoach: () => setState(() => _coachRole = true),
              onAthlete: _onSelectAthlete,
            ),
            const SizedBox(height: 20),
            AuthDarkTextField(
              label: l10n.loginEmail,
              controller: _emailController,
              hint: l10n.loginEmailHint,
              prefixIcon: Icons.person_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username, AutofillHints.email],
              validator: (value) {
                final t = value?.trim() ?? '';
                if (t.isEmpty) return l10n.loginErrorInvalidEmail;
                if (!_emailRegex.hasMatch(t)) return l10n.loginErrorInvalidEmail;
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.loginPassword.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: MarketingDarkColors.slate300,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    navigateTo(context, '/forgot-password');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: MarketingDarkColors.brandLight,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n.loginForgotPassword,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            AuthDarkTextField(
              label: '', // label rendered above with forgot link
              controller: _passwordController,
              obscureText: _obscurePassword,
              onToggleObscure: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              prefixIcon: Icons.lock_outline,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.loginErrorPasswordEmpty;
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(
                    value: _staySignedIn,
                    onChanged: (v) =>
                        setState(() => _staySignedIn = v ?? true),
                    activeColor: MarketingDarkColors.brand,
                    side: const BorderSide(color: MarketingDarkColors.borderMuted),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _staySignedIn = !_staySignedIn),
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          color: MarketingDarkColors.slate300,
                        ),
                        children: [
                          TextSpan(text: l10n.loginStaySignedIn),
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: l10n.loginStaySignedInOffline,
                            style: const TextStyle(
                              color: MarketingDarkColors.brandLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AuthPrimaryCta(
              label: l10n.loginSubmit,
              isLoading: _isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 24),
            AuthSocialButtons(dividerLabel: l10n.loginOrContinueWith),
            const SizedBox(height: 24),
            Divider(
              color: MarketingDarkColors.border.withValues(alpha: 0.9),
              height: 1,
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 6,
              children: [
                Text(
                  l10n.loginNoAccount,
                  style: const TextStyle(
                    fontSize: 12,
                    color: MarketingDarkColors.textMuted,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    navigateTo(context, '/register');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: MarketingDarkColors.brandLight,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n.loginRegisterLink,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: MarketingDarkColors.brand.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: MarketingDarkColors.brand.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    l10n.loginTrialChip,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: MarketingDarkColors.brandLight,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleSegment extends StatelessWidget {
  const _RoleSegment({
    required this.coachSelected,
    required this.coachLabel,
    required this.athleteLabel,
    required this.onCoach,
    required this.onAthlete,
  });

  final bool coachSelected;
  final String coachLabel;
  final String athleteLabel;
  final VoidCallback onCoach;
  final VoidCallback onAthlete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: MarketingDarkColors.bg.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MarketingDarkColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RoleChip(
              label: coachLabel,
              selected: coachSelected,
              onTap: onCoach,
            ),
          ),
          Expanded(
            child: _RoleChip(
              label: athleteLabel,
              selected: !coachSelected,
              onTap: onAthlete,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? MarketingDarkColors.brand : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : MarketingDarkColors.slate400,
            ),
          ),
        ),
      ),
    );
  }
}
