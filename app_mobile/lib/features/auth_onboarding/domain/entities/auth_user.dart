import 'package:equatable/equatable.dart';

/// Domain entity — pure Dart, no `firebase_auth` types leak past the
/// data layer, per `MED100_ARCHITECTURE.md` §3.
class AuthUser extends Equatable {
  const AuthUser({
    required this.uid,
    required this.isAnonymous,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  final String uid;

  /// True for Guest Mode sessions (Firebase anonymous auth). Still a
  /// real, unique per-device `uid` — the same one every other per-user
  /// repository cache-scoping rule (`MED100_DATABASE_DESIGN.md` §0a)
  /// applies to, guest or not.
  final bool isAnonymous;

  final String? email;
  final String? displayName;
  final String? photoUrl;

  @override
  List<Object?> get props => [uid, isAnonymous, email, displayName, photoUrl];
}
