import '../../../../core/error/result.dart';
import '../entities/admin_user.dart';

abstract interface class AdminAuthRepository {
  /// `null` when signed out. A non-null [AdminUser] with
  /// `role == AdminRole.none` (or `.learner`) is a real Firebase account
  /// that simply isn't staff — the router's gate turns that away, this
  /// stream only ever reports the truth.
  Stream<AdminUser?> watchAuthState();

  Future<Result<AdminUser>> signInWithEmail({required String email, required String password});

  Future<void> signOut();
}
