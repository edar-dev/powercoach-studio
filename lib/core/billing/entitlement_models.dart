enum BillingPlan { free, pro }

enum BillingStatus {
  none,
  active,
  trialing,
  pastDue,
  canceled,
}

enum BillingInterval { monthly, yearly }

class Entitlement {
  const Entitlement({
    required this.plan,
    required this.subscriptionPlan,
    required this.status,
    this.currentPeriodEnd,
    this.proUntil,
  });

  final BillingPlan plan;
  final BillingPlan subscriptionPlan;
  final BillingStatus status;
  final DateTime? currentPeriodEnd;
  final DateTime? proUntil;

  bool get isPro => plan == BillingPlan.pro;

  factory Entitlement.fromJson(Map<String, dynamic> json) {
    return Entitlement(
      plan: _parsePlan(json['plan']),
      subscriptionPlan: _parsePlan(json['subscriptionPlan']),
      status: _parseStatus(json['status']),
      currentPeriodEnd: _parseDate(json['currentPeriodEnd']),
      proUntil: _parseDate(json['proUntil']),
    );
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

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    final parsed = DateTime.tryParse(value.toString());
    return parsed?.toUtc();
  }
}
