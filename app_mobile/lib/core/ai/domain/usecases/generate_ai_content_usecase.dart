import '../../../error/result.dart';
import '../entities/ai_request.dart';
import '../entities/ai_response.dart';
import '../repositories/ai_engine_repository.dart';

class GenerateAiContentUseCase {
  const GenerateAiContentUseCase(this._repository);
  final AiEngineRepository _repository;

  Future<Result<AiResponse>> call(AiRequest request) => _repository.generate(request);
}
