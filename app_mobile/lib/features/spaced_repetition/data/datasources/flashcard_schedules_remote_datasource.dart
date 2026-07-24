import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/flashcard_schedule.dart';
import '../../domain/entities/repetition_stage.dart';

/// Owns Firestore access for `users/{userId}/flashcardSchedule` —
/// deliberately client-owned per `firestore.rules`' doc comment (a
/// deviation from the architecture docs' server-computed-SM-2 design,
/// matching the simpler client-computed 7/30/90 ladder this feature
/// actually implements).
///
/// [FlashcardSchedule] has no `updatedAt` field of its own, so `push`
/// stamps one at write time purely as this collection's sync watermark —
/// it is never read back into the domain entity.
class FlashcardSchedulesRemoteDataSource {
  FlashcardSchedulesRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _schedules(String userId) =>
      _firestore.collection('users').doc(userId).collection('flashcardSchedule');

  Future<void> push(String userId, FlashcardSchedule schedule) {
    return _schedules(userId).doc(schedule.flashcardId).set({
      'topicId': schedule.topicId,
      'stage': schedule.stage.name,
      'dueDate': Timestamp.fromDate(schedule.dueDate),
      'lastReviewedAt': schedule.lastReviewedAt == null
          ? null
          : Timestamp.fromDate(schedule.lastReviewedAt!),
      'timesReviewed': schedule.timesReviewed,
      'timesLapsed': schedule.timesLapsed,
      'createdAt': Timestamp.fromDate(schedule.createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// `since == null` pulls every schedule (first sync on this device).
  Future<List<FlashcardSchedule>> pullSince(String userId, DateTime? since) async {
    Query<Map<String, dynamic>> query = _schedules(userId).orderBy('updatedAt');
    if (since != null) {
      query = query.where('updatedAt', isGreaterThan: Timestamp.fromDate(since));
    }
    final snapshot = await query.get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  FlashcardSchedule _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return FlashcardSchedule(
      flashcardId: doc.id,
      topicId: data['topicId'] as String,
      stage: RepetitionStage.values.byName(data['stage'] as String),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      lastReviewedAt: (data['lastReviewedAt'] as Timestamp?)?.toDate(),
      timesReviewed: data['timesReviewed'] as int? ?? 0,
      timesLapsed: data['timesLapsed'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
