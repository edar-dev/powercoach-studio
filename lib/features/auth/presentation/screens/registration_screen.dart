import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/auth/access_waitlist.dart';
import '../../../../core/routing/app_navigation.dart';
import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/auth_dark_form_shell.dart';
import '../widgets/auth_dark_text_field.dart';
import '../widgets/auth_social_buttons.dart';

/// Invite-only access + self-serve waitlist — public `signUp` is not offered.
/// Route remains `/register` for bookmarks and login footer links.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({
    super.key,
    this.onRequestAccess,
  });

  /// Optional override for tests; defaults to [AccessWaitlist.requestAccess].
  final Future<AccessWaitlistResult> Function({
    required String email,
    String? name,
    String? note,
  })? onRequestAccess;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;
  bool _submittedOk = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitWaitlist() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final request = widget.onRequestAccess ?? AccessWaitlist.requestAccess;

    try {
      final result = await request(
        email: _emailController.text,
        name: _nameController.text,
        note: _noteController.text,
      );
      if (!mounted) return;

      setState(() => _submittedOk = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.alreadyPending
                ? l10n.authWaitlistAlreadyPending
                : l10n.authWaitlistSuccess,
            style: TextStyle(color: cs.onPrimaryContainer),
          ),
          backgroundColor: cs.primaryContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on AccessWaitlistException catch (e) {
      // Expected validation / rate-limit responses — do not spam Sentry.
      if (!_isExpectedWaitlistClientError(e.message)) {
        await Sentry.captureException(e);
      }
      if (!mounted) return;
      final message = _mapWaitlistError(l10n, e.message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: cs.onErrorContainer),
          ),
          backgroundColor: cs.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.authWaitlistErrorGeneric,
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

  bool _isExpectedWaitlistClientError(String raw) {
    final lower = raw.toLowerCase();
    return raw == 'invalid_email' ||
        raw == 'rate_limited' ||
        lower.contains('valid email') ||
        lower.contains('too many') ||
        lower.contains('rate');
  }

  String _mapWaitlistError(AppLocalizations l10n, String raw) {
    final lower = raw.toLowerCase();
    if (raw == 'invalid_email' || lower.contains('valid email')) {
      return l10n.authWaitlistErrorInvalidEmail;
    }
    if (raw == 'rate_limited' ||
        lower.contains('too many') ||
        lower.contains('rate')) {
      return l10n.authWaitlistErrorRateLimited;
    }
    return l10n.authWaitlistErrorGeneric;
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
          const SizedBox(height: 20),
          const Divider(color: MarketingDarkColors.borderMuted, height: 1),
          const SizedBox(height: 16),
          Text(
            l10n.authWaitlistSectionTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          if (_submittedOk)
            Text(
              l10n.authWaitlistSuccess,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: MarketingDarkColors.brandLight,
              ),
            )
          else
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthDarkTextField(
                    label: l10n.authWaitlistEmailLabel,
                    controller: _emailController,
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) {
                      final t = value?.trim() ?? '';
                      if (t.isEmpty || !AccessWaitlist.isValidEmail(t)) {
                        return l10n.authWaitlistErrorInvalidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  AuthDarkTextField(
                    label: l10n.authWaitlistNameLabel,
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                  ),
                  const SizedBox(height: 12),
                  AuthDarkTextField(
                    label: l10n.authWaitlistNoteLabel,
                    controller: _noteController,
                    hint: l10n.authWaitlistNoteHint,
                    prefixIcon: Icons.notes_outlined,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submitWaitlist(),
                  ),
                  const SizedBox(height: 20),
                  AuthPrimaryCta(
                    label: l10n.authWaitlistSubmit,
                    isLoading: _isLoading,
                    onPressed: _submitWaitlist,
                  ),
                ],
              ),
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
