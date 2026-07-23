import '../../../../core/error/result.dart';
import '../auth_validators.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class RegisterWithEmailUseCase {
  const RegisterWithEmailUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final error =
        AuthValidators.email(email) ??
        AuthValidators.passwordStrength(password) ??
        AuthValidators.passwordsMatch(password, confirmPassword);
    if (error != null) return Result.failure(error);

    return _repository.registerWithEmail(email: email.trim(), password: password);
  }
}
