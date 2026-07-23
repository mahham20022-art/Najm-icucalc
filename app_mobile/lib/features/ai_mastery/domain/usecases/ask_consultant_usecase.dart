import '../../../../core/ai/domain/entities/ai_response_chunk.dart';
import '../../../../core/error/result.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../entities/consultant_message.dart';
import '../repositories/mastery_repository.dart';

class AskConsultantUseCase {
  const AskConsultantUseCase(this._repository);
  final MasteryRepository _repository;

  Stream<Result<AiResponseChunk>> call({
    required Topic topic,
    required List<ConsultantMessage> history,
    required String question,
  }) => _repository.askConsultant(topic: topic, history: history, question: question);
}
