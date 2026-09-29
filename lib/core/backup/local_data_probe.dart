import '../storage/offline_local_store.dart';
import '../sync/offline_models.dart';

/// Lightweight checks over the local Drift entity cache for recovery gates.
class LocalDataProbe {
  LocalDataProbe({OfflineLocalStore? store})
    : _store = store ?? OfflineLocalStore.instance;

  static final LocalDataProbe instance = LocalDataProbe();

  final OfflineLocalStore _store;

  /// True when [userId] has no non-deleted customers **and** no non-deleted
  /// workout plans (coach data looks empty — candidate for cloud recovery).
  Future<bool> isCoachDataEmpty(String userId) async {
    if (userId.isEmpty) return true;
    final entities = await _store.listEntitiesJsonForBackup(userId);
    var hasCustomer = false;
    var hasWorkoutPlan = false;
    for (final raw in entities) {
      final deleted = raw['deleted'] == true;
      if (deleted) continue;
      final type = raw['type']?.toString();
      if (type == OfflineEntityType.customer.name) {
        hasCustomer = true;
      } else if (type == OfflineEntityType.workoutPlan.name) {
        hasWorkoutPlan = true;
      }
      if (hasCustomer || hasWorkoutPlan) return false;
    }
    return true;
  }

  /// Newest `updatedAt` across all local entities for [userId], or null.
  Future<DateTime?> maxEntityUpdatedAt(String userId) async {
    if (userId.isEmpty) return null;
    final entities = await _store.listEntitiesJsonForBackup(userId);
    DateTime? max;
    for (final raw in entities) {
      final parsed = DateTime.tryParse(raw['updatedAt']?.toString() ?? '');
      if (parsed == null) continue;
      if (max == null || parsed.isAfter(max)) {
        max = parsed;
      }
    }
    return max;
  }
}
