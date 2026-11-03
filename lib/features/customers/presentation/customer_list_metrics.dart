import '../../dashboard/domain/dashboard_snapshot.dart';
import '../data/models/customer.dart';
import 'customer_list_filter.dart';

/// Aggregate KPI strip for the populated customers list (honest local fields only).
class CustomerListMetrics {
  const CustomerListMetrics({
    required this.totalAthletes,
    required this.activeCount,
    required this.plansInProgress,
    required this.pausedCount,
    required this.needsUpdateCount,
  });

  final int totalAthletes;
  final int activeCount;
  final int plansInProgress;
  final int pausedCount;
  final int needsUpdateCount;
}

/// Builds list metrics from [Customer] fields only (no per-row plan fetches).
CustomerListMetrics computeCustomerListMetrics(
  List<Customer> customers, {
  DateTime? now,
  int stalePlanDays = kStalePlanDays,
}) {
  final clock = now ?? DateTime.now();
  var active = 0;
  var plansInProgress = 0;
  var paused = 0;
  var needsUpdate = 0;

  for (final c in customers) {
    if (c.isArchived) {
      paused++;
      continue;
    }
    active++;
    if (!customerHasAssignedPlan(c)) continue;
    plansInProgress++;
    if (customerPlanIsStale(c, now: clock, stalePlanDays: stalePlanDays)) {
      needsUpdate++;
    }
  }

  return CustomerListMetrics(
    totalAthletes: customers.length,
    activeCount: active,
    plansInProgress: plansInProgress,
    pausedCount: paused,
    needsUpdateCount: needsUpdate,
  );
}
