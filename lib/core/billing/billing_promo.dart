import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/supabase_bootstrap.dart';

/// Invite promo code redemption and Pro access requests (no Stripe checkout).
abstract final class BillingPromo {
  static Future<RedeemPromoResult> redeemCode(String code) async {
    await SupabaseBootstrap.ensureInitialized();
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'redeem-promo-code',
        body: <String, String>{'code': code.trim()},
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw BillingPromoException('Unexpected response');
      }

      final error = data['error']?.toString();
      if (error != null && error.isNotEmpty) {
        throw BillingPromoException(error);
      }

      return RedeemPromoResult(
        alreadyPro: data['alreadyPro'] == true,
      );
    } on FunctionException catch (e) {
      throw BillingPromoException(_messageFromFunctionException(e));
    }
  }

  static Future<CouponRequestResult> requestCoupon({String? message}) async {
    await SupabaseBootstrap.ensureInitialized();
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'request-coupon',
        body: <String, String?>{
          if (message != null && message.trim().isNotEmpty)
            'message': message.trim(),
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw BillingPromoException('Unexpected response');
      }

      final error = data['error']?.toString();
      if (error != null && error.isNotEmpty) {
        throw BillingPromoException(error);
      }

      return CouponRequestResult(
        alreadyPending: data['alreadyPending'] == true,
      );
    } on FunctionException catch (e) {
      throw BillingPromoException(_messageFromFunctionException(e));
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
    return e.reasonPhrase ?? 'Request failed (${e.status})';
  }
}

class RedeemPromoResult {
  const RedeemPromoResult({this.alreadyPro = false});

  final bool alreadyPro;
}

class CouponRequestResult {
  const CouponRequestResult({this.alreadyPending = false});

  final bool alreadyPending;
}

class BillingPromoException implements Exception {
  BillingPromoException(this.message);

  final String message;

  @override
  String toString() => message;
}
