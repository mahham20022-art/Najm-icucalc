/// Secure, persisted session preferences — backed by platform Keychain
/// (iOS) / Keystore-encrypted storage (Android) via `flutter_secure_storage`
/// in the data layer, not plain `SharedPreferences`, since both flags
/// gate whether a real signed-in session is honored on next launch.
abstract interface class SessionRepository {
  /// Whether a persisted Firebase session should be honored on next
  /// launch. If `false`, [RestoreSessionUseCase] signs the user out
  /// instead of silently resuming — the mobile Firebase SDK otherwise
  /// persists sessions unconditionally, with no built-in "forget me".
  Future<bool> isRememberMeEnabled();

  Future<void> setRememberMeEnabled(bool value);

  /// Whether a resumed session must additionally pass a biometric prompt
  /// before the app grants entry (`RestoreSessionUseCase`) — a device
  /// preference, independent of which account is signed in.
  Future<bool> isBiometricEnabled();

  Future<void> setBiometricEnabled(bool value);
}
