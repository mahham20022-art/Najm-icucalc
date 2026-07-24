import '../entities/spaced_repetition_statistics.dart';
import '../repositories/spaced_repetition_repository.dart';

class WatchStatisticsUseCase {
  const WatchStatisticsUseCase(this._repository);
  final SpacedRepetitionRepository _repository;

  Stream<SpacedRepetitionStatistics> call() => _repository.watchStatistics();
}
