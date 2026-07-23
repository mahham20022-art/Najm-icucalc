import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider-agnostic session contract — repositories depend on this, not
/// on `FirebaseAuth` directly, matching the same pattern as
/// `core/analytics/analytics_facade.dart`.
///
/// Every per-user local table must be scoped by `userId`
/// (`MED100_DATABASE_DESIGN.md` §0a) specifically so a shared or
/// re-logged-in device can't leak one user's cached data into another's
/// session — this is what any repository's cache-key construction should
/// read from, rather than hardcoding a single shared key.
abstract interface class CurrentUser {
  /// `null` when signed out or in guest mode — callers that need a
  /// concrete scoping key fall back to [guestScopeId], not to a shared
  /// unscoped key.
  String? get userId;
}

/// Guest-mode scope: distinct from any real `userId`, so guest progress
/// never collides with (or silently migrates into) a signed-in user's
/// cache once they authenticate — reconciling guest data into a real
/// account is an explicit step (`MED100_UI_UX_SPEC.md` §3), not implicit.
const guestScopeId = 'guest';

class NoAuthCurrentUser implements CurrentUser {
  const NoAuthCurrentUser();

  @override
  String? get userId => null;
}

/// Reads straight off `FirebaseAuth.instance` rather than through
/// `features/auth_onboarding`'s repository — `core` sits below every
/// feature (`MED100_ARCHITECTURE.md` §3), so it can depend on the
/// Firebase SDK directly (same as `core/database`, `core/analytics`
/// depending on their own SDKs) but never on another feature's
/// abstractions. The actual sign-in/sign-out *behavior* still lives
/// entirely in `features/auth_onboarding` — this only ever reads.
class FirebaseCurrentUser implements CurrentUser {
  const FirebaseCurrentUser(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  String? get userId => _firebaseAuth.currentUser?.uid;
}

final currentUserProvider = Provider<CurrentUser>((ref) {
  return FirebaseCurrentUser(FirebaseAuth.instance);
});
