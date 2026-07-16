import 'package:flutter/foundation.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/platform/open_external_url.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'entitlement_models.dart';

/// Stripe Checkout / Customer Portal via Supabase Edge Functions (web redirect).
abstract final class BillingCheckout {
  static String get _returnBase {
    if (kIsWeb) {
      return '${Uri.base.origin}/settings/subscription';
    }
    return 'https://powercoach-studio.vercel.app/settings/subscription';
  }

  static Future<String> startCheckout({
    BillingInterval interval = BillingInterval.monthly,
  }) async {
    await SupabaseBootstrap.ensureInitialized();
    final response = await _invoke('create-checkout-session', <String, String>{
      'billingInterval': interval.name,
      'successUrl': '$_returnBase?checkout=success',
      'cancelUrl': '$_returnBase?checkout=cancel',
    });

    final url = _readUrl(response);
    openExternalUrl(url);
    return url;
  }

  static Future<String> openCustomerPortal() async {
    await SupabaseBootstrap.ensureInitialized();
    final response = await _invoke('create-portal-session', <String, String>{
      'returnUrl': _returnBase,
    });

    final url = _readUrl(response);
    openExternalUrl(url);
    return url;
  }

  static Future<FunctionResponse> _invoke(
    String name,
    Map<String, String> body,
  ) async {
    try {
      return await Supabase.instance.client.functions.invoke(name, body: body);
    } on FunctionException catch (e) {
      throw BillingCheckoutException(_messageFromFunctionException(e));
    }
  }

  static String _readUrl(FunctionResponse response) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw BillingCheckoutException('Unexpected billing response');
    }

    final error = data['error']?.toString();
    if (error != null && error.isNotEmpty) {
      throw BillingCheckoutException(error);
    }

    final url = data['url']?.toString();
    if (url == null || url.isEmpty) {
      throw BillingCheckoutException('Missing checkout URL');
    }

    return url;
  }

  static String _messageFromFunctionException(FunctionException e) {
    final details = e.details;
    if (details is Map && details['error'] != null) {
      return details['error'].toString();
    }
    if (details is String && details.isNotEmpty) {
      return details;
    }
    return e.reasonPhrase ?? 'Billing request failed (${e.status})';
  }
}

class BillingCheckoutException implements Exception {
  BillingCheckoutException(this.message);

  final String message;

  @override
  String toString() => message;
}
