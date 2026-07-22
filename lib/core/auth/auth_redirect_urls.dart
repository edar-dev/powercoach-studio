import 'package:flutter/foundation.dart';

/// Supabase auth email links (confirmation, recovery) must redirect to an
/// allowlisted URL. Prefer the current web origin; fall back to production.
abstract final class AuthRedirectUrls {
  static const productionOrigin = 'https://powercoach-studio.vercel.app';

  static String get _origin {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      if (origin.isNotEmpty && origin != 'null') {
        return origin;
      }
    }
    return productionOrigin;
  }

  /// After the user confirms their email, land on login so the app can pick up
  /// the session from the URL fragment and route guards can send them in-app.
  static String get emailConfirmation => '$_origin/login';

  static String get passwordRecovery => '$_origin/login';
}
