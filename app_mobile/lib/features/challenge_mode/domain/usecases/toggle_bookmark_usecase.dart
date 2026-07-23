import '../../../../core/error/result.dart';
import '../entities/challenge_state.dart';
import '../repositories/challenge_repository.dart';

class ToggleBookmarkUseCase {
  const ToggleBookmarkUseCase(this._repository);
  final ChallengeRepository _repository;

  Future<Result<ChallengeState>> call(int day) => _repository.toggleBookmark(day);
}
