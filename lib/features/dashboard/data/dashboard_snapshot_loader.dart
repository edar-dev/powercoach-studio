import '../../customers/data/customer_repository.dart';
import '../../workouts/data/workout_plan_repository.dart';
import '../domain/dashboard_snapshot.dart';

/// Loads [DashboardSnapshot] from local repositories.
class DashboardSnapshotLoader {
  DashboardSnapshotLoader({
    CustomerRepository? customerRepository,
    WorkoutPlanRepository? workoutPlanRepository,
  })  : _customers = customerRepository ?? CustomerRepository(),
        _plans = workoutPlanRepository ?? WorkoutPlanRepository();

  final CustomerRepository _customers;
  final WorkoutPlanRepository _plans;

  Future<DashboardSnapshot> load({
    required String unknownClientLabel,
    required String untitledWorkoutLabel,
    DateTime? now,
  }) async {
    final clock = now ?? DateTime.now();
    try {
      final customersFuture = _customers.getAll();
      final plansFuture = _plans.getAll();
      return buildDashboardSnapshot(
        customers: await customersFuture,
        plans: await plansFuture,
        now: clock,
        unknownClientLabel: unknownClientLabel,
        untitledWorkoutLabel: untitledWorkoutLabel,
      );
    } catch (e) {
      return DashboardSnapshot.error(e.toString());
    }
  }
}
