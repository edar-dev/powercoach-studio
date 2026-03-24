import 'dart:convert';

import '../../../core/di/service_locator.dart';
import '../../../core/network/gymblog_api_client.dart';
import '../../../core/sync/offline_models.dart';
import '../../../core/sync/offline_repository_support.dart';
import 'workout_plan_api_model.dart';
import 'workout_routine_model.dart';

/// Fetches and persists workout plans via GymBlog.API (REST).
class WorkoutPlanRepository {
  WorkoutPlanRepository({GymBlogApiClient? api, OfflineRepositorySupport? offline})
      : _api = api ?? getIt<GymBlogApiClient>(),
        _offline = offline ?? OfflineRepositorySupport();

  final GymBlogApiClient _api;
  final OfflineRepositorySupport _offline;

  /// GET /api/workout-plans/customer/{customerId}
  Future<List<WorkoutPlanApiModel>> getByCustomerId(String customerId) async {
    try {
      final list = await _api.getList('/api/workout-plans/customer/$customerId');
      final models = list
          .whereType<Map<String, dynamic>>()
          .map(WorkoutPlanApiModel.fromJson)
          .toList();
      _sortPlansByStartDateDesc(models);
      for (final plan in models) {
        await _offline.saveLocalEntity(
          type: OfflineEntityType.workoutPlan,
          id: plan.id,
          scopeId: customerId,
          payload: <String, dynamic>{
            'id': plan.id,
            'customerId': plan.customerId,
            'userId': plan.userId,
            'name': plan.name,
            'theme': plan.theme,
            'initialWeekNumber': plan.initialWeekNumber,
            'planData': plan.planData,
            'pdfHeader': plan.pdfHeader,
            'useCustomPdfHeader': plan.useCustomPdfHeader,
            'phase': plan.phase,
            'tags': plan.tags,
            'notes': plan.notes,
            'createdAt': plan.createdAt.toIso8601String(),
            'updatedAt': plan.updatedAt.toIso8601String(),
            'rowVersion': plan.rowVersion,
          },
        );
      }
      return models;
    } catch (_) {
      final local = await _offline.readLocalEntities(
        OfflineEntityType.workoutPlan,
        scopeId: customerId,
      );
      final offlineModels = local.map(WorkoutPlanApiModel.fromJson).toList();
      _sortPlansByStartDateDesc(offlineModels);
      return offlineModels;
    }
  }

  /// GET /api/workout-plans/{id}
  Future<WorkoutPlanApiModel?> getById(String planId) async {
    try {
      final data = await _api.get('/api/workout-plans/$planId');
      final model = WorkoutPlanApiModel.fromJson(data);
      await _offline.saveLocalEntity(
        type: OfflineEntityType.workoutPlan,
        id: model.id,
        scopeId: model.customerId,
        payload: data,
      );
      return model;
    } on GymBlogApiException catch (e) {
      if (e.statusCode == 404) return null;
      final local = await _offline.readLocalEntityById(OfflineEntityType.workoutPlan, planId);
      if (local != null) return WorkoutPlanApiModel.fromJson(local);
      rethrow;
    }
  }

  /// POST /api/workout-plans. Returns created plan (with id).
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
      localOnly: true,
    );
    await _offline.enqueue(
      entityType: OfflineEntityType.workoutPlan,
      entityId: tempId,
      scopeId: customerId,
      opType: OfflineOperationType.create,
      path: '/api/workout-plans',
      payload: body,
    );
    return WorkoutPlanApiModel.fromJson(localPayload);
  }

  /// PUT /api/workout-plans/{id}
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
    final rv = current?['rowVersion'];
    if (rv != null) body['expectedRowVersion'] = rv;
    final merged = <String, dynamic>{
      ...?current,
      ...body,
      'id': planId,
      'updatedAt': DateTime.now().toIso8601String(),
    }..remove('expectedRowVersion');
    await _offline.saveLocalEntity(
      type: OfflineEntityType.workoutPlan,
      id: planId,
      scopeId: merged['customerId']?.toString() ?? current?['customerId']?.toString() ?? '',
      payload: merged,
      localOnly: true,
    );
    await _offline.enqueue(
      entityType: OfflineEntityType.workoutPlan,
      entityId: planId,
      scopeId: merged['customerId']?.toString() ?? '',
      opType: OfflineOperationType.update,
      path: '/api/workout-plans/$planId',
      payload: body,
      baseUpdatedAt: DateTime.tryParse(current?['updatedAt']?.toString() ?? ''),
    );
    return WorkoutPlanApiModel.fromJson(merged);
  }

  Future<void> delete(String planId) async {
    await _offline.markDeleted(OfflineEntityType.workoutPlan, planId);
    await _offline.enqueue(
      entityType: OfflineEntityType.workoutPlan,
      entityId: planId,
      scopeId: '',
      opType: OfflineOperationType.delete,
      path: '/api/workout-plans/$planId',
      payload: <String, dynamic>{},
    );
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
