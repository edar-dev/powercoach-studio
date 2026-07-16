import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/billing/entitlement_models.dart';

void main() {
  group('Entitlement.fromJson', () {
    test('parses pro plan with grace period fields', () {
      final entitlement = Entitlement.fromJson(<String, dynamic>{
        'plan': 'pro',
        'subscriptionPlan': 'pro',
        'status': 'canceled',
        'currentPeriodEnd': '2026-08-01T00:00:00Z',
        'proUntil': '2026-08-08T00:00:00Z',
      });

      expect(entitlement.isPro, isTrue);
      expect(entitlement.status, BillingStatus.canceled);
      expect(entitlement.proUntil, isNotNull);
    });

    test('defaults missing fields to free', () {
      final entitlement = Entitlement.fromJson(<String, dynamic>{});

      expect(entitlement.plan, BillingPlan.free);
      expect(entitlement.status, BillingStatus.none);
      expect(entitlement.isPro, isFalse);
    });
  });
}
