/// Sentinel [WorkoutPlanApiModel.customerId] (and Drift `scopeId`) for reusable workout **templates**.
///
/// Real customers must never use this id. [WorkoutPlanRepository.getByCustomerId] scopes by id, so
/// templates stay isolated from client plan lists.
const String kWorkoutPlanTemplateScopeId = '__template__';
