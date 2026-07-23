/// Exponential-backoff retry, provider-agnostic — reused for both
/// OpenAI and Claude's non-streaming calls. Only wraps [AiProvider.complete],
/// never [AiProvider.completeStream]: retrying a stream after some
/// tokens have already been yielded to a listener would either duplicate
/// or lose content, so a mid-stream failure is surfaced once, not
/// retried (see `AiEngineRepositoryImpl.generateStream`).
class RetryPolicy {
  const RetryPolicy({this.maxAttempts = 3, this.initialDelay = const Duration(milliseconds: 500)});

  final int maxAttempts;
  final Duration initialDelay;

  /// Runs [action], retrying with doubling delay on failures where
  /// [retryIf] returns `true` (default: always retry) until
  /// [maxAttempts] is reached, then rethrows the last error.
  Future<T> run<T>(Future<T> Function() action, {bool Function(Object error)? retryIf}) async {
    var attempt = 0;
    var delay = initialDelay;
    while (true) {
      attempt++;
      try {
        return await action();
      } catch (error) {
        final shouldRetry = attempt < maxAttempts && (retryIf?.call(error) ?? true);
        if (!shouldRetry) rethrow;
        await Future<void>.delayed(delay);
        delay *= 2;
      }
    }
  }
}
