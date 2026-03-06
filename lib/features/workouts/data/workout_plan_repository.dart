import 'dart:convert';

import '../../../core/network/gymblog_api_client.dart';
import 'workout_plan_api_model.dart';
import 'workout_routine_model.dart';

/// Fetches and persists workout plans via GymBlog.API (REST).
class WorkoutPlanRepository {
  WorkoutPlanRepository() : _api = GymBlogApiClient();

  final GymBlogApiClient _api;

  /// GET /api/workout-plans/customer/{customerId}
  Future<List<WorkoutPlanApiModel>> getByCustomerId(String customerId) async {
    final list = await _api.getList('/api/workout-plans/customer/$customerId');
    return list
        .map((e) => WorkoutPlanApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/workout-plans/{id}
  Future<WorkoutPlanApiModel?> getById(String planId) async {
    try {
      final data = await _api.get('/api/workout-plans/$planId');
      return WorkoutPlanApiModel.fromJson(data);
    } on GymBlogApiException catch (e) {
      if (e.statusCode == 404) return null;
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

    final data = await _api.post('/api/workout-plans', body);
    return WorkoutPlanApiModel.fromJson(data);
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

    final data = await _api.put('/api/workout-plans/$planId', body);
    return WorkoutPlanApiModel.fromJson(data);
  }

  Future<void> delete(String planId) async {
    await _api.delete('/api/workout-plans/$planId');
  }
}

/// Parses [WorkoutPlanApiModel.planData] into [WorkoutRoutine].
WorkoutRoutine planDataToRoutine(String planDataJson) {
  final map = jsonDecode(planDataJson) as Map<String, dynamic>;
  return WorkoutRoutine.fromJson(map);
}
