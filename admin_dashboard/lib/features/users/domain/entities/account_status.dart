/// Mirrors `MED100_DATABASE_DESIGN.md` §1's `users/{userId}.accountStatus`.
enum AccountStatus { active, suspended, pendingDeletion }

extension AccountStatusJson on AccountStatus {
  static AccountStatus fromFirestore(String? raw) => switch (raw) {
    'suspended' => AccountStatus.suspended,
    'pending_deletion' => AccountStatus.pendingDeletion,
    _ => AccountStatus.active,
  };

  String get firestoreValue => switch (this) {
    AccountStatus.active => 'active',
    AccountStatus.suspended => 'suspended',
    AccountStatus.pendingDeletion => 'pending_deletion',
  };
}
