import 'dart:convert';

import '../../../../core/ai/domain/entities/ai_message.dart';
import '../../../../core/ai/domain/entities/ai_request.dart';
import '../../../../core/ai/domain/entities/ai_response_chunk.dart';
import '../../../../core/ai/domain/repositories/ai_engine_repository.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../../domain/entities/clinical_algorithm.dart';
import '../../domain/entities/comparison_table.dart';
import '../../domain/entities/consultant_message.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/entities/mastery_content.dart';
import '../../domain/entities/mastery_section_type.dart';
import '../../domain/entities/mcq.dart';
import '../../domain/entities/reference_entry.dart';
import '../../domain/repositories/mastery_repository.dart';
import '../mastery_prompt_templates.dart';

/// How many MCQs/flashcards to request per topic — enough for a useful
/// study/exam session without an oversized single AI call.
const _itemsPerTopic = 6;

class MasteryRepositoryImpl implements MasteryRepository {
  const MasteryRepositoryImpl(this._aiEngine);

  final AiEngineRepository _aiEngine;

  @override
  Future<Result<MasteryContent>> getProseSection({
    required Topic topic,
    required MasterySectionType section,
  }) async {
    final request = AiRequest(
      promptTemplate: MasteryPromptTemplates.forProseSection(section),
      variables: {'title': topic.title, 'body': topic.body},
      itemType: 'topic',
      itemId: '${topic.id}:${section.name}',
    );
    final result = await _aiEngine.generate(request);
    return result.when(
      success: (response) => Result.success(
        MasteryContent(section: section, body: response.content.trim(), cached: response.cached),
      ),
      failure: (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<ComparisonTable>> getComparisonTable(Topic topic) async {
    final request = AiRequest(
      promptTemplate: MasteryPromptTemplates.comparisonTable,
      variables: {'title': topic.title, 'body': topic.body},
      itemType: 'topic',
      itemId: '${topic.id}:comparison_table',
    );
    final result = await _aiEngine.generate(request);
    return result.when(
      success: (response) {
        try {
          final json = _decodeJsonObject(response.content);
          final columns = (json['columns'] as List).cast<String>();
          final rawRows = (json['rows'] as List).map((row) => (row as List).cast<String>());
          // A model occasionally emits a ragged row despite the prompt's
          // instructions — normalize rather than let `DataTable` assert-
          // crash on a cell-count mismatch downstream.
          final rows = rawRows
              .map(
                (row) => List<String>.generate(columns.length, (i) => i < row.length ? row[i] : ''),
              )
              .toList();
          return Result.success(
            ComparisonTable(
              title: (json['title'] as String?) ?? topic.title,
              columns: columns,
              rows: rows,
            ),
          );
        } catch (_) {
          return const Result.failure(AiMalformedResponseFailure());
        }
      },
      failure: (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<ClinicalAlgorithm>> getAlgorithm(Topic topic) async {
    final request = AiRequest(
      promptTemplate: MasteryPromptTemplates.algorithm,
      variables: {'title': topic.title, 'body': topic.body},
      itemType: 'topic',
      itemId: '${topic.id}:algorithm',
    );
    final result = await _aiEngine.generate(request);
    return result.when(
      success: (response) {
        try {
          final json = _decodeJsonObject(response.content);
          final steps = (json['steps'] as List)
              .cast<Map<String, dynamic>>()
              .map(
                (step) => AlgorithmStep(
                  order: step['order'] as int,
                  text: step['text'] as String,
                  branches: ((step['branches'] as List?) ?? const []).cast<String>(),
                ),
              )
              .toList();
          return Result.success(
            ClinicalAlgorithm(title: (json['title'] as String?) ?? topic.title, steps: steps),
          );
        } catch (_) {
          return const Result.failure(AiMalformedResponseFailure());
        }
      },
      failure: (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<List<Mcq>>> getMcqs(Topic topic) async {
    final request = AiRequest(
      promptTemplate: MasteryPromptTemplates.mcqs,
      variables: {'title': topic.title, 'body': topic.body, 'count': '$_itemsPerTopic'},
      itemType: 'topic',
      itemId: '${topic.id}:mcqs',
    );
    final result = await _aiEngine.generate(request);
    return result.when(
      success: (response) {
        try {
          final json = _decodeJsonObject(response.content);
          final mcqs = (json['questions'] as List)
              .cast<Map<String, dynamic>>()
              .map(
                (q) => Mcq(
                  question: q['question'] as String,
                  options: (q['options'] as List).cast<String>(),
                  correctIndex: q['correctIndex'] as int,
                  explanation: q['explanation'] as String,
                ),
              )
              .toList();
          return Result.success(mcqs);
        } catch (_) {
          return const Result.failure(AiMalformedResponseFailure());
        }
      },
      failure: (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<List<Flashcard>>> getFlashcards(Topic topic) async {
    final request = AiRequest(
      promptTemplate: MasteryPromptTemplates.flashcards,
      variables: {'title': topic.title, 'body': topic.body, 'count': '$_itemsPerTopic'},
      itemType: 'topic',
      itemId: '${topic.id}:flashcards',
    );
    final result = await _aiEngine.generate(request);
    return result.when(
      success: (response) {
        try {
          final json = _decodeJsonObject(response.content);
          final rawCards = (json['cards'] as List).cast<Map<String, dynamic>>();
          final cards = [
            for (var i = 0; i < rawCards.length; i++)
              Flashcard(
                id: '${topic.id}_$i',
                front: rawCards[i]['front'] as String,
                back: rawCards[i]['back'] as String,
              ),
          ];
          return Result.success(cards);
        } catch (_) {
          return const Result.failure(AiMalformedResponseFailure());
        }
      },
      failure: (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<List<ReferenceEntry>>> getReferences(Topic topic) async {
    final request = AiRequest(
      promptTemplate: MasteryPromptTemplates.references,
      variables: {'title': topic.title, 'body': topic.body},
      itemType: 'topic',
      itemId: '${topic.id}:references',
    );
    final result = await _aiEngine.generate(request);
    return result.when(
      success: (response) {
        try {
          final json = _decodeJsonObject(response.content);
          final references = (json['references'] as List)
              .cast<String>()
              .map(ReferenceEntry.new)
              .toList();
          return Result.success(references);
        } catch (_) {
          return const Result.failure(AiMalformedResponseFailure());
        }
      },
      failure: (failure) => Result.failure(failure),
    );
  }

  @override
  Stream<Result<AiResponseChunk>> askConsultant({
    required Topic topic,
    required List<ConsultantMessage> history,
    required String question,
  }) {
    final messages = [
      AiMessage(role: AiMessageRole.system, content: _consultantSystemPrompt(topic)),
      for (final message in history)
        AiMessage(
          role: message.speaker == ConsultantSpeaker.user
              ? AiMessageRole.user
              : AiMessageRole.assistant,
          content: message.content,
        ),
      AiMessage(role: AiMessageRole.user, content: question),
    ];
    return _aiEngine.chat(messages: messages, maxTokens: 500, temperature: 0.4);
  }

  String _consultantSystemPrompt(Topic topic) =>
      'You are an experienced attending physician acting as a curbside '
      'consultant for a colleague asking about "${topic.title}". Answer '
      'precisely and practically, the way a specialist would in a hallway '
      "conversation — it's fine to ask a clarifying question if the query "
      'is ambiguous. Base your answers on this source material where '
      'relevant:\n\n${topic.body}\n\nIf asked something outside this '
      'material, answer from general clinical knowledge but say so.';

  /// Strips a defensive markdown code fence (models sometimes wrap JSON
  /// in ` ```json ... ``` ` despite instructions not to) before decoding.
  Map<String, dynamic> _decodeJsonObject(String raw) {
    final trimmed = raw.trim();
    final fenceMatch = RegExp(r'^```(?:json)?\s*([\s\S]*?)\s*```$').firstMatch(trimmed);
    final cleaned = fenceMatch?.group(1) ?? trimmed;
    return jsonDecode(cleaned) as Map<String, dynamic>;
  }
}
