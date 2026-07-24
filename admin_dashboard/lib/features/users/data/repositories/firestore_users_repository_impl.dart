import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart' hide Result;

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../auth/domain/entities/admin_role.dart';
import '../../domain/entities/account_status.dart';
import '../../domain/entities/managed_user.dart';
import '../../domain/entities/subscription_tier.dart';
import '../../domain/entities/users_page.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/firestore_users_datasource.dart';

class FirestoreUsersRepositoryImpl implements UsersRepository {
  const FirestoreUsersRepositoryImpl(this._dataSource);
  final FirestoreUsersDataSource _dataSource;

  @override
  Future<Result<UsersPage>> fetchUsers({
    String? searchEmail,
    Object? cursor,
    int pageSize = 25,
  }) async {
    try {
      // `cursor` crosses the domain boundary as `Object?` so
      // `UsersRepository` doesn't leak a Firestore type — the cast below
      // can only fail if a caller passes something other than a cursor
      // this same repository previously handed back, and the try/catch
      // around it turns that into a `Result.failure` instead of an
      // uncaught `TypeError`.
      final snapshot = await _dataSource.fetchUsersPage(
        searchEmail: searchEmail,
        startAfter: cursor as DocumentSnapshot<Map<String, dynamic>>?,
        pageSize: pageSize,
      );

      final users = <ManagedUser>[];
      for (final doc in snapshot.docs) {
        users.add(await _toManagedUser(doc));
      }

      return Result.success(
        UsersPage(
          users: users,
          cursor: snapshot.docs.isEmpty ? null : snapshot.docs.last,
          hasMore: snapshot.docs.length == pageSize,
        ),
      );
    } catch (_) {
      return const Result.failure(ServerFailure('Could not load users.'));
    }
  }

  Future<ManagedUser> _toManagedUser(DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data() ?? const {};

    // N+1 read per visible row — acceptable at this admin tool's scale
    // (a staff member paging through 25 rows at a time), not something
    // that would be acceptable in the end-user mobile app's read path.
    final subscriptionDoc = await _dataSource.fetchSubscription(doc.id);
    final tierRaw = subscriptionDoc.data()?['tier'] as String?;

    return ManagedUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      role: AdminRoleAccess.fromClaim(data['role'] as String?),
      accountStatus: AccountStatusJson.fromFirestore(data['accountStatus'] as String?),
      tier: switch (tierRaw) {
        'premium' => ManagedUserTier.premium,
        'free' => ManagedUserTier.free,
        _ => ManagedUserTier.unknown,
      },
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Future<Result<void>> setAccountStatus({
    required String uid,
    required AccountStatus status,
  }) async {
    try {
      await _dataSource.updateAccountStatus(uid, status.firestoreValue);
      return const Result.success(null);
    } catch (_) {
      return const Result.failure(ServerFailure('Could not update account status.'));
    }
  }

  @override
  Future<Result<void>> setRole({required String uid, required String role}) async {
    try {
      await _dataSource.callSetRole(uid, role);
      return const Result.success(null);
    } on FirebaseFunctionsException catch (error) {
      return Result.failure(ServerFailure(error.message ?? 'Could not update role.'));
    } catch (_) {
      // Expected until `adminSetUserRole` is actually deployed — see
      // `FirestoreUsersDataSource.callSetRole`'s doc comment.
      return const Result.failure(
        ServerFailure('Role changes require a Cloud Function that is not deployed yet.'),
      );
    }
  }
}
