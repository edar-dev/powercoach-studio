import 'dart:convert';

import '../../../core/sync/offline_models.dart';
import '../../../core/sync/offline_repository_support.dart';
import 'workout_plan_api_model.dart';
import 'workout_routine_model.dart';

/// Persists workout plans in local storage.
class WorkoutPlanRepository {
  WorkoutPlanRepository({OfflineRepositorySupport? offline})
      : _offline = offline ?? OfflineRepositorySupport();

  final OfflineRepositorySupport _offline;

  Future<List<WorkoutPlanApiModel>> getAll() async {
    final local = await _offline.readLocalEntities(OfflineEntityType.workoutPlan);
    final models = local.map(WorkoutPlanApiModel.fromJson).toList();
    _sortPlansByStartDateDesc(models);
    return models;
  }

  Future<List<WorkoutPlanApiModel>> getByCustomerId(String customerId) async {
    final local = await _offline.readLocalEntities(
      OfflineEntityType.workoutPlan,
      scopeId: customerId,
    );
    final models = local.map(WorkoutPlanApiModel.fromJson).toList();
    _sortPlansByStartDateDesc(models);
    return models;
  }

  Future<WorkoutPlanApiModel?> getById(String planId) async {
    final local = await _offline.readLocalEntityById(
      OfflineEntityType.workoutPlan,
      planId,
    );
    if (local == null) return null;
    return WorkoutPlanApiModel.fromJson(local);
  }

  Future<WorkoutPlanApiModel> create({
    required String customerId,
    required String name,
    required String planDataJson,
    String? pdfHeader,
    bool useCustomPdfHeader = false,
    String? theme,
    int initialWeekNumber = 1,
    String? phase,
    String? tags,
    String? notes,
  }) async {
    final tempId = _offline.newTempId('workout');
    final now = DateTime.now();
    final body = <String, dynamic>{
      'customerId': customerId,
      'name': name,
      'planData': planDataJson,
      'useCustomPdfHeader': useCustomPdfHeader,
      'initialWeekNumber': initialWeekNumber,
    };
    if (pdfHeader != null) body['pdfHeader'] = pdfHeader;
    if (theme != null) body['theme'] = theme;
    if (phase != null) body['phase'] = phase;
    if (tags != null) body['tags'] = tags;
    if (notes != null) body['notes'] = notes;

    final localPayload = <String, dynamic>{
      'id': tempId,
      'customerId': customerId,
      'userId': '',
      ...body,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'rowVersion': 1,
    };
    await _offline.saveLocalEntity(
      type: OfflineEntityType.workoutPlan,
      id: tempId,
      scopeId: customerId,
      payload: localPayload,
      localOnly: false,
    );
    return WorkoutPlanApiModel.fromJson(localPayload);
  }

  Future<WorkoutPlanApiModel> update({
    required String planId,
    String? name,
    String? planDataJson,
    String? pdfHeader,
    bool? useCustomPdfHeader,
    String? theme,
    int? initialWeekNumber,
    String? phase,
    String? tags,
    String? notes,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (planDataJson != null) body['planData'] = planDataJson;
    if (pdfHeader != null) body['pdfHeader'] = pdfHeader;
    if (useCustomPdfHeader != null) body['useCustomPdfHeader'] = useCustomPdfHeader;
    if (theme != null) body['theme'] = theme;
    if (initialWeekNumber != null) body['initialWeekNumber'] = initialWeekNumber;
    if (phase != null) body['phase'] = phase;
    if (tags != null) body['tags'] = tags;
    if (notes != null) body['notes'] = notes;

    final current = await _offline.readLocalEntityById(
      OfflineEntityType.workoutPlan,
      planId,
    );
    final merged = <String, dynamic>{
      ...?current,
      ...body,
      'id': planId,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await _offline.saveLocalEntity(
      type: OfflineEntityType.workoutPlan,
      id: planId,
      scopeId: merged['customerId']?.toString() ?? current?['customerId']?.toString() ?? '',
      payload: merged,
      localOnly: false,
    );
    return WorkoutPlanApiModel.fromJson(merged);
  }

  Future<void> delete(String planId) async {
    await _offline.markDeleted(OfflineEntityType.workoutPlan, planId);
  }
}

/// Sort key: routine `startDate` from [WorkoutPlanApiModel.planData], else [WorkoutPlanApiModel.updatedAt].
DateTime _sortKeyForPlan(WorkoutPlanApiModel p) {
  try {
    final decoded = jsonDecode(p.planData);
    if (decoded is Map<String, dynamic>) {
      final sd = decoded['startDate'];
      if (sd != null) {
        final d = DateTime.tryParse(sd.toString());
        if (d != null) {
          return DateTime(d.year, d.month, d.day);
        }
      }
    }
  } catch (_) {}
  return p.updatedAt;
}

void _sortPlansByStartDateDesc(List<WorkoutPlanApiModel> plans) {
  plans.sort((a, b) => _sortKeyForPlan(b).compareTo(_sortKeyForPlan(a)));
}

/// Parses [WorkoutPlanApiModel.planData] into [WorkoutRoutine].
WorkoutRoutine planDataToRoutine(String planDataJson) {
  final map = jsonDecode(planDataJson) as Map<String, dynamic>;
  return WorkoutRoutine.fromJson(map);
}
