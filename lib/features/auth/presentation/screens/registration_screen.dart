import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/analytics/product_analytics.dart';
import 'package:powercoach_studio/core/auth/auth_redirect_urls.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/billing/entitlement_repository.dart';
import 'package:powercoach_studio/core/constants/legal_urls.dart';
import 'package:powercoach_studio/core/platform/open_external_url.dart';
import 'package:powercoach_studio/core/routing/app_navigation.dart';
import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/local_coach_profile_repository.dart';
import '../../utils/auth_error_message.dart';
import '../../utils/registration_password_rules.dart';
import '../widgets/auth_dark_form_shell.dart';
import '../widgets/auth_dark_text_field.dart';
import '../widgets/auth_social_buttons.dart';

/// Registration — dark Stitch parity (`design/stitch-assets/auth/register-dark`).
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

enum _Specialty { pt, athleticPrep, powerlifting }

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _acceptedTerms = false;
  _Specialty _specialty = _Specialty.pt;
  int _passwordScore = 0;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => openExternalUrl(LegalUrls.termsOfService);
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => openExternalUrl(LegalUrls.privacyPolicy);
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  Future<void> _persistDisplayNameIfSession(Session? session) async {
    final userId = session?.user.id;
    if (userId == null || userId.isEmpty) return;
    final displayName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
            .trim();
    if (displayName.isEmpty) return;
    try {
      final repo = LocalCoachProfileRepository.instance;
      final existing = await repo.getProfile(userId);
      await repo.saveProfile(
        userId,
        LocalUserProfileData(
          displayName: displayName,
          phone: existing.phone,
          bio: existing.bio,
          avatarUrl: existing.avatarUrl,
          website: existing.website,
          subscriptionPlan: existing.subscriptionPlan,
        ),
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.registrationAcceptTermsError),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await SupabaseBootstrap.ensureInitialized();
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: _passwordController.text,
        emailRedirectTo: AuthRedirectUrls.emailConfirmation,
      );

      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final colorScheme = Theme.of(context).colorScheme;

      if (response.session != null) {
        await _persistDisplayNameIfSession(response.session);
        ProductAnalytics.signupCompleted();
        await EntitlementRepository.instance.refresh();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.registrationSuccessReady,
              style: TextStyle(color: colorScheme.onPrimaryContainer),
            ),
            backgroundColor: colorScheme.primaryContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/dashboard');
        return;
      }

      context.go(
        '/register/check-email?email=${Uri.encodeComponent(email)}',
      );
    } on AuthException catch (e) {
      await Sentry.captureException(e);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            registrationErrorMessage(e, l10n),
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
            l10n.registrationErrorGeneric,
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

  String _strengthLabel(AppLocalizations l10n) {
    return switch (_passwordScore) {
      0 || 1 => l10n.registrationPasswordStrengthWeak,
      2 => l10n.registrationPasswordStrengthFair,
      3 => l10n.registrationPasswordStrengthGood,
      _ => l10n.registrationPasswordStrengthStrong,
    };
  }

  Color _strengthColor() {
    return switch (_passwordScore) {
      0 || 1 => const Color(0xFFF87171),
      2 => const Color(0xFFFBBF24),
      3 => MarketingDarkColors.emerald,
      _ => MarketingDarkColors.emerald,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AuthDarkFormShell(
      backLabel: l10n.authBackLogin,
      onBack: () {
        HapticFeedback.mediumImpact();
        navigateTo(context, '/login');
      },
      centerBrand: false,
      maxCardWidth: MarketingDarkColors.authCardMaxWidthRegister,
      topBadge: _TrialBadge(label: l10n.registrationTrialBadge),
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
            child: const Icon(Icons.bolt, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.registrationEyebrow.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: MarketingDarkColors.brandLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.registrationHeadline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.registrationSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: MarketingDarkColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _TrustChip(label: l10n.registrationTrustExercises),
              _TrustChip(label: l10n.registrationTrustOffline),
              _TrustChip(label: l10n.registrationTrustMesocycles),
            ],
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 420;
                final first = AuthDarkTextField(
                  label: l10n.registrationFirstName,
                  controller: _firstNameController,
                  hint: l10n.registrationFirstNameHint,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.givenName],
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) {
                      return l10n.registrationErrorNameEmpty;
                    }
                    return null;
                  },
                );
                final last = AuthDarkTextField(
                  label: l10n.registrationLastName,
                  controller: _lastNameController,
                  hint: l10n.registrationLastNameHint,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.familyName],
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) {
                      return l10n.registrationErrorNameEmpty;
                    }
                    return null;
                  },
                );
                if (!wide) {
                  return Column(
                    children: [
                      first,
                      const SizedBox(height: 14),
                      last,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: first),
                    const SizedBox(width: 12),
                    Expanded(child: last),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            Text(
              l10n.registrationSpecialty.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: MarketingDarkColors.slate300,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _SpecialtyChip(
                    label: l10n.registrationSpecialtyPt,
                    selected: _specialty == _Specialty.pt,
                    onTap: () => setState(() => _specialty = _Specialty.pt),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SpecialtyChip(
                    label: l10n.registrationSpecialtyAthletic,
                    selected: _specialty == _Specialty.athleticPrep,
                    onTap: () =>
                        setState(() => _specialty = _Specialty.athleticPrep),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SpecialtyChip(
                    label: l10n.registrationSpecialtyPowerlifting,
                    selected: _specialty == _Specialty.powerlifting,
                    onTap: () =>
                        setState(() => _specialty = _Specialty.powerlifting),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AuthDarkTextField(
              label: l10n.registrationEmail,
              controller: _emailController,
              hint: l10n.registrationEmailHint,
              prefixIcon: Icons.person_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (value) {
                final t = value?.trim() ?? '';
                if (t.isEmpty || !_emailRegex.hasMatch(t)) {
                  return l10n.registrationErrorInvalidEmail;
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            AuthDarkTextField(
              label: l10n.registrationPassword,
              controller: _passwordController,
              obscureText: _obscurePassword,
              onToggleObscure: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              onChanged: (v) => setState(
                () => _passwordScore =
                    RegistrationPasswordRules.strengthScore(v),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.registrationErrorPasswordEmpty;
                }
                if (!RegistrationPasswordRules.isValid(value)) {
                  return l10n.registrationErrorPasswordWeak;
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            _PasswordMeter(
              score: _passwordScore,
              label: _strengthLabel(l10n),
              color: _strengthColor(),
              hint: l10n.registrationPasswordRulesHint,
            ),
            const SizedBox(height: 14),
            AuthDarkTextField(
              label: l10n.registrationConfirmPassword,
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              onToggleObscure: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              validator: (value) {
                if (value != _passwordController.text) {
                  return l10n.registrationErrorPasswordMismatch;
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(
                    value: _acceptedTerms,
                    onChanged: (v) =>
                        setState(() => _acceptedTerms = v ?? false),
                    activeColor: MarketingDarkColors.brand,
                    side: const BorderSide(
                      color: MarketingDarkColors.borderMuted,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: MarketingDarkColors.textMuted,
                      ),
                      children: [
                        TextSpan(text: '${l10n.registrationTermsPrefix} '),
                        TextSpan(
                          text: l10n.registrationTermsOfService,
                          style: const TextStyle(
                            color: MarketingDarkColors.brandLight,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: _termsRecognizer,
                        ),
                        TextSpan(text: ' ${l10n.registrationTermsMiddle} '),
                        TextSpan(
                          text: l10n.registrationPrivacyPolicy,
                          style: const TextStyle(
                            color: MarketingDarkColors.brandLight,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: _privacyRecognizer,
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AuthPrimaryCta(
              label: l10n.registrationSubmit,
              isLoading: _isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 20),
            AuthSocialButtons(dividerLabel: l10n.registrationOrContinueWith),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.registrationAlreadyHaveAccount,
                  style: const TextStyle(
                    fontSize: 12,
                    color: MarketingDarkColors.textMuted,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    navigateTo(context, '/login');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: MarketingDarkColors.brandLight,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n.registrationLoginLink,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
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

class _TrialBadge extends StatelessWidget {
  const _TrialBadge({required this.label});

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
          Expanded(
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

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: MarketingDarkColors.surface800.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: MarketingDarkColors.borderMuted.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check,
            size: 14,
            color: MarketingDarkColors.emerald,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: MarketingDarkColors.slate300,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  const _SpecialtyChip({
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
      color: selected
          ? MarketingDarkColors.brand.withValues(alpha: 0.15)
          : MarketingDarkColors.surfaceInput.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
            border: Border.all(
              color: selected
                  ? MarketingDarkColors.brandMid
                  : MarketingDarkColors.borderSubtle,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: selected
                  ? MarketingDarkColors.brandSoft
                  : MarketingDarkColors.slate400,
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordMeter extends StatelessWidget {
  const _PasswordMeter({
    required this.score,
    required this.label,
    required this.color,
    required this.hint,
  });

  final int score;
  final String label;
  final Color color;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          children: List.generate(4, (i) {
            final active = i < score;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                decoration: BoxDecoration(
                  color: active ? color : MarketingDarkColors.borderMuted,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 11,
                    color: MarketingDarkColors.textMuted,
                  ),
                  children: [
                    TextSpan(text: '${l10n.registrationPasswordSecurity} '),
                    TextSpan(
                      text: label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              hint,
              style: const TextStyle(
                fontSize: 10,
                color: MarketingDarkColors.slate500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
