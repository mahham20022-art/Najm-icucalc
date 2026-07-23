import '../../../../core/error/result.dart';

/// Local, on-device biometric prompt (Face ID / Touch ID / fingerprint) —
/// deliberately its own interface, not folded into [AuthRepository]:
/// Firebase has no biometric provider. Biometrics gate access to an
/// *already-established* Firebase session; they never produce one.
abstract interface class BiometricAuthenticator {
  /// Whether this device can present a biometric prompt at all (hardware
  /// present, at least one biometric enrolled).
  Future<bool> isAvailable();

  /// Shows the OS biometric prompt. Cancellation and failure both come
  /// back as `Result.failure(BiometricFailure(...))` — the caller (
  /// `RestoreSessionUseCase`, or a manual retry from the Login screen)
  /// decides what to do next; this never signs anyone in or out itself.
  Future<Result<void>> authenticate();
}
