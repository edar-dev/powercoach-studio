import 'dart:math';

import 'package:dio/dio.dart';

/// Polly-style retry policy for HTTP requests.
/// Retries on transient failures: timeouts, connection errors, 5xx, 408, 429.
class RetryPolicy {
  const RetryPolicy({
    this.maxRetryCount = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 10),
    this.useExponentialBackoff = true,
    this.jitter = true,
  });

  final int maxRetryCount;
  final Duration initialDelay;
  final Duration maxDelay;
  final bool useExponentialBackoff;
  final bool jitter;

  /// Whether this error is worth retrying (transient).
  bool shouldRetry(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }
    if (error.type == DioExceptionType.badResponse && error.response != null) {
      final status = error.response!.statusCode ?? 0;
      // 408 Request Timeout, 429 Too Many Requests, 5xx server errors
      return status == 408 || status == 429 || (status >= 500 && status < 600);
    }
    return false;
  }

  /// Delay before the given attempt (0-based). Uses exponential backoff and optional jitter.
  Duration delayForAttempt(int attempt) {
    if (attempt <= 0) {
      return initialDelay;
    }
    Duration d = initialDelay;
    if (useExponentialBackoff) {
      for (int i = 0; i < attempt; i++) {
        d = Duration(
          milliseconds: (d.inMilliseconds * 2).clamp(0, maxDelay.inMilliseconds),
        );
        if (d > maxDelay) {
          d = maxDelay;
          break;
        }
      }
    }
    if (jitter) {
      final jitterMs = (d.inMilliseconds * 0.2 * (1 - _jitterFactor())).round();
      d = Duration(milliseconds: (d.inMilliseconds + jitterMs).clamp(0, maxDelay.inMilliseconds));
    }
    return d;
  }

  static final Random _rnd = Random();

  double _jitterFactor() {
    return _rnd.nextDouble();
  }
}
