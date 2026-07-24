import 'managed_user.dart';

/// A page of [ManagedUser] results. [cursor] is deliberately opaque
/// (`Object?`, only the data layer that produced it knows how to
/// interpret it, currently a Firestore `DocumentSnapshot`) — a full
/// abstract pagination-cursor type would be over-engineering for a
/// single-datasource admin list, per this build's "shell first, then
/// deepen" scope; revisit if a second data source ever needs to
/// interoperate with this same pagination contract.
class UsersPage {
  const UsersPage({required this.users, required this.cursor, required this.hasMore});

  final List<ManagedUser> users;
  final Object? cursor;
  final bool hasMore;
}
