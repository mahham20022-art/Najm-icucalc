import '../../../../core/error/result.dart';
import '../entities/users_page.dart';
import '../repositories/users_repository.dart';

class FetchUsersUseCase {
  const FetchUsersUseCase(this._repository);
  final UsersRepository _repository;

  Future<Result<UsersPage>> call({String? searchEmail, Object? cursor, int pageSize = 25}) =>
      _repository.fetchUsers(searchEmail: searchEmail, cursor: cursor, pageSize: pageSize);
}
