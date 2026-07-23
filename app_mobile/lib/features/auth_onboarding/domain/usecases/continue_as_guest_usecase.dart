import '../../../../core/error/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class ContinueAsGuestUseCase {
  const ContinueAsGuestUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<AuthUser>> call() => _repository.continueAsGuest();
}
