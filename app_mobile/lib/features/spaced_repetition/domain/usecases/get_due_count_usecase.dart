import '../repositories/spaced_repetition_repository.dart';

class GetDueCountUseCase {
  const GetDueCountUseCase(this._repository);
  final SpacedRepetitionRepository _repository;

  Future<int> call() => _repository.getDueCount();
}
