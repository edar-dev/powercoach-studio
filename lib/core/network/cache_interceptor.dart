import 'package:dio/dio.dart';

import 'api_cache.dart';

/// Dio interceptor that caches GET responses and invalidates on mutation (POST/PUT/DELETE).
/// Set [options.extra['skip_cache']] = true to bypass cache for a single request.
/// Use [pathTtl] to override TTL per path (e.g. shorter for list, longer for static).
class CacheInterceptor extends Interceptor {
  CacheInterceptor({
    required this.cache,
    this.cacheGet = true,
    this.pathTtl,
  });

  final ApiCache cache;
  final bool cacheGet;

  /// Optional TTL per path. Return null to use cache default. Example: (path) => path.contains('/list') ? Duration(minutes: 2) : null.
  final Duration? Function(String path)? pathTtl;

  static String _cacheKey(RequestOptions options) {
    final path = options.path;
    final q = options.queryParameters;
    if (q.isEmpty) {
      return path;
    }
    final query = q.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$path?$query';
  }

  /// Prefix for invalidation. /api/customers/123 -> /api/customers; /api/customers -> /api/customers.
  static String _invalidationPrefix(RequestOptions options) {
    final path = options.path;
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.length <= 1) {
      return path;
    }
    final last = segments.last;
    final looksLikeId = RegExp(r'^[\d-]+$').hasMatch(last) ||
        RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(last);
    if (looksLikeId) {
      return '/${segments.sublist(0, segments.length - 1).join('/')}';
    }
    return path;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final skipCache = options.extra['skip_cache'] == true;
    if (!cacheGet || options.method.toUpperCase() != 'GET' || skipCache) {
      handler.next(options);
      return;
    }
    final key = _cacheKey(options);
    final cached = cache.get(key);
    if (cached != null) {
      handler.resolve(
        Response(
          requestOptions: options,
          data: cached,
          statusCode: 200,
        ),
      );
      return;
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final skipCache = options.extra['skip_cache'] == true;
    if (options.method.toUpperCase() == 'GET' && response.statusCode == 200 && response.data != null && !skipCache) {
      final key = _cacheKey(options);
      final ttl = pathTtl?.call(options.path);
      cache.set(key, response.data, ttl: ttl);
    } else if (options.method.toUpperCase() != 'GET') {
      cache.invalidatePrefix(_invalidationPrefix(options));
    }
    handler.next(response);
  }
}
