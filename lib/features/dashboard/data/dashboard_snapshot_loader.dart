import '../../../core/storage/offline_local_store.dart';
import '../../customers/data/customer_repository.dart';
import '../../workouts/data/workout_plan_repository.dart';
import '../domain/dashboard_snapshot.dart';

/// Loads [DashboardSnapshot] from repositories and the offline outbox.
class DashboardSnapshotLoader {
  DashboardSnapshotLoader({
    CustomerRepository? customerRepository,
    WorkoutPlanRepository? workoutPlanRepository,
    OfflineLocalStore? offlineStore,
  })  : _customers = customerRepository ?? CustomerRepository(),
        _plans = workoutPlanRepository ?? WorkoutPlanRepository(),
        _offline = offlineStore ?? OfflineLocalStore.instance;

  final CustomerRepository _customers;
  final WorkoutPlanRepository _plans;
  final OfflineLocalStore _offline;

  Future<DashboardSnapshot> load({
    required String unknownClientLabel,
    DateTime? now,
  }) async {
    final clock = now ?? DateTime.now();
    try {
      final customers = await _customers.getAll();
      final plans = await _plans.getAll();
      final pending = await _offline.readPendingOperations();
      return buildDashboardSnapshot(
        customers: customers,
        plans: plans,
        pendingOperations: pending,
        now: clock,
        unknownClientLabel: unknownClientLabel,
      );
    } catch (e, _) {
      return DashboardSnapshot.error(e.toString());
    }
  }
}
