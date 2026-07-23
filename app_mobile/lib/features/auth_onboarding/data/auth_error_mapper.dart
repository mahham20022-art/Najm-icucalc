import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/error/failure.dart';

/// Every place `AuthRepositoryImpl` calls Firebase/Google/Apple SDKs
/// funnels its catch block through here — the one place raw SDK
/// exceptions get translated into the typed [Failure]s the rest of the
/// app deals with. No `FirebaseAuthException` code or raw exception
/// message ever reaches a ViewModel or a screen (`MED100_UI_UX_SPEC.md`
/// §19: user-facing copy never surfaces technical jargon or raw error
/// codes).
Failure mapAuthException(Object error) {
  if (error is FirebaseAuthException) return _mapFirebaseAuthException(error);
  if (error is GoogleSignInException) return _mapGoogleSignInException(error);
  if (error is SignInWithAppleException) return _mapAppleSignInException(error);
  return const AuthFailure();
}

Failure _mapFirebaseAuthException(FirebaseAuthException error) {
  switch (error.code) {
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
    case 'invalid-email':
      return const InvalidCredentialsFailure();
    case 'email-already-in-use':
      return const EmailAlreadyInUseFailure();
    case 'weak-password':
      return const WeakPasswordFailure();
    case 'account-exists-with-different-credential':
      return const AccountExistsWithDifferentCredentialFailure();
    case 'too-many-requests':
      return const TooManyRequestsFailure();
    case 'network-request-failed':
      return const NetworkFailure();
    case 'user-disabled':
      return const AuthFailure('This account has been disabled.');
    default:
      return const AuthFailure();
  }
}

Failure _mapGoogleSignInException(GoogleSignInException error) {
  switch (error.code) {
    case GoogleSignInExceptionCode.canceled:
      return const SignInCancelledFailure();
    case GoogleSignInExceptionCode.interrupted:
      return const NetworkFailure();
    default:
      return const AuthFailure();
  }
}

Failure _mapAppleSignInException(SignInWithAppleException error) {
  if (error is SignInWithAppleAuthorizationException) {
    if (error.code == AuthorizationErrorCode.canceled) {
      return const SignInCancelledFailure();
    }
    return const AuthFailure();
  }
  if (error is SignInWithAppleNotSupportedException) {
    return const AuthFailure('Sign in with Apple is not available on this device.');
  }
  return const AuthFailure();
}
