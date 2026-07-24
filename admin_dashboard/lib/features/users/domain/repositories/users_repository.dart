import '../../../../core/error/result.dart';
import '../entities/account_status.dart';
import '../entities/users_page.dart';

abstract interface class UsersRepository {
  /// [searchEmail], when non-empty, narrows to emails with that exact
  /// prefix (a Firestore range query) — there is no full-text search
  /// here, a deliberate simplification for this first pass.
  /// [cursor] is a previous [UsersPage.cursor]; omit for the first page.
  Future<Result<UsersPage>> fetchUsers({String? searchEmail, Object? cursor, int pageSize = 25});

  /// A plain Firestore field write (`accountStatus`), not an Auth
  /// custom claim — safe for an authenticated admin client to perform
  /// directly, gated by Firestore Security Rules on the `role` claim.
  Future<Result<void>> setAccountStatus({required String uid, required AccountStatus status});

  /// Unlike [setAccountStatus], a user's `role` is also mirrored into a
  /// Firebase Auth custom claim (`MED100_DATABASE_DESIGN.md` §1), which
  /// only the Admin SDK can set — never directly writable from any
  /// client, this one included. This calls a Cloud Functions callable
  /// that must exist server-side; see
  /// `FirestoreUsersRepositoryImpl.setRole`'s doc comment for this
  /// feature's foundation-stage gap.
  Future<Result<void>> setRole({required String uid, required String role});
}
