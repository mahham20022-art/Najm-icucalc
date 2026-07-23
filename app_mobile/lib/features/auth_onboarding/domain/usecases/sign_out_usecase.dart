import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';
import '../repositories/session_repository.dart';

/// Signs out of Firebase *and* clears the persisted "remember me" flag —
/// deliberately, so the next cold start doesn't silently resume a session
/// the user just explicitly ended. The biometric-enabled preference is
/// left untouched: it's a device preference ("I want to use Face ID for
/// this app"), not tied to any one account, so it should still apply if
/// the same or a different user signs back in.
class SignOutUseCase {
  const SignOutUseCase(this._authRepository, this._sessionRepository);

  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;

  Future<Result<void>> call() async {
    final result = await _authRepository.signOut();
    if (result.isSuccess) {
      await _sessionRepository.setRememberMeEnabled(false);
    }
    return result;
  }
}
