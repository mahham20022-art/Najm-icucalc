import '../../../../core/error/result.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../entities/explanation_mode.dart';
import '../entities/teaching_session.dart';

/// Teaching Mode's domain boundary. [submitExplanation] does the whole
/// pipeline in one call — evaluate via the AI Engine, compute the
/// Mastery Score, persist the session — since from the caller's point of
/// view "grade what I just explained" is one intent, not three.
abstract interface class TeachingRepository {
  Future<Result<TeachingSession>> submitExplanation({
    required Topic topic,
    required ExplanationMode mode,
    required String explanationText,
  });

  /// All of this user's past sessions for [topicId], most recent first —
  /// powers a "your best score on this topic" indicator without needing
  /// a full history screen.
  Stream<List<TeachingSession>> watchSessionsForTopic(String topicId);
}
