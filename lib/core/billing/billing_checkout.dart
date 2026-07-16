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
    final response = await Supabase.instance.client.functions.invoke(
      'create-checkout-session',
      body: <String, String>{
        'billingInterval': interval.name,
        'successUrl': '$_returnBase?checkout=success',
        'cancelUrl': '$_returnBase?checkout=cancel',
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw BillingCheckoutException('Unexpected checkout response');
    }

    final error = data['error']?.toString();
    if (error != null && error.isNotEmpty) {
      throw BillingCheckoutException(error);
    }

    final url = data['url']?.toString();
    if (url == null || url.isEmpty) {
      throw BillingCheckoutException('Missing checkout URL');
    }

    openExternalUrl(url);
    return url;
  }

  static Future<String> openCustomerPortal() async {
    await SupabaseBootstrap.ensureInitialized();
    final response = await Supabase.instance.client.functions.invoke(
      'create-portal-session',
      body: <String, String>{
        'returnUrl': _returnBase,
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw BillingCheckoutException('Unexpected portal response');
    }

    final error = data['error']?.toString();
    if (error != null && error.isNotEmpty) {
      throw BillingCheckoutException(error);
    }

    final url = data['url']?.toString();
    if (url == null || url.isEmpty) {
      throw BillingCheckoutException('Missing portal URL');
    }

    openExternalUrl(url);
    return url;
  }
}

class BillingCheckoutException implements Exception {
  BillingCheckoutException(this.message);

  final String message;

  @override
  String toString() => message;
}
