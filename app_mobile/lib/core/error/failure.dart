import 'package:equatable/equatable.dart';

/// Base type for every domain-level failure surfaced to a ViewModel.
///
/// Use cases and repositories never throw across the domain/presentation
/// boundary (see `MED100_ARCHITECTURE.md` §4) — they return a [Result]
/// (see `result.dart`) whose error side is one of these.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// No network connectivity and no usable local cache for the request.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No connection available.']);
}

/// A Cloud Function or Firestore call reached the server but it reported
/// an error (validation, permission-denied, not-found, etc.).
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on our end.']);
}

/// The local (Drift) cache could not be read or written.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read local data.']);
}

/// The signed-in user does not have entitlement/permission for the
/// requested resource (e.g. a premium-flagged topic on the free tier).
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'You do not have access to this.']);
}

/// Input failed validation before a request was even attempted.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Email/password combination Firebase rejected (`wrong-password`,
/// `user-not-found`, `invalid-credential` all collapse to this one
/// message deliberately — telling a caller *which* of the two was wrong
/// is a well-known account-enumeration risk).
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([super.message = 'Incorrect email or password.']);
}

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure([super.message = 'An account already exists for that email.']);
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure([super.message = 'Choose a stronger password.']);
}

/// The email is already registered via a different sign-in method (e.g.
/// they signed up with Google, then tried Apple with the same email).
class AccountExistsWithDifferentCredentialFailure extends Failure {
  const AccountExistsWithDifferentCredentialFailure([
    super.message = 'That email is already linked to a different sign-in method.',
  ]);
}

class TooManyRequestsFailure extends Failure {
  const TooManyRequestsFailure([
    super.message = 'Too many attempts. Please wait a moment and try again.',
  ]);
}

/// The user closed the Google/Apple sign-in sheet themselves — not an
/// error to surface as one; ViewModels check for this type specifically
/// to return to idle state silently instead of showing an error banner.
class SignInCancelledFailure extends Failure {
  const SignInCancelledFailure([super.message = 'Sign-in was cancelled.']);
}

/// Biometric prompt failed, was cancelled, or isn't available/enrolled
/// on this device.
class BiometricFailure extends Failure {
  const BiometricFailure([super.message = 'Biometric authentication failed.']);
}

/// Catch-all for an auth-related failure that doesn't fit a more specific
/// type above — still carries a human-readable message, never a raw
/// Firebase error code (`MED100_UI_UX_SPEC.md` §19).
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Something went wrong signing you in.']);
}
