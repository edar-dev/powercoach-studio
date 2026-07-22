import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/auth/utils/auth_error_message.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('registrationErrorMessage maps duplicate email', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('it'));
    final message = registrationErrorMessage(
      AuthException('User already registered'),
      l10n,
    );
    expect(message, l10n.registrationErrorAlreadyRegistered);
  });
}
