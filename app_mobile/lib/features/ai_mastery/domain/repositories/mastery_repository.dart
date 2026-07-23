import '../../../../core/ai/domain/entities/ai_response_chunk.dart';
import '../../../../core/error/result.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../entities/clinical_algorithm.dart';
import '../entities/comparison_table.dart';
import '../entities/consultant_message.dart';
import '../entities/flashcard.dart';
import '../entities/mastery_content.dart';
import '../entities/mastery_section_type.dart';
import '../entities/mcq.dart';
import '../entities/reference_entry.dart';

/// AI Mastery Mode's domain boundary — every one of the 14 sections a
/// topic offers is backed by one of these six methods:
///
/// - [getProseSection]: Summary, Clinical Pearls, Diagnosis, Management,
///   Guidelines, Explain Simply, Explain Deeply.
/// - [getComparisonTable], [getAlgorithm], [getMcqs], [getFlashcards],
///   [getReferences]: the five structured sections.
/// - [askConsultant]: Consultant Mode's live, un-cached chat.
///
/// Exam Mode isn't listed here — it's a presentation mode over
/// [getMcqs]'s output (`ExamSession`), not a separate generation call.
///
/// Implemented entirely on top of `core/ai`'s `AiEngineRepository`; this
/// interface never mentions OpenAI/Claude or caching/rate-limiting
/// directly, per the same layering `ChallengeRepository` follows over
/// Drift.
abstract interface class MasteryRepository {
  Future<Result<MasteryContent>> getProseSection({
    required Topic topic,
    required MasterySectionType section,
  });

  Future<Result<ComparisonTable>> getComparisonTable(Topic topic);

  Future<Result<ClinicalAlgorithm>> getAlgorithm(Topic topic);

  Future<Result<List<Mcq>>> getMcqs(Topic topic);

  Future<Result<List<Flashcard>>> getFlashcards(Topic topic);

  Future<Result<List<ReferenceEntry>>> getReferences(Topic topic);

  Stream<Result<AiResponseChunk>> askConsultant({
    required Topic topic,
    required List<ConsultantMessage> history,
    required String question,
  });
}
