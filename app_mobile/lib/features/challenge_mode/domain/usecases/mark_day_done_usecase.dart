import '../../../../core/error/result.dart';
import '../entities/challenge_state.dart';
import '../repositories/challenge_repository.dart';

class MarkDayDoneUseCase {
  const MarkDayDoneUseCase(this._repository);
  final ChallengeRepository _repository;

  Future<Result<ChallengeState>> call() => _repository.markDone();
}
