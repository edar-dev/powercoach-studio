import 'package:dio/dio.dart';

import 'hevy_api_models.dart';
import 'hevy_settings_store.dart';

/// HTTP client for Hevy public API (https://api.hevyapp.com/docs).
class HevyApiClient {
  HevyApiClient({Dio? dio, HevySettingsStore? settings})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.hevyapp.com',
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 60),
              ),
            ),
        _settings = settings ?? HevySettingsStore.instance;

  final Dio _dio;
  final HevySettingsStore _settings;

  static const _maxPageSize = 100;

  Future<String?> _apiKey() => _settings.getApiKey();

  Future<Map<String, String>> _headers() async {
    final key = await _apiKey();
    if (key == null || key.isEmpty) {
      throw HevyApiException('Hevy API key not configured', statusCode: 0);
    }
    return {'api-key': key};
  }

  /// Fetches all exercise templates (paginated).
  Future<List<HevyExerciseTemplateDto>> fetchAllExerciseTemplates({
    void Function(int page, int pageCount)? onPage,
  }) async {
    final headers = await _headers();
    final all = <HevyExerciseTemplateDto>[];
    var page = 1;
    var pageCount = 1;

    while (page <= pageCount) {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/exercise_templates',
        queryParameters: {'page': page, 'pageSize': _maxPageSize},
        options: Options(headers: headers),
      );
      final data = response.data;
      if (data == null) {
        throw HevyApiException('Empty response from Hevy', statusCode: response.statusCode);
      }
      pageCount = (data['page_count'] as num?)?.toInt() ?? 1;
      onPage?.call(page, pageCount);
      final list = data['exercise_templates'] as List<dynamic>? ?? [];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          all.add(HevyExerciseTemplateDto.fromJson(item));
        }
      }
      page++;
    }
    return all;
  }

  /// Creates a routine in the coach's Hevy account.
  Future<Map<String, dynamic>> createRoutine(Map<String, dynamic> body) async {
    final headers = await _headers();
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/routines',
      data: body,
      options: Options(headers: headers),
    );
    return response.data ?? {};
  }

  /// Creates a logged workout in the coach's Hevy account.
  Future<Map<String, dynamic>> createWorkout(Map<String, dynamic> body) async {
    final headers = await _headers();
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/workouts',
      data: body,
      options: Options(headers: headers),
    );
    return response.data ?? {};
  }

  /// Lightweight connectivity check.
  Future<void> testConnection() async {
    await fetchAllExerciseTemplates(onPage: (_, __) {});
  }

  static Never handleDioError(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      final msg = e.response?.data?.toString() ?? e.message ?? 'Network error';
      throw HevyApiException(msg, statusCode: status);
    }
    throw HevyApiException(e.toString());
  }
}
