import '../../../../core/error/result.dart';
import '../entities/account_status.dart';
import '../repositories/users_repository.dart';

class SetAccountStatusUseCase {
  const SetAccountStatusUseCase(this._repository);
  final UsersRepository _repository;

  Future<Result<void>> call({required String uid, required AccountStatus status}) =>
      _repository.setAccountStatus(uid: uid, status: status);
}
