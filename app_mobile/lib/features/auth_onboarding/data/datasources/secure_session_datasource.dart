import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around `flutter_secure_storage` (Keychain on iOS,
/// encrypted storage backed by Keystore on Android) — the only place
/// this feature persists the "remember me" and "biometric enabled"
/// flags. Deliberately not plain `SharedPreferences`: both flags gate
/// whether a real signed-in session is honored, so they belong in
/// hardware-backed secure storage, not a plaintext file.
class SecureSessionDataSource {
  SecureSessionDataSource({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _rememberMeKey = 'auth.remember_me';
  static const _biometricEnabledKey = 'auth.biometric_enabled';

  Future<bool> getRememberMe() async => (await _storage.read(key: _rememberMeKey)) == 'true';

  Future<void> setRememberMe(bool value) => _storage.write(key: _rememberMeKey, value: '$value');

  Future<bool> getBiometricEnabled() async =>
      (await _storage.read(key: _biometricEnabledKey)) == 'true';

  Future<void> setBiometricEnabled(bool value) =>
      _storage.write(key: _biometricEnabledKey, value: '$value');
}
