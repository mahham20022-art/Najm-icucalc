import '../../../../core/error/result.dart';
import '../auth_validators.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailUseCase {
  const SignInWithEmailUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<AuthUser>> call({required String email, required String password}) async {
    final error = AuthValidators.email(email) ?? AuthValidators.passwordNotEmpty(password);
    if (error != null) return Result.failure(error);

    return _repository.signInWithEmail(email: email.trim(), password: password);
  }
}
