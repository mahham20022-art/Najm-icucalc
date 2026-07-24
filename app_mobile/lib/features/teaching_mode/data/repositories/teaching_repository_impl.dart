// ignore_for_file: prefer_initializing_formals
// The constructor's named parameters intentionally use public names
// (`aiEngine`) distinct from their private backing fields (`_aiEngine`)
// for a readable call site — an initializing formal would force the
// parameter name itself to be private.

import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../../../core/ai/domain/entities/ai_request.dart';
import '../../../../core/ai/domain/repositories/ai_engine_repository.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/session/current_user.dart';
import '../../../../core/sync/data/outbox_local_datasource.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../../domain/entities/explanation_mode.dart';
import '../../domain/entities/teaching_evaluation.dart';
import '../../domain/entities/teaching_session.dart';
import '../../domain/repositories/teaching_repository.dart';
import '../datasources/teaching_sessions_local_datasource.dart';
import '../teaching_prompt_templates.dart';
import '../teaching_sync_worker.dart' show TeachingSyncWorker;

class TeachingRepositoryImpl implements TeachingRepository {
  TeachingRepositoryImpl({
    required AiEngineRepository aiEngine,
    required TeachingSessionsLocalDataSource localDataSource,
    required OutboxLocalDataSource outbox,
    required CurrentUser currentUser,
  }) : _aiEngine = aiEngine,
       _localDataSource = localDataSource,
       _outbox = outbox,
       _currentUser = currentUser;

  final AiEngineRepository _aiEngine;
  final TeachingSessionsLocalDataSource _localDataSource;
  final OutboxLocalDataSource _outbox;
  final CurrentUser _currentUser;

  static const _uuid = Uuid();

  String get _userId => _currentUser.userId ?? guestScopeId;

  @override
  Future<Result<TeachingSession>> submitExplanation({
    required Topic topic,
    required ExplanationMode mode,
    required String explanationText,
  }) async {
    final request = AiRequest(
      promptTemplate: TeachingPromptTemplates.evaluation,
      variables: {
        'title': topic.title,
        'body': topic.body,
        'mode': mode.name,
        'explanation': explanationText,
      },
      itemType: 'topic',
      // `itemId` is bookkeeping metadata on the cache row, not part of
      // the AI Engine's actual cache key — that key already hashes the
      // fully-rendered prompt (template id + every variable, including
      // `explanationText`) together, so two different explanations
      // naturally get different cache entries without needing anything
      // explanation-specific folded in here.
      itemId: topic.id,
    );

    final result = await _aiEngine.generate(request);
    final failure = result.failureOrNull;
    if (failure != null) return Result.failure(failure);

    final TeachingEvaluation evaluation;
    try {
      evaluation = _parseEvaluation(result.dataOrNull!.content);
    } catch (_) {
      return const Result.failure(AiMalformedResponseFailure());
    }

    final session = TeachingSession(
      id: _uuid.v4(),
      topicId: topic.id,
      topicTitle: topic.title,
      mode: mode,
      explanationText: explanationText,
      evaluation: evaluation,
      completedAt: DateTime.now(),
    );
    await _localDataSource.insert(_userId, session);
    await _outbox.enqueue(
      userId: _userId,
      entityType: TeachingSyncWorker.entityType,
      entityId: session.id,
      operation: 'create',
    );
    return Result.success(session);
  }

  @override
  Stream<List<TeachingSession>> watchSessionsForTopic(String topicId) =>
      _localDataSource.watchForTopic(_userId, topicId);

  TeachingEvaluation _parseEvaluation(String raw) {
    final trimmed = raw.trim();
    final fenceMatch = RegExp(r'^```(?:json)?\s*([\s\S]*?)\s*```$').firstMatch(trimmed);
    final cleaned = fenceMatch?.group(1) ?? trimmed;
    final json = jsonDecode(cleaned) as Map<String, dynamic>;

    return TeachingEvaluation(
      accuracyScore: (json['accuracyScore'] as num).round(),
      clinicalReasoningScore: (json['clinicalReasoningScore'] as num).round(),
      completenessScore: (json['completenessScore'] as num).round(),
      confidenceScore: (json['confidenceScore'] as num).round(),
      missingConcepts: ((json['missingConcepts'] as List?) ?? const []).cast<String>(),
      hallucinations: ((json['hallucinations'] as List?) ?? const []).cast<String>(),
      feedback: json['feedback'] as String,
    );
  }
}
