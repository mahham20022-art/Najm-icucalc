import '../../../../core/error/result.dart';
import '../entities/auth_user.dart';

/// Domain-owned interface — the data layer implements this
/// (`AuthRepositoryImpl`), composing Firebase Authentication with
/// Google/Apple sign-in SDKs behind it. Presentation only ever depends on
/// this interface, per the Repository Pattern
/// (`MED100_ARCHITECTURE.md` §5).
abstract interface class AuthRepository {
  /// The signed-in user right now, synchronously, or `null` if signed
  /// out. Used for the one-shot session-restore check at Splash — for
  /// reactive updates, use [authStateChanges].
  AuthUser? get currentUser;

  /// Emits whenever Firebase's underlying auth state changes (sign-in,
  /// sign-out, token invalidation) — `null` means signed out.
  Stream<AuthUser?> get authStateChanges;

  Future<Result<AuthUser>> signInWithGoogle();

  Future<Result<AuthUser>> signInWithApple();

  Future<Result<AuthUser>> signInWithEmail({required String email, required String password});

  Future<Result<AuthUser>> registerWithEmail({required String email, required String password});

  /// Guest Mode — Firebase anonymous auth. Still produces a real,
  /// distinct `uid` (see [AuthUser.isAnonymous]).
  Future<Result<AuthUser>> continueAsGuest();

  Future<Result<void>> signOut();
}
