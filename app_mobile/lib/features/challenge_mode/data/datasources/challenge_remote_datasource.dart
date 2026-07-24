import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/challenge_state.dart';

/// Owns Firestore access for Challenge Mode's single per-user progress
/// document (`users/{userId}/challengeProgress/state`) — added so a
/// 100-day journey survives a reinstall/device switch, per this
/// feature's self-review finding that "fully offline by construction"
/// meant permanent data loss was one uninstall away.
class ChallengeRemoteDataSource {
  ChallengeRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String userId) =>
      _firestore.collection('users').doc(userId).collection('challengeProgress').doc('state');

  Future<void> push(String userId, ChallengeState state) {
    return _doc(userId).set({
      'startedAt': Timestamp.fromDate(state.startedAt),
      'lastActionDate': state.lastActionDate == null
          ? null
          : Timestamp.fromDate(state.lastActionDate!),
      'completedDays': state.completedDays.toList(),
      'skippedDays': state.skippedDays.toList(),
      'bookmarkedDays': state.bookmarkedDays.toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<ChallengeState?> pull(String userId) async {
    final snapshot = await _doc(userId).get();
    final data = snapshot.data();
    if (data == null) return null;
    return ChallengeState(
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      lastActionDate: (data['lastActionDate'] as Timestamp?)?.toDate(),
      completedDays: (data['completedDays'] as List).cast<int>().toSet(),
      skippedDays: (data['skippedDays'] as List).cast<int>().toSet(),
      bookmarkedDays: (data['bookmarkedDays'] as List).cast<int>().toSet(),
    );
  }
}
