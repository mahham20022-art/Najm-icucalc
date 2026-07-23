import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/biometric_datasource.dart';
import 'data/datasources/firebase_auth_datasource.dart';
import 'data/datasources/secure_session_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/biometric_authenticator_impl.dart';
import 'data/repositories/session_repository_impl.dart';
import 'domain/entities/auth_user.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/biometric_authenticator.dart';
import 'domain/repositories/session_repository.dart';
import 'domain/usecases/continue_as_guest_usecase.dart';
import 'domain/usecases/register_with_email_usecase.dart';
import 'domain/usecases/restore_session_usecase.dart';
import 'domain/usecases/sign_in_with_apple_usecase.dart';
import 'domain/usecases/sign_in_with_email_usecase.dart';
import 'domain/usecases/sign_in_with_google_usecase.dart';
import 'domain/usecases/sign_out_usecase.dart';

// DI graph for authentication, following `MED100_ARCHITECTURE.md` §6:
// dataSourceProvider -> repositoryProvider (the only providers allowed to
// reference Firebase/platform SDK types) -> useCaseProvider ->
// viewModelProvider (`presentation/viewmodels/auth_view_model.dart`).

final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSource();
});

final secureSessionDataSourceProvider = Provider<SecureSessionDataSource>((ref) {
  return SecureSessionDataSource();
});

final biometricDataSourceProvider = Provider<BiometricDataSource>((ref) {
  return BiometricDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(firebaseAuthDataSourceProvider));
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepositoryImpl(ref.watch(secureSessionDataSourceProvider));
});

final biometricAuthenticatorProvider = Provider<BiometricAuthenticator>((ref) {
  return BiometricAuthenticatorImpl(ref.watch(biometricDataSourceProvider));
});

/// Reactive mirror of the repository's auth state — `AuthViewModel`
/// listens to this so a sign-out that happens elsewhere (or a revoked
/// token) is reflected in the UI immediately, distinct from the one-shot
/// `RestoreSessionUseCase` decision made at Splash.
final authStateChangesProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((ref) {
  return SignInWithGoogleUseCase(ref.watch(authRepositoryProvider));
});

final signInWithAppleUseCaseProvider = Provider<SignInWithAppleUseCase>((ref) {
  return SignInWithAppleUseCase(ref.watch(authRepositoryProvider));
});

final signInWithEmailUseCaseProvider = Provider<SignInWithEmailUseCase>((ref) {
  return SignInWithEmailUseCase(ref.watch(authRepositoryProvider));
});

final registerWithEmailUseCaseProvider = Provider<RegisterWithEmailUseCase>((ref) {
  return RegisterWithEmailUseCase(ref.watch(authRepositoryProvider));
});

final continueAsGuestUseCaseProvider = Provider<ContinueAsGuestUseCase>((ref) {
  return ContinueAsGuestUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider), ref.watch(sessionRepositoryProvider));
});

final restoreSessionUseCaseProvider = Provider<RestoreSessionUseCase>((ref) {
  return RestoreSessionUseCase(
    ref.watch(authRepositoryProvider),
    ref.watch(sessionRepositoryProvider),
    ref.watch(biometricAuthenticatorProvider),
  );
});
