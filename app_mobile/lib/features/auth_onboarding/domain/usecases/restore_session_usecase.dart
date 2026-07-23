import '../../../../core/error/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/biometric_authenticator.dart';
import '../repositories/session_repository.dart';

/// The three outcomes of resolving a cold-start session — deliberately
/// not just `Result<AuthUser?>`: [SessionLocked] needs to carry the user
/// too, so the Login screen can offer "Use Face ID" as a retry rather
/// than forcing a full re-login when only the biometric prompt failed.
sealed class SessionRestoreOutcome {
  const SessionRestoreOutcome();
}

class NoSession extends SessionRestoreOutcome {
  const NoSession();
}

class SessionRestored extends SessionRestoreOutcome {
  const SessionRestored(this.user);
  final AuthUser user;
}

class SessionLocked extends SessionRestoreOutcome {
  const SessionLocked(this.user);
  final AuthUser user;
}

/// Runs once at Splash (`MED100_UI_UX_SPEC.md` §1) to decide whether a
/// persisted Firebase session should actually be honored:
///
/// 1. No Firebase user at all → [NoSession].
/// 2. A user exists, but "Remember Me" was off → sign out (a stale
///    session the user asked not to keep) → [NoSession].
/// 3. A user exists, Remember Me is on, biometric lock isn't enabled →
///    [SessionRestored] immediately.
/// 4. A user exists, Remember Me is on, biometric lock *is* enabled →
///    prompt; success → [SessionRestored], failure/cancel → [SessionLocked]
///    (the Firebase session is deliberately left intact here — a
///    cancelled Face ID prompt shouldn't force a full re-login).
class RestoreSessionUseCase {
  const RestoreSessionUseCase(this._authRepository, this._sessionRepository, this._biometrics);

  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;
  final BiometricAuthenticator _biometrics;

  Future<Result<SessionRestoreOutcome>> call() async {
    final user = _authRepository.currentUser;
    if (user == null) return const Result.success(NoSession());

    final rememberMe = await _sessionRepository.isRememberMeEnabled();
    if (!rememberMe) {
      await _authRepository.signOut();
      return const Result.success(NoSession());
    }

    final biometricEnabled = await _sessionRepository.isBiometricEnabled();
    if (!biometricEnabled) return Result.success(SessionRestored(user));

    if (!await _biometrics.isAvailable()) {
      // The user opted into biometric lock on a device that can no
      // longer honor it (e.g. all biometrics were un-enrolled since) —
      // fail open here rather than permanently locking them out with no
      // way to satisfy a prompt that can't be shown.
      return Result.success(SessionRestored(user));
    }

    final biometricResult = await _biometrics.authenticate();
    return biometricResult.when(
      success: (_) => Result.success(SessionRestored(user)),
      failure: (_) => Result.success(SessionLocked(user)),
    );
  }
}
