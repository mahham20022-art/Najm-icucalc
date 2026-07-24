import 'package:equatable/equatable.dart';

/// Base type for every domain-level failure surfaced to a ViewModel —
/// same `Result`/`Failure` convention as `app_mobile` (see that repo's
/// `core/error/failure.dart`), kept as a separate small file here rather
/// than a shared package: these are two intentionally independent
/// Flutter projects, and this pattern is a few dozen lines, not a
/// dependency worth coupling their release cycles over.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No connection available.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on our end.']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'You do not have access to this.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([super.message = 'Incorrect email or password.']);
}
