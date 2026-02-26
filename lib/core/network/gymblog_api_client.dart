import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// HTTP client for GymBlog.API. Uses Supabase session token for auth.
/// Requires GYMBLOG_API_URL in .env (no-op / "not configured" if missing).
class GymBlogApiClient {
  GymBlogApiClient() : _dio = _createDio();

  static String? get baseUrl {
    final url = dotenv.env['GYMBLOG_API_URL']?.trim();
    return (url != null && url.isNotEmpty) ? url : null;
  }

  static bool get isConfigured => baseUrl != null;

  final Dio _dio;

  static Dio _createDio() {
    final base = baseUrl ?? '';
    final dio = Dio(
      BaseOptions(
        baseUrl: base,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
        handler.next(options);
      },
      onError: (err, handler) {
        handler.next(err);
      },
    ));
    return dio;
  }

  void _ensureConfigured() {
    if (!isConfigured) {
      throw GymBlogApiException('API not configured', 0);
    }
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    _ensureConfigured();
    try {
      final response = await _dio.get<List<dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      final data = response.data;
      return data is List<dynamic> ? data : <dynamic>[];
    } on DioException catch (e) {
      throw _fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> get(String path) async {
    _ensureConfigured();
    try {
      final response = await _dio.get<Map<String, dynamic>>(path);
      final data = response.data;
      if (data == null) throw GymBlogApiException('Empty response', 0);
      return data;
    } on DioException catch (e) {
      throw _fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, [dynamic body]) async {
    _ensureConfigured();
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      final data = response.data;
      if (data == null) throw GymBlogApiException('Empty response', 0);
      return data;
    } on DioException catch (e) {
      throw _fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> put(String path, [dynamic body]) async {
    _ensureConfigured();
    try {
      final response = await _dio.put<Map<String, dynamic>>(path, data: body);
      final data = response.data;
      if (data == null) throw GymBlogApiException('Empty response', 0);
      return data;
    } on DioException catch (e) {
      throw _fromDioException(e);
    }
  }

  Future<void> delete(String path) async {
    _ensureConfigured();
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw _fromDioException(e);
    }
  }

  GymBlogApiException _fromDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return GymBlogApiException('Connection timeout', 0);
    }
    if (e.type == DioExceptionType.badResponse && e.response != null) {
      final statusCode = e.response!.statusCode ?? 0;
      final data = e.response!.data;
      String message = 'Server error';
      if (data is Map && data['error'] != null) {
        message = data['error'].toString();
      } else if (e.response?.statusMessage != null) {
        message = e.response!.statusMessage!;
      }
      if (statusCode == 401) {
        message = 'Session expired or unauthorized';
      }
      return GymBlogApiException(message, statusCode);
    }
    if (e.type == DioExceptionType.connectionError) {
      return GymBlogApiException('No internet connection', 0);
    }
    return GymBlogApiException(e.message ?? 'Network error', 0);
  }
}

class GymBlogApiException implements Exception {
  GymBlogApiException(this.message, this.statusCode);
  final String message;
  final int statusCode;
  @override
  String toString() => 'GymBlogApiException: $message ($statusCode)';
}
