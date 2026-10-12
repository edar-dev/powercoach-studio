import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_bootstrap.dart';

/// Self-serve **app access** waitlist (invite-only).
///
/// Distinct from Pro promo `BillingPromo.requestCoupon` / `coupon_requests`.
/// Uses Edge Function `request-access` (service role server-side only).
abstract final class AccessWaitlist {
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Injectable for widget tests; production uses [_invokeRequestAccess].
  static Future<AccessWaitlistResult> Function({
    required String email,
    String? name,
    String? note,
  }) requestAccess = _invokeRequestAccess;

  static void resetForTests() {
    requestAccess = _invokeRequestAccess;
  }

  static bool isValidEmail(String email) {
    final trimmed = email.trim();
    return trimmed.isNotEmpty && emailRegex.hasMatch(trimmed);
  }

  static Future<AccessWaitlistResult> _invokeRequestAccess({
    required String email,
    String? name,
    String? note,
  }) async {
    final trimmedEmail = email.trim();
    if (!isValidEmail(trimmedEmail)) {
      throw AccessWaitlistException('invalid_email');
    }

    await SupabaseBootstrap.ensureInitialized();
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'request-access',
        body: <String, String?>{
          'email': trimmedEmail,
          if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        },
      );

      final data = response.data;
      if (data is! Map) {
        throw AccessWaitlistException('unexpected_response');
      }

      final map = Map<String, dynamic>.from(data);
      final error = map['error']?.toString();
      if (error != null && error.isNotEmpty) {
        throw AccessWaitlistException(error);
      }

      return AccessWaitlistResult(
        alreadyPending: map['alreadyPending'] == true,
      );
    } on FunctionException catch (e) {
      throw AccessWaitlistException(_messageFromFunctionException(e));
    }
  }

  static String _messageFromFunctionException(FunctionException e) {
    final details = e.details;
    if (details is Map && details['error'] != null) {
      return details['error'].toString();
    }
    if (details is String && details.isNotEmpty) {
      return details;
    }
    if (e.status == 429) {
      return 'rate_limited';
    }
    return e.reasonPhrase ?? 'Request failed (${e.status})';
  }
}

class AccessWaitlistResult {
  const AccessWaitlistResult({this.alreadyPending = false});

  final bool alreadyPending;
}

class AccessWaitlistException implements Exception {
  AccessWaitlistException(this.message);

  final String message;

  @override
  String toString() => message;
}
