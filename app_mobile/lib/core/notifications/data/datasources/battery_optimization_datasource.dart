import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Android's Doze/App Standby battery optimization can silently drop a
/// scheduled alarm — the OS decides the app hasn't been used recently
/// enough to bother waking it. Exempting Med100 is what makes the daily
/// reminder actually reliable rather than "usually fires." A no-op on
/// every other platform, which has no equivalent concept.
class BatteryOptimizationDataSource {
  Future<bool> isIgnoringBatteryOptimizations() async {
    if (!_isAndroid) return true;
    return Permission.ignoreBatteryOptimizations.status.then((status) => status.isGranted);
  }

  /// Opens the OS's "ignore battery optimizations" system dialog for
  /// this app. Returns whether the exemption ended up granted.
  Future<bool> requestIgnoreBatteryOptimizations() async {
    if (!_isAndroid) return true;
    final status = await Permission.ignoreBatteryOptimizations.request();
    return status.isGranted;
  }

  /// `kIsWeb` must be checked first: on Flutter web, `defaultTargetPlatform`
  /// reflects the browser's OS (so an Android phone's browser reports
  /// `TargetPlatform.android`), but `permission_handler`'s web backend
  /// throws for this permission since it has no browser equivalent.
  bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}
