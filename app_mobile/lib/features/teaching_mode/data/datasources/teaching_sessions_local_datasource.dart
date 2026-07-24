import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/explanation_mode.dart';
import '../../domain/entities/teaching_evaluation.dart';
import '../../domain/entities/teaching_session.dart';

/// Owns all Drift access for `TeachingSessions` — the only place the raw
/// row type or its JSON-encoded list columns are touched.
class TeachingSessionsLocalDataSource {
  TeachingSessionsLocalDataSource(this._db);
  final AppDatabase _db;

  Future<void> insert(String userId, TeachingSession session) async {
    await _db
        .into(_db.teachingSessions)
        .insert(
          TeachingSessionsCompanion.insert(
            id: session.id,
            userId: userId,
            topicId: session.topicId,
            topicTitle: session.topicTitle,
            mode: session.mode.name,
            explanationText: session.explanationText,
            accuracyScore: session.evaluation.accuracyScore,
            clinicalReasoningScore: session.evaluation.clinicalReasoningScore,
            completenessScore: session.evaluation.completenessScore,
            confidenceScore: session.evaluation.confidenceScore,
            missingConceptsJson: Value(jsonEncode(session.evaluation.missingConcepts)),
            hallucinationsJson: Value(jsonEncode(session.evaluation.hallucinations)),
            feedback: session.evaluation.feedback,
            masteryScore: session.masteryScore,
            completedAt: session.completedAt,
          ),
        );
  }

  Stream<List<TeachingSession>> watchForTopic(String userId, String topicId) {
    final query = _db.select(_db.teachingSessions)
      ..where((t) => t.userId.equals(userId) & t.topicId.equals(topicId))
      ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]);
    return query.watch().map((rows) => rows.map(_toEntity).toList());
  }

  Future<TeachingSession?> getById(String userId, String sessionId) async {
    final query = _db.select(_db.teachingSessions)
      ..where((t) => t.id.equals(sessionId) & t.userId.equals(userId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  /// Used only by [TeachingSyncWorker]'s pull path — a session created on
  /// another device and downloaded to this one. Sessions are otherwise
  /// append-only ([insert] fails on an id collision), so this is the one
  /// path that tolerates re-writing an existing row (the same remote
  /// session pulled twice is idempotent, not a conflict).
  Future<void> upsertFromRemote(String userId, TeachingSession session) async {
    await _db
        .into(_db.teachingSessions)
        .insertOnConflictUpdate(
          TeachingSessionsCompanion.insert(
            id: session.id,
            userId: userId,
            topicId: session.topicId,
            topicTitle: session.topicTitle,
            mode: session.mode.name,
            explanationText: session.explanationText,
            accuracyScore: session.evaluation.accuracyScore,
            clinicalReasoningScore: session.evaluation.clinicalReasoningScore,
            completenessScore: session.evaluation.completenessScore,
            confidenceScore: session.evaluation.confidenceScore,
            missingConceptsJson: Value(jsonEncode(session.evaluation.missingConcepts)),
            hallucinationsJson: Value(jsonEncode(session.evaluation.hallucinations)),
            feedback: session.evaluation.feedback,
            masteryScore: session.masteryScore,
            completedAt: session.completedAt,
          ),
        );
  }

  TeachingSession _toEntity(TeachingSessionRow row) {
    return TeachingSession(
      id: row.id,
      topicId: row.topicId,
      topicTitle: row.topicTitle,
      mode: row.mode == 'voice' ? ExplanationMode.voice : ExplanationMode.written,
      explanationText: row.explanationText,
      evaluation: TeachingEvaluation(
        accuracyScore: row.accuracyScore,
        clinicalReasoningScore: row.clinicalReasoningScore,
        completenessScore: row.completenessScore,
        confidenceScore: row.confidenceScore,
        missingConcepts: (jsonDecode(row.missingConceptsJson) as List).cast<String>(),
        hallucinations: (jsonDecode(row.hallucinationsJson) as List).cast<String>(),
        feedback: row.feedback,
      ),
      completedAt: row.completedAt,
    );
  }
}
