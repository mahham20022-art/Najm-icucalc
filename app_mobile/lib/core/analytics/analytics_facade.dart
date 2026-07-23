import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider-agnostic analytics contract, per `MED100_ARCHITECTURE.md` §6 —
/// ViewModels depend on this interface, never on `firebase_analytics`
/// directly, so the underlying provider can change without touching
/// feature code.
abstract interface class AnalyticsFacade {
  Future<void> logEvent(String name, {Map<String, Object?> parameters});

  Future<void> setUserProperty(String name, String? value);
}

/// No-op implementation used as the default so the app runs (and widget
/// tests pass) before a real Firebase-backed implementation is wired up
/// at the composition root (`app/bootstrap`).
class NoopAnalyticsFacade implements AnalyticsFacade {
  const NoopAnalyticsFacade();

  @override
  Future<void> logEvent(String name, {Map<String, Object?> parameters = const {}}) async {}

  @override
  Future<void> setUserProperty(String name, String? value) async {}
}

final analyticsProvider = Provider<AnalyticsFacade>((ref) {
  return const NoopAnalyticsFacade();
});
