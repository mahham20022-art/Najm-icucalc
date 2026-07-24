import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/firestore_users_datasource.dart';
import 'data/repositories/firestore_users_repository_impl.dart';
import 'domain/repositories/users_repository.dart';
import 'domain/usecases/fetch_users_usecase.dart';
import 'domain/usecases/set_account_status_usecase.dart';
import 'domain/usecases/set_user_role_usecase.dart';

final firestoreUsersDataSourceProvider = Provider<FirestoreUsersDataSource>((ref) {
  return FirestoreUsersDataSource();
});

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return FirestoreUsersRepositoryImpl(ref.watch(firestoreUsersDataSourceProvider));
});

final fetchUsersUseCaseProvider = Provider<FetchUsersUseCase>((ref) {
  return FetchUsersUseCase(ref.watch(usersRepositoryProvider));
});

final setAccountStatusUseCaseProvider = Provider<SetAccountStatusUseCase>((ref) {
  return SetAccountStatusUseCase(ref.watch(usersRepositoryProvider));
});

final setUserRoleUseCaseProvider = Provider<SetUserRoleUseCase>((ref) {
  return SetUserRoleUseCase(ref.watch(usersRepositoryProvider));
});
