import '../../../../core/error/result.dart';
import '../entities/challenge_state.dart';
import '../repositories/challenge_repository.dart';

class SkipDayUseCase {
  const SkipDayUseCase(this._repository);
  final ChallengeRepository _repository;

  Future<Result<ChallengeState>> call() => _repository.markSkip();
}
