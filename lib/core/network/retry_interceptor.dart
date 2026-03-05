import 'package:dio/dio.dart';

import 'retry_policy.dart';

/// Dio interceptor that retries failed requests according to [RetryPolicy].
class RetryInterceptor extends Interceptor {
  RetryInterceptor({required this.dio, this.policy = const RetryPolicy()});

  final Dio dio;
  final RetryPolicy policy;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final attempt = (options.extra['retry_count'] as int?) ?? 0;

    if (attempt < policy.maxRetryCount && policy.shouldRetry(err)) {
      options.extra['retry_count'] = attempt + 1;
      final delay = policy.delayForAttempt(attempt);
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
