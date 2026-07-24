import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/admin_role.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/admin_auth_repository.dart';
import '../datasources/firebase_admin_auth_datasource.dart';

class AdminAuthRepositoryImpl implements AdminAuthRepository {
  const AdminAuthRepositoryImpl(this._dataSource);
  final FirebaseAdminAuthDataSource _dataSource;

  @override
  Stream<AdminUser?> watchAuthState() {
    return _dataSource.idTokenChanges().asyncMap((user) async {
      if (user == null) return null;
      final roleClaim = await _dataSource.getRoleClaim(user);
      return AdminUser(
        uid: user.uid,
        email: user.email,
        role: AdminRoleAccess.fromClaim(roleClaim),
      );
    });
  }

  @override
  Future<Result<AdminUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.signInWithEmail(email: email, password: password);
      // Force-refresh: a role just granted moments ago (e.g. a brand new
      // admin's very first sign-in) must not read as `none` because a
      // stale cached token was used instead.
      final role = AdminRoleAccess.fromClaim(
        await _dataSource.getRoleClaim(user, forceRefresh: true),
      );

      // No `canAccessDashboard` check (and no force sign-out) here on
      // purpose: a fresh sign-in and an already-persisted session that
      // no longer qualifies must be handled identically, and the
      // router's redirect guard already does that uniformly for
      // `AdminAuthAuthenticated` regardless of *how* it arrived — see
      // `NotAuthorizedScreen`'s doc comment for the same reasoning
      // reversed. Special-casing it here too was a real bug: this
      // method's own `await _dataSource.signOut()` would race the
      // `watchAuthState()` listener the ViewModel keeps running in the
      // background, which could clobber the freshly-set error state
      // back to a bare "unauthenticated" the moment the sign-out's
      // `idTokenChanges` event arrived — silently swallowing the "why."
      return Result.success(AdminUser(uid: user.uid, email: user.email, role: role));
    } on FirebaseAuthException catch (error) {
      return switch (error.code) {
        'wrong-password' ||
        'user-not-found' ||
        'invalid-credential' => const Result.failure(InvalidCredentialsFailure()),
        _ => Result.failure(ServerFailure(error.message ?? 'Sign-in failed.')),
      };
    } catch (_) {
      return const Result.failure(ServerFailure());
    }
  }

  @override
  Future<void> signOut() => _dataSource.signOut();
}
