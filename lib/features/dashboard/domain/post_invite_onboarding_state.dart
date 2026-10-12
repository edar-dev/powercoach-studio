import 'dashboard_snapshot.dart';

/// Resolved visibility and step progress for the post-invite checklist.
class PostInviteOnboardingState {
  const PostInviteOnboardingState({
    required this.visible,
    required this.hasCustomer,
    required this.hasPlan,
    required this.pdfDone,
    required this.completedCount,
    this.firstCustomerWithoutPlanId,
    this.firstPlanCustomerId,
    this.firstPlanId,
  });

  final bool visible;
  final bool hasCustomer;
  final bool hasPlan;
  final bool pdfDone;
  final int completedCount;
  final String? firstCustomerWithoutPlanId;
  final String? firstPlanCustomerId;
  final String? firstPlanId;
}

/// Pure resolver: snapshot counts + prefs → checklist UI state.
PostInviteOnboardingState resolvePostInviteOnboarding({
  required DashboardSnapshot snapshot,
  required bool dismissed,
  required bool pdfDone,
}) {
  final hasCustomer = snapshot.clientCount > 0;
  final hasPlan = snapshot.activePrograms > 0;
  final completedCount =
      (hasCustomer ? 1 : 0) + (hasPlan ? 1 : 0) + (pdfDone ? 1 : 0);
  final allDone = hasCustomer && hasPlan && pdfDone;
  final visible = !dismissed && !allDone && !snapshot.hasError;

  final firstWithoutPlan = snapshot.customersWithoutPlan.isEmpty
      ? null
      : snapshot.customersWithoutPlan.first.customerId;

  String? planCustomerId;
  String? planId;
  if (snapshot.stalePlans.isNotEmpty) {
    planCustomerId = snapshot.stalePlans.first.customerId;
    planId = snapshot.stalePlans.first.planId;
  } else if (snapshot.todayItems.isNotEmpty) {
    planCustomerId = snapshot.todayItems.first.customerId;
    planId = snapshot.todayItems.first.planId;
  }

  return PostInviteOnboardingState(
    visible: visible,
    hasCustomer: hasCustomer,
    hasPlan: hasPlan,
    pdfDone: pdfDone,
    completedCount: completedCount,
    firstCustomerWithoutPlanId: firstWithoutPlan,
    firstPlanCustomerId: planCustomerId,
    firstPlanId: planId,
  );
}
