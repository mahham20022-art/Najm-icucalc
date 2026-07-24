import '../../../../core/error/result.dart';
import '../entities/admin_user.dart';
import '../repositories/admin_auth_repository.dart';

class AdminSignInUseCase {
  const AdminSignInUseCase(this._repository);
  final AdminAuthRepository _repository;

  Future<Result<AdminUser>> call({required String email, required String password}) =>
      _repository.signInWithEmail(email: email, password: password);
}
