enum BillingPlan { free, pro }

enum BillingStatus {
  none,
  active,
  trialing,
  pastDue,
  canceled,
}

enum BillingInterval { monthly, yearly }

enum EntitlementSource { none, stripe, promo, manual }

class Entitlement {
  const Entitlement({
    required this.plan,
    required this.subscriptionPlan,
    required this.status,
    this.currentPeriodEnd,
    this.proUntil,
    this.billingInterval,
    this.priceAmountCents,
    this.currency,
    this.entitlementSource = EntitlementSource.none,
    this.hasPendingCouponRequest = false,
  });

  final BillingPlan plan;
  final BillingPlan subscriptionPlan;
  final BillingStatus status;
  final DateTime? currentPeriodEnd;
  final DateTime? proUntil;
  final BillingInterval? billingInterval;
  final int? priceAmountCents;
  final String? currency;
  final EntitlementSource entitlementSource;
  final bool hasPendingCouponRequest;

  bool get isPro => plan == BillingPlan.pro;

  bool get isStripeBilling => entitlementSource == EntitlementSource.stripe;

  factory Entitlement.fromJson(Map<String, dynamic> json) {
    return Entitlement(
      plan: _parsePlan(json['plan']),
      subscriptionPlan: _parsePlan(json['subscriptionPlan']),
      status: _parseStatus(json['status']),
      currentPeriodEnd: _parseDate(json['currentPeriodEnd']),
      proUntil: _parseDate(json['proUntil']),
      billingInterval: _parseInterval(json['billingInterval']),
      priceAmountCents: _parseInt(json['priceAmountCents']),
      currency: json['currency']?.toString(),
      entitlementSource: _parseSource(json['entitlementSource']),
      hasPendingCouponRequest: json['hasPendingCouponRequest'] == true,
    );
  }

  static EntitlementSource _parseSource(Object? value) {
    return switch (value?.toString()) {
      'stripe' => EntitlementSource.stripe,
      'promo' => EntitlementSource.promo,
      'manual' => EntitlementSource.manual,
      _ => EntitlementSource.none,
    };
  }

  static BillingPlan _parsePlan(Object? value) {
    return value?.toString() == 'pro' ? BillingPlan.pro : BillingPlan.free;
  }

  static BillingStatus _parseStatus(Object? value) {
    return switch (value?.toString()) {
      'active' => BillingStatus.active,
      'trialing' => BillingStatus.trialing,
      'past_due' => BillingStatus.pastDue,
      'canceled' => BillingStatus.canceled,
      _ => BillingStatus.none,
    };
  }

  static BillingInterval? _parseInterval(Object? value) {
    return switch (value?.toString()) {
      'yearly' => BillingInterval.yearly,
      'monthly' => BillingInterval.monthly,
      _ => null,
    };
  }

  static int? _parseInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    final parsed = DateTime.tryParse(value.toString());
    return parsed?.toUtc();
  }
}
