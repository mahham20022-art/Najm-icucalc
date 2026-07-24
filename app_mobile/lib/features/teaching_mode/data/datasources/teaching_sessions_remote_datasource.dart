import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/explanation_mode.dart';
import '../../domain/entities/teaching_evaluation.dart';
import '../../domain/entities/teaching_session.dart';

/// Owns Firestore access for Teaching Mode's `teachingSessions` —
/// append-only, per `firestore.rules` (`allow update, delete: if false`):
/// a session is a record of one attempt, never edited after grading.
class TeachingSessionsRemoteDataSource {
  TeachingSessionsRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _sessions(String userId) =>
      _firestore.collection('users').doc(userId).collection('teachingSessions');

  Future<void> push(String userId, TeachingSession session) {
    return _sessions(userId).doc(session.id).set({
      'topicId': session.topicId,
      'topicTitle': session.topicTitle,
      'mode': session.mode.name,
      'explanationText': session.explanationText,
      'accuracyScore': session.evaluation.accuracyScore,
      'clinicalReasoningScore': session.evaluation.clinicalReasoningScore,
      'completenessScore': session.evaluation.completenessScore,
      'confidenceScore': session.evaluation.confidenceScore,
      'missingConcepts': session.evaluation.missingConcepts,
      'hallucinations': session.evaluation.hallucinations,
      'feedback': session.evaluation.feedback,
      'completedAt': Timestamp.fromDate(session.completedAt),
    });
  }

  /// `since == null` pulls every session (first sync on this device).
  Future<List<TeachingSession>> pullSince(String userId, DateTime? since) async {
    Query<Map<String, dynamic>> query = _sessions(userId).orderBy('completedAt');
    if (since != null) {
      query = query.where('completedAt', isGreaterThan: Timestamp.fromDate(since));
    }
    final snapshot = await query.get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  TeachingSession _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return TeachingSession(
      id: doc.id,
      topicId: data['topicId'] as String,
      topicTitle: data['topicTitle'] as String,
      mode: data['mode'] == 'voice' ? ExplanationMode.voice : ExplanationMode.written,
      explanationText: data['explanationText'] as String,
      evaluation: TeachingEvaluation(
        accuracyScore: (data['accuracyScore'] as num).round(),
        clinicalReasoningScore: (data['clinicalReasoningScore'] as num).round(),
        completenessScore: (data['completenessScore'] as num).round(),
        confidenceScore: (data['confidenceScore'] as num).round(),
        missingConcepts: ((data['missingConcepts'] as List?) ?? const []).cast<String>(),
        hallucinations: ((data['hallucinations'] as List?) ?? const []).cast<String>(),
        feedback: data['feedback'] as String,
      ),
      completedAt: (data['completedAt'] as Timestamp).toDate(),
    );
  }
}
