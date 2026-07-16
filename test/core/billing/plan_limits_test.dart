import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/billing/plan_limits.dart';

void main() {
  group('PlanLimits', () {
    test('free tier allows up to five active customers', () {
      expect(PlanLimits.maxActiveCustomers, 5);
    });
  });
}
