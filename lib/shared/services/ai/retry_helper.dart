import 'dart:async';

class RetryHelper {
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration baseDelay = const Duration(seconds: 1),
    bool Function(Exception)? shouldRetry,
  }) async {
    Exception? lastException;
    
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await operation().timeout(const Duration(seconds: 60));
      } on TimeoutException catch (e) {
        lastException = e;
        if (i < maxRetries - 1) {
          await Future.delayed(baseDelay * (1 << i));
        }
      } on Exception catch (e) {
        lastException = e;
        final shouldRetryThis = shouldRetry?.call(e) ?? _defaultShouldRetry(e);
        if (!shouldRetryThis || i >= maxRetries - 1) {
          rethrow;
        }
        await Future.delayed(baseDelay * (1 << i));
      }
    }
    
    throw lastException ?? Exception('Max retries exceeded');
  }
  
  static bool _defaultShouldRetry(Exception e) {
    final message = e.toString().toLowerCase();
    return message.contains('network') ||
           message.contains('timeout') ||
           message.contains('503') ||
           message.contains('429');
  }
}
