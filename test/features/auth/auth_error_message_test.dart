import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/auth/utils/auth_error_message.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('registrationErrorMessage maps duplicate email', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('it'));
    final message = registrationErrorMessage(
      const AuthException('User already registered'),
      l10n,
    );
    expect(message, l10n.registrationErrorAlreadyRegistered);
  });

  test('registrationErrorMessage maps signup disabled messages', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('it'));
    final fragments = [
      'Signups not allowed for this instance',
      'Signup is disabled',
      'Sign up is disabled',
      'Email signups are disabled',
      'Registration is disabled',
      'signup_disabled',
    ];
    for (final fragment in fragments) {
      final message = registrationErrorMessage(AuthException(fragment), l10n);
      expect(
        message,
        l10n.registrationErrorSignupsDisabled,
        reason: 'Expected mapping for "$fragment"',
      );
    }
  });

  test('registrationErrorMessage maps signup_disabled code', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('it'));
    final message = registrationErrorMessage(
      const AuthException(
        'Forbidden',
        code: 'signup_disabled',
      ),
      l10n,
    );
    expect(message, l10n.registrationErrorSignupsDisabled);
  });

  test('authErrorMessage maps signup disabled for login path', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('it'));
    final message = authErrorMessage(
      const AuthException(
        'Signups not allowed for this instance',
        code: 'signup_disabled',
      ),
      l10n,
    );
    expect(message, l10n.registrationErrorSignupsDisabled);
  });
}
