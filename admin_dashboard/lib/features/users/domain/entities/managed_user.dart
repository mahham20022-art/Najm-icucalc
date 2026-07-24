import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/admin_role.dart';
import 'account_status.dart';
import 'subscription_tier.dart';

/// A row in the admin Users list — `users/{userId}` joined with
/// `subscriptions/{userId}` for display (Firestore has no server-side
/// join, so the data layer fetches both per visible page rather than
/// this entity claiming a single-document origin it doesn't have).
class ManagedUser extends Equatable {
  const ManagedUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.accountStatus,
    required this.tier,
    required this.createdAt,
  });

  final String uid;
  final String email;
  final String displayName;
  final AdminRole role;
  final AccountStatus accountStatus;
  final ManagedUserTier tier;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [uid, email, displayName, role, accountStatus, tier, createdAt];
}
