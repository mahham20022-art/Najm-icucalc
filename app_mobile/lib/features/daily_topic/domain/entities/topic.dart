import 'package:equatable/equatable.dart';

/// Domain entity — pure Dart, no Firestore/Drift/JSON knowledge, per
/// `MED100_ARCHITECTURE.md` §3. Mirrors the shape defined in
/// `MED100_DATABASE_DESIGN.md` §2, trimmed to what the presentation layer
/// actually needs; the full document schema lives in the data layer's
/// DTO, not here.
class Topic extends Equatable {
  const Topic({
    required this.id,
    required this.title,
    required this.specialtyId,
    required this.estimatedMinutes,
    required this.isFree,
  });

  final String id;
  final String title;
  final String specialtyId;
  final int estimatedMinutes;
  final bool isFree;

  @override
  List<Object?> get props => [id, title, specialtyId, estimatedMinutes, isFree];
}
