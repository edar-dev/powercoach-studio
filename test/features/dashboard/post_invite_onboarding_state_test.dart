import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/features/dashboard/domain/dashboard_snapshot.dart';
import 'package:powercoach_studio/features/dashboard/domain/post_invite_onboarding_state.dart';

DashboardSnapshot _snap({
  int clientCount = 0,
  int activePrograms = 0,
  List<DashboardTodayItem> todayItems = const [],
  List<DashboardStalePlanItem> stalePlans = const [],
  List<DashboardCustomerNoPlanItem> customersWithoutPlan = const [],
  String? errorMessage,
}) {
  return DashboardSnapshot(
    errorMessage: errorMessage,
    clientCount: clientCount,
    activePrograms: activePrograms,
    weeklyUpdates: 0,
    todayItems: todayItems,
    stalePlans: stalePlans,
    customersWithoutPlan: customersWithoutPlan,
  );
}

void main() {
  test('visible when not dismissed and incomplete', () {
    final state = resolvePostInviteOnboarding(
      snapshot: _snap(),
      dismissed: false,
      pdfDone: false,
    );
    expect(state.visible, isTrue);
    expect(state.hasCustomer, isFalse);
    expect(state.hasPlan, isFalse);
    expect(state.pdfDone, isFalse);
    expect(state.completedCount, 0);
  });

  test('hidden when dismissed', () {
    final state = resolvePostInviteOnboarding(
      snapshot: _snap(),
      dismissed: true,
      pdfDone: false,
    );
    expect(state.visible, isFalse);
  });

  test('hidden when all three steps done', () {
    final state = resolvePostInviteOnboarding(
      snapshot: _snap(clientCount: 1, activePrograms: 1),
      dismissed: false,
      pdfDone: true,
    );
    expect(state.visible, isFalse);
    expect(state.completedCount, 3);
    expect(state.hasCustomer, isTrue);
    expect(state.hasPlan, isTrue);
    expect(state.pdfDone, isTrue);
  });

  test('hidden on snapshot error', () {
    final state = resolvePostInviteOnboarding(
      snapshot: _snap(errorMessage: 'boom'),
      dismissed: false,
      pdfDone: false,
    );
    expect(state.visible, isFalse);
  });

  test('counts customer and plan from snapshot; pdf from pref', () {
    final state = resolvePostInviteOnboarding(
      snapshot: _snap(clientCount: 2, activePrograms: 3),
      dismissed: false,
      pdfDone: false,
    );
    expect(state.visible, isTrue);
    expect(state.completedCount, 2);
    expect(state.hasCustomer, isTrue);
    expect(state.hasPlan, isTrue);
    expect(state.pdfDone, isFalse);
  });

  test('prefers first customer without plan and stale plan deep-link hints', () {
    final state = resolvePostInviteOnboarding(
      snapshot: _snap(
        clientCount: 2,
        activePrograms: 1,
        customersWithoutPlan: const [
          DashboardCustomerNoPlanItem(customerId: 'c-no-plan', name: 'A'),
          DashboardCustomerNoPlanItem(customerId: 'c-other', name: 'B'),
        ],
        stalePlans: [
          DashboardStalePlanItem(
            customerId: 'c-stale',
            planId: 'p-stale',
            clientName: 'S',
            programName: 'P',
            updatedAt: DateTime(2026, 1, 1),
          ),
        ],
        todayItems: [
          DashboardTodayItem(
            customerId: 'c-today',
            planId: 'p-today',
            weekIndex: 0,
            dayIndex: 0,
            sessionLabel: 'A',
            clientName: 'T',
            programName: 'P',
            date: DateTime(2026, 3, 1),
          ),
        ],
      ),
      dismissed: false,
      pdfDone: false,
    );
    expect(state.firstCustomerWithoutPlanId, 'c-no-plan');
    expect(state.firstPlanCustomerId, 'c-stale');
    expect(state.firstPlanId, 'p-stale');
  });

  test('falls back to todayItems for plan deep-link when no stale plans', () {
    final state = resolvePostInviteOnboarding(
      snapshot: _snap(
        clientCount: 1,
        activePrograms: 1,
        todayItems: [
          DashboardTodayItem(
            customerId: 'c-today',
            planId: 'p-today',
            weekIndex: 0,
            dayIndex: 0,
            sessionLabel: 'A',
            clientName: 'T',
            programName: 'P',
            date: DateTime(2026, 3, 1),
          ),
        ],
      ),
      dismissed: false,
      pdfDone: true,
    );
    expect(state.firstPlanCustomerId, 'c-today');
    expect(state.firstPlanId, 'p-today');
    expect(state.visible, isFalse);
  });
}
