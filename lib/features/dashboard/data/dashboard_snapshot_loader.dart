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
    required String untitledWorkoutLabel,
    DateTime? now,
  }) async {
    final clock = now ?? DateTime.now();
    try {
      final customersFuture = _customers.getAll();
      final plansFuture = _plans.getAll();
      final pendingFuture = _offline.readPendingOperations();
      return buildDashboardSnapshot(
        customers: await customersFuture,
        plans: await plansFuture,
        pendingOperations: await pendingFuture,
        now: clock,
        unknownClientLabel: unknownClientLabel,
        untitledWorkoutLabel: untitledWorkoutLabel,
      );
    } catch (e) {
      return DashboardSnapshot.error(e.toString());
    }
  }
}
