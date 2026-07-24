import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/firebase_admin_auth_datasource.dart';
import 'data/repositories/admin_auth_repository_impl.dart';
import 'domain/repositories/admin_auth_repository.dart';
import 'domain/usecases/admin_sign_in_usecase.dart';
import 'domain/usecases/admin_sign_out_usecase.dart';
import 'domain/usecases/watch_admin_auth_state_usecase.dart';

final firebaseAdminAuthDataSourceProvider = Provider<FirebaseAdminAuthDataSource>((ref) {
  return FirebaseAdminAuthDataSource();
});

final adminAuthRepositoryProvider = Provider<AdminAuthRepository>((ref) {
  return AdminAuthRepositoryImpl(ref.watch(firebaseAdminAuthDataSourceProvider));
});

final watchAdminAuthStateUseCaseProvider = Provider<WatchAdminAuthStateUseCase>((ref) {
  return WatchAdminAuthStateUseCase(ref.watch(adminAuthRepositoryProvider));
});

final adminSignInUseCaseProvider = Provider<AdminSignInUseCase>((ref) {
  return AdminSignInUseCase(ref.watch(adminAuthRepositoryProvider));
});

final adminSignOutUseCaseProvider = Provider<AdminSignOutUseCase>((ref) {
  return AdminSignOutUseCase(ref.watch(adminAuthRepositoryProvider));
});
