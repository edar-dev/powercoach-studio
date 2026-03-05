import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import 'retry_policy.dart';

/// Callback when a retry is about to happen: (error, attemptIndex, delay).
typedef RetryCallback = void Function(DioException error, int attempt, Duration delay);

/// Dio interceptor that retries failed requests according to [RetryPolicy].
/// Optionally report retries via [onRetry] (e.g. debugPrint or Sentry breadcrumb).
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.policy = const RetryPolicy(),
    this.onRetry,
  });

  final Dio dio;
  final RetryPolicy policy;

  /// Called before each retry (attempt is 0-based index of the retry about to happen).
  final RetryCallback? onRetry;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final attempt = (options.extra['retry_count'] as int?) ?? 0;

    if (attempt < policy.maxRetryCount && policy.shouldRetry(err)) {
      options.extra['retry_count'] = attempt + 1;
      final delay = policy.delayForAttempt(attempt);
      onRetry?.call(err, attempt, delay);
      if (kDebugMode) {
        debugPrint(
          'powercoach-studio: API retry attempt ${attempt + 1}/${policy.maxRetryCount} '
          'for ${options.method} ${options.path} after ${err.type} (delay ${delay.inMilliseconds}ms)',
        );
      }
      Future.delayed(delay, () async {
        try {
          final response = await dio.fetch(options);
          handler.resolve(response);
        } catch (e) {
          handler.reject(e is DioException ? e : DioException(requestOptions: options, error: e));
        }
      });
    } else {
      handler.next(err);
    }
  }
}
