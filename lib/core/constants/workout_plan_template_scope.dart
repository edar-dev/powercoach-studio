/// Legacy sentinel formerly used as [WorkoutPlanApiModel.customerId] / Drift
/// `scopeId` for reusable workout templates.
///
/// Templates are no longer a product feature. This constant remains only so we
/// can: (1) exclude leftover rows from [getAll], (2) purge them on local load,
/// and (3) skip them on backup import/export. Do not write new entities with
/// this scope.
const String kWorkoutPlanTemplateScopeId = '__template__';

/// True when a backup/offline entity map is a retired template-scoped workout plan.
bool isLegacyWorkoutPlanTemplateEntity(Map<String, dynamic> raw) {
  if (raw['scopeId']?.toString() == kWorkoutPlanTemplateScopeId) {
    return true;
  }
  if (raw['customerId']?.toString() == kWorkoutPlanTemplateScopeId) {
    return true;
  }
  final payload = raw['payload'];
  if (payload is Map &&
      payload['customerId']?.toString() == kWorkoutPlanTemplateScopeId) {
    return true;
  }
  return false;
}
