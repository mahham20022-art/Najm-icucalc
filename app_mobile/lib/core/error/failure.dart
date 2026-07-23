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
