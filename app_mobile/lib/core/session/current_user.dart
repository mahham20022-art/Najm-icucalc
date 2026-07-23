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

final currentUserProvider = Provider<CurrentUser>((ref) => const NoAuthCurrentUser());
