import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper over `firebase_auth` — nothing outside the data layer
/// touches the plugin directly, same convention `app_mobile` follows.
class FirebaseAdminAuthDataSource {
  FirebaseAdminAuthDataSource({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  /// `idTokenChanges`, not `authStateChanges` — a custom-claim grant
  /// (e.g. an existing user just promoted to `admin`) only becomes
  /// visible on a token refresh, which `authStateChanges` doesn't emit
  /// for since the *user* didn't change, only their token did.
  Stream<User?> idTokenChanges() => _firebaseAuth.idTokenChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User> signInWithEmail({required String email, required String password}) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) throw StateError('Sign-in succeeded with no user attached.');
    return user;
  }

  /// The claims map is parsed client-side and, per Firebase's own docs,
  /// "not to be trusted" as an authorization boundary — used here only
  /// to decide what this dashboard *shows*, never as the actual security
  /// check (that's Firestore Security Rules' job, per
  /// `MED100_ARCHITECTURE.md` §12).
  Future<String?> getRoleClaim(User user, {bool forceRefresh = false}) async {
    final result = await user.getIdTokenResult(forceRefresh);
    return result.claims?['role'] as String?;
  }

  Future<void> signOut() => _firebaseAuth.signOut();
}
