import '../repositories/admin_auth_repository.dart';

class AdminSignOutUseCase {
  const AdminSignOutUseCase(this._repository);
  final AdminAuthRepository _repository;

  Future<void> call() => _repository.signOut();
}
