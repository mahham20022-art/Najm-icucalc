import 'failure.dart';

/// Same hand-rolled `Result<T>` convention as `app_mobile` — see that
/// repo's `core/error/result.dart` for the rationale.
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = Failed<T>;

  T? get dataOrNull => switch (this) {
    Success<T>(:final data) => data,
    Failed<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Failed<T>(:final failure) => failure,
  };

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
