import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Thin wrapper around `firebase_auth` plus the Google/Apple sign-in
/// SDKs — the only place in this feature that touches those packages
/// directly. Returns raw `firebase_auth.User`; converting to the domain
/// [AuthUser] entity is `AuthRepositoryImpl`'s job, not this datasource's
/// (`MED100_ARCHITECTURE.md` §5).
class FirebaseAuthDataSource {
  FirebaseAuthDataSource({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  bool _googleSignInInitialized = false;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    // `initialize()` is safe to call more than once, but there's no
    // reason to re-hit the platform channel on every sign-in attempt.
    // No `clientId`/`serverClientId` passed here: those come from a real
    // Firebase project's OAuth client config, which doesn't exist until
    // `flutterfire configure` runs (see README) — platform defaults are
    // used until then.
    if (!_googleSignInInitialized) {
      await _googleSignIn.initialize();
      _googleSignInInitialized = true;
    }

    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<User?> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
    );
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
    return userCredential.user;
  }

  Future<User?> signInWithEmail({required String email, required String password}) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<User?> registerWithEmail({required String email, required String password}) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<User?> continueAsGuest() async {
    final userCredential = await _firebaseAuth.signInAnonymously();
    return userCredential.user;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    // Only sign out of Google if a Google session is actually active —
    // calling it unconditionally is harmless but pointless for
    // email/Apple/guest sessions.
    if (_googleSignInInitialized) {
      await _googleSignIn.signOut();
    }
  }
}
