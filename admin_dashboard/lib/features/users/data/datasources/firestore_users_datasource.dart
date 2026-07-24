import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Owns Firestore (`users/{userId}`, `subscriptions/{userId}`) and the
/// `adminSetUserRole` Cloud Functions callable for `features/users`.
class FirestoreUsersDataSource {
  FirestoreUsersDataSource({FirebaseFirestore? firestore, FirebaseFunctions? functions})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');

  /// No search term: newest-first by `createdAt`. With one: an
  /// email-prefix range query — Firestore has no full-text search, and
  /// this is a deliberate, documented simplification (see
  /// `UsersRepository.fetchUsers`'s doc comment).
  Future<QuerySnapshot<Map<String, dynamic>>> fetchUsersPage({
    String? searchEmail,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
    required int pageSize,
  }) {
    Query<Map<String, dynamic>> query;
    if (searchEmail != null && searchEmail.isNotEmpty) {
      query = _users
          .orderBy('email')
          .where('email', isGreaterThanOrEqualTo: searchEmail)
          .where('email', isLessThan: '$searchEmail');
    } else {
      query = _users.orderBy('createdAt', descending: true);
    }
    if (startAfter != null) query = query.startAfterDocument(startAfter);
    return query.limit(pageSize).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchSubscription(String uid) =>
      _firestore.collection('subscriptions').doc(uid).get();

  Future<void> updateAccountStatus(String uid, String status) =>
      _users.doc(uid).update({'accountStatus': status});

  /// `role` is also mirrored into a Firebase Auth custom claim, which
  /// only the Admin SDK can set — this callable is the real, correct
  /// integration point, but the Cloud Function itself
  /// (`adminSetUserRole`) does not exist server-side yet. Calling this
  /// today fails with a `not-found`/`internal` `FirebaseFunctionsException`
  /// until that function is deployed; see `FirestoreUsersRepositoryImpl`.
  Future<void> callSetRole(String uid, String role) =>
      _functions.httpsCallable('adminSetUserRole').call({'uid': uid, 'role': role});
}
