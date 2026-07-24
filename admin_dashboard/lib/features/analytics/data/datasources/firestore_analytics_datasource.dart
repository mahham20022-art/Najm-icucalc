import 'package:cloud_firestore/cloud_firestore.dart';

/// Owns every Firestore aggregation-count query behind the Analytics
/// screen. `.count().get()` is a real server-side aggregation (not a
/// full document fetch) — cheap and correct even as collections grow,
/// unlike downloading every document to count client-side.
class FirestoreAnalyticsDataSource {
  FirestoreAnalyticsDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<int> _count(Query<Map<String, dynamic>> query) async {
    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  Future<int> totalUsers() => _count(_firestore.collection('users'));

  Future<int> suspendedUsers() =>
      _count(_firestore.collection('users').where('accountStatus', isEqualTo: 'suspended'));

  Future<int> premiumUsers() =>
      _count(_firestore.collection('subscriptions').where('tier', isEqualTo: 'premium'));

  Future<int> totalTopics() => _count(_firestore.collection('topics'));

  Future<int> totalLearningPaths() => _count(_firestore.collection('learningPaths'));
}
