import 'package:local_auth/local_auth.dart';

/// Thin wrapper around `local_auth` — the only place this feature
/// touches that package directly.
class BiometricDataSource {
  BiometricDataSource({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  Future<bool> isAvailable() async {
    final supported = await _localAuth.isDeviceSupported();
    if (!supported) return false;
    return _localAuth.canCheckBiometrics;
  }

  /// Throws on hardware/platform errors; returns `false` (not an
  /// exception) if the user cancels or fails the prompt — both are
  /// mapped to [BiometricFailure] by the repository either way.
  Future<bool> authenticate() {
    return _localAuth.authenticate(
      localizedReason: 'Authenticate to sign in to Med100',
      biometricOnly: true,
    );
  }
}
