import '../sync/offline_models.dart';

/// Selectable slices of a user backup import.
enum BackupEntityGroup {
  customers,
  workoutPlans,
  exerciseLibrary,
  reminders,
  preferences,
}

const Set<BackupEntityGroup> kAllBackupEntityGroups = {
  BackupEntityGroup.customers,
  BackupEntityGroup.workoutPlans,
  BackupEntityGroup.exerciseLibrary,
  BackupEntityGroup.reminders,
  BackupEntityGroup.preferences,
};

/// Entity types included when [BackupEntityGroup.customers] is selected.
const Set<OfflineEntityType> kCustomerRelatedEntityTypes = {
  OfflineEntityType.customer,
  OfflineEntityType.measurement,
  OfflineEntityType.exerciseRecord,
  OfflineEntityType.customerNote,
};

Set<OfflineEntityType> entityTypesForBackupGroups(Set<BackupEntityGroup> groups) {
  final types = <OfflineEntityType>{};
  for (final group in groups) {
    switch (group) {
      case BackupEntityGroup.customers:
        types.addAll(kCustomerRelatedEntityTypes);
      case BackupEntityGroup.workoutPlans:
        types.add(OfflineEntityType.workoutPlan);
      case BackupEntityGroup.exerciseLibrary:
        types.add(OfflineEntityType.customExercise);
      case BackupEntityGroup.reminders:
      case BackupEntityGroup.preferences:
        break;
    }
  }
  return types;
}

bool backupGroupsIncludeAllEntityTypes(Set<BackupEntityGroup> groups) {
  return kCustomerRelatedEntityTypes.every(
        (t) => entityTypesForBackupGroups(groups).contains(t),
      ) &&
      entityTypesForBackupGroups(groups).contains(OfflineEntityType.workoutPlan) &&
      entityTypesForBackupGroups(groups).contains(OfflineEntityType.customExercise);
}

OfflineEntityType? _entityTypeFromBackupRow(Map<String, dynamic> entity) {
  final typeName = entity['type']?.toString();
  if (typeName == null || typeName.isEmpty) return null;
  for (final type in OfflineEntityType.values) {
    if (type.name == typeName) return type;
  }
  return null;
}

BackupEntityGroup? backupGroupForEntityRow(Map<String, dynamic> entity) {
  final type = _entityTypeFromBackupRow(entity);
  if (type != null) {
    return backupGroupForEntityType(type);
  }
  if (entity.containsKey('planData')) {
    return BackupEntityGroup.workoutPlans;
  }
  return null;
}

BackupEntityGroup? backupGroupForEntityType(OfflineEntityType type) {
  if (kCustomerRelatedEntityTypes.contains(type)) {
    return BackupEntityGroup.customers;
  }
  return switch (type) {
    OfflineEntityType.workoutPlan => BackupEntityGroup.workoutPlans,
    OfflineEntityType.customExercise => BackupEntityGroup.exerciseLibrary,
    _ => null,
  };
}

List<Map<String, dynamic>> filterBackupEntities(
  List<Map<String, dynamic>> entities,
  Set<BackupEntityGroup> groups,
) {
  if (groups.isEmpty) return const [];
  return [
    for (final entity in entities)
      if (_entityIncludedInGroups(entity, groups)) entity,
  ];
}

bool _entityIncludedInGroups(
  Map<String, dynamic> entity,
  Set<BackupEntityGroup> groups,
) {
  final group = backupGroupForEntityRow(entity);
  return group != null && groups.contains(group);
}
