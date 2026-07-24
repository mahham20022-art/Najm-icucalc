import '../entities/admin_user.dart';
import '../repositories/admin_auth_repository.dart';

class WatchAdminAuthStateUseCase {
  const WatchAdminAuthStateUseCase(this._repository);
  final AdminAuthRepository _repository;

  Stream<AdminUser?> call() => _repository.watchAuthState();
}
