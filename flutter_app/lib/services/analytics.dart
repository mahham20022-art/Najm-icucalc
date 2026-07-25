import 'package:firebase_analytics/firebase_analytics.dart';

/// Firebase Analytics wrapper. All calls are safe if Firebase failed to init
/// (e.g. running without google-services.json) — errors are swallowed.
class Analytics {
  static FirebaseAnalytics? _analytics;
  static bool _enabled = false;

  static void enable() {
    try {
      _analytics = FirebaseAnalytics.instance;
      _enabled = true;
    } catch (_) {
      _enabled = false;
    }
  }

  static Future<void> screen(String name) async {
    if (!_enabled) return;
    try { await _analytics!.logScreenView(screenName: name); } catch (_) {}
  }

  static Future<void> event(String name, [Map<String, Object>? params]) async {
    if (!_enabled) return;
    try {
      await _analytics!.logEvent(
        name: name,
        parameters: params,
      );
    } catch (_) {}
  }
}
