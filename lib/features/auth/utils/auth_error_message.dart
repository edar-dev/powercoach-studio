import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../l10n/app_localizations.dart';

/// Maps Supabase [AuthException] to a localized, user-friendly message.
String authErrorMessage(AuthException e, AppLocalizations l10n) {
  final msg = (e.message).toLowerCase();
  final code = e.statusCode;
  final codeNum = code is int ? code : int.tryParse(code?.toString() ?? '');

  if (codeNum == 429) return l10n.loginErrorTooManyRequests;
  if (msg.contains('confirm') || msg.contains('verified') || codeNum == 422) {
    return l10n.loginErrorEmailNotConfirmed;
  }
  if (msg.contains('invalid') ||
      msg.contains('credentials') ||
      msg.contains('invalid_login_credentials') ||
      codeNum == 400) {
    return l10n.loginErrorInvalidCredentials;
  }
  return e.message.isNotEmpty ? e.message : l10n.loginErrorGeneric;
}
