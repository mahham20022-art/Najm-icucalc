import '../../../../core/error/result.dart';
import '../repositories/users_repository.dart';

class SetUserRoleUseCase {
  const SetUserRoleUseCase(this._repository);
  final UsersRepository _repository;

  Future<Result<void>> call({required String uid, required String role}) =>
      _repository.setRole(uid: uid, role: role);
}
