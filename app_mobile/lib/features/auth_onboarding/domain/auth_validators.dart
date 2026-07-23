import '../../../core/error/failure.dart';

/// Shared client-side validation for [SignInWithEmailUseCase] and
/// [RegisterWithEmailUseCase] — catches empty/malformed input before a
/// network call is even attempted; never a substitute for Firebase's own
/// server-side validation (`EmailAlreadyInUseFailure`, etc. still come
/// back from the repository).
abstract final class AuthValidators {
  static Failure? email(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return const ValidationFailure('Enter your email address.');
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed)) {
      return const ValidationFailure('Enter a valid email address.');
    }
    return null;
  }

  static Failure? passwordNotEmpty(String password) {
    if (password.isEmpty) return const ValidationFailure('Enter your password.');
    return null;
  }

  /// Firebase's own minimum is 6 characters; enforcing it client-side
  /// avoids a round trip just to learn that.
  static Failure? passwordStrength(String password) {
    if (password.length < 6) {
      return const ValidationFailure('Password must be at least 6 characters.');
    }
    return null;
  }

  static Failure? passwordsMatch(String password, String confirmPassword) {
    if (password != confirmPassword) return const ValidationFailure('Passwords do not match.');
    return null;
  }
}
