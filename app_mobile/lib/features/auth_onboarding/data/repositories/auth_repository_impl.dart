import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../../../core/error/result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../auth_error_mapper.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final FirebaseAuthDataSource _dataSource;

  @override
  AuthUser? get currentUser => _toEntity(_dataSource.currentUser);

  @override
  Stream<AuthUser?> get authStateChanges => _dataSource.authStateChanges.map(_toEntity);

  @override
  Future<Result<AuthUser>> signInWithGoogle() =>
      _guard(() async => _requireUser(await _dataSource.signInWithGoogle()));

  @override
  Future<Result<AuthUser>> signInWithApple() =>
      _guard(() async => _requireUser(await _dataSource.signInWithApple()));

  @override
  Future<Result<AuthUser>> signInWithEmail({required String email, required String password}) =>
      _guard(
        () async =>
            _requireUser(await _dataSource.signInWithEmail(email: email, password: password)),
      );

  @override
  Future<Result<AuthUser>> registerWithEmail({required String email, required String password}) =>
      _guard(
        () async =>
            _requireUser(await _dataSource.registerWithEmail(email: email, password: password)),
      );

  @override
  Future<Result<AuthUser>> continueAsGuest() =>
      _guard(() async => _requireUser(await _dataSource.continueAsGuest()));

  @override
  Future<Result<void>> signOut() => _guard(() => _dataSource.signOut());

  AuthUser _requireUser(fb.User? user) {
    final entity = _toEntity(user);
    if (entity == null) {
      // Firebase returning a null user after a "successful" call is not
      // an expected outcome of any of the flows above — treat it the
      // same as an unexpected auth failure rather than silently
      // returning a nonsensical null AuthUser as if it were a success.
      throw StateError('Firebase returned no user after a successful sign-in call.');
    }
    return entity;
  }

  AuthUser? _toEntity(fb.User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      isAnonymous: user.isAnonymous,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      final value = await action();
      return Result.success(value);
    } catch (error) {
      return Result.failure(mapAuthException(error));
    }
  }
}
