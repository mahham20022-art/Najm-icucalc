import 'dart:collection';

/// A per-provider sliding-window rate limiter — protects API budget and
/// vendor ToS limits by rejecting a request client-side, before it's
/// ever sent, rather than only reacting after a vendor 429. One instance
/// per [AiProvider]; a shared instance would let a slow provider's
/// backlog block requests to a fast one.
class RateLimiter {
  RateLimiter({required this.maxRequests, required this.window});

  final int maxRequests;
  final Duration window;
  final Queue<DateTime> _requestTimestamps = Queue<DateTime>();

  /// Returns `true` and records the attempt if under the limit; returns
  /// `false` without recording anything if not — callers must not
  /// proceed with the request on a `false` result.
  bool tryAcquire() {
    final now = DateTime.now();
    while (_requestTimestamps.isNotEmpty && now.difference(_requestTimestamps.first) > window) {
      _requestTimestamps.removeFirst();
    }
    if (_requestTimestamps.length >= maxRequests) return false;
    _requestTimestamps.add(now);
    return true;
  }
}
