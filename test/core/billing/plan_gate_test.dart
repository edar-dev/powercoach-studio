import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/billing/entitlement_models.dart';
import 'package:powercoach_studio/core/billing/entitlement_repository.dart';
import 'package:powercoach_studio/core/billing/plan_gate.dart';
import 'package:powercoach_studio/core/billing/plan_limits.dart';

void main() {
  const free = Entitlement(
    plan: BillingPlan.free,
    subscriptionPlan: BillingPlan.free,
    status: BillingStatus.none,
  );
  const pro = Entitlement(
    plan: BillingPlan.pro,
    subscriptionPlan: BillingPlan.pro,
    status: BillingStatus.active,
  );

  tearDown(() {
    EntitlementRepository.instance.entitlement.value = null;
  });

  group('PlanGate', () {
    test('isPro reflects cached entitlement', () async {
      EntitlementRepository.instance.entitlement.value = free;
      expect(await PlanGate.isPro(), isFalse);

      EntitlementRepository.instance.entitlement.value = pro;
      expect(await PlanGate.isPro(), isTrue);
    });

    test('canAddCustomer enforces free limit and allows Pro', () async {
      EntitlementRepository.instance.entitlement.value = free;
      expect(await PlanGate.canAddCustomer(4), isTrue);
      expect(
        await PlanGate.canAddCustomer(PlanLimits.maxActiveCustomers),
        isFalse,
      );
      expect(
        await PlanGate.canAddCustomer(PlanLimits.maxActiveCustomers - 1),
        isTrue,
      );

      EntitlementRepository.instance.entitlement.value = pro;
      expect(await PlanGate.canAddCustomer(50), isTrue);
    });

    test('export and brand helpers follow isPro', () async {
      EntitlementRepository.instance.entitlement.value = free;
      expect(await PlanGate.canExportProgress(), isFalse);
      expect(await PlanGate.canExportWorkoutPdfOrExcel(), isFalse);
      expect(await PlanGate.canCustomizePdfBrand(), isFalse);
      expect(await PlanGate.canExportMeasurements(), isFalse);

      EntitlementRepository.instance.entitlement.value = pro;
      expect(await PlanGate.canExportProgress(), isTrue);
      expect(await PlanGate.canExportWorkoutPdfOrExcel(), isTrue);
      expect(await PlanGate.canCustomizePdfBrand(), isTrue);
      expect(await PlanGate.canExportMeasurements(), isTrue);
    });
  });
}
