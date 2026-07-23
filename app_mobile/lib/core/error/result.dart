import 'failure.dart';

/// A `Result<T>` is the return type of every repository method and use
/// case in this codebase — success and failure are values, never
/// exceptions crossing the domain/presentation boundary
/// (`MED100_ARCHITECTURE.md` §4).
///
/// Deliberately hand-rolled as a Dart 3 sealed class rather than pulling
/// in a functional-programming package: pattern matching via `switch`
/// gives the same exhaustiveness guarantee with zero extra dependency.
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = Failed<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failed<T>;

  /// Returns the success value or `null` if this is a [Failed].
  T? get dataOrNull => switch (this) {
    Success<T>(:final data) => data,
    Failed<T>() => null,
  };

  /// Returns the failure or `null` if this is a [Success].
  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Failed<T>(:final failure) => failure,
  };

  /// Exhaustive fold — the preferred way to consume a [Result] in a
  /// ViewModel, since it forces both branches to be handled.
  R when<R>({required R Function(T data) success, required R Function(Failure failure) failure}) =>
      switch (this) {
        Success<T>(:final data) => success(data),
        Failed<T>(failure: final f) => failure(f),
      };
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Failed<T> extends Result<T> {
  const Failed(this.failure);
  final Failure failure;
}
