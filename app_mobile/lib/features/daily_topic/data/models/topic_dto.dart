import '../../domain/entities/topic.dart';

/// Data-layer shape — mirrors the Firestore `topics/{topicId}` document
/// from `MED100_DATABASE_DESIGN.md` §2 (trimmed to foundation-stage
/// fields). Converting between this and the domain [Topic] entity is the
/// data layer's job; the domain layer never sees a raw map.
class TopicDto {
  const TopicDto({
    required this.id,
    required this.title,
    required this.specialtyId,
    required this.estimatedMinutes,
    required this.isFree,
    required this.version,
  });

  final String id;
  final String title;
  final String specialtyId;
  final int estimatedMinutes;
  final bool isFree;
  final int version;

  factory TopicDto.fromJson(Map<String, dynamic> json) => TopicDto(
    id: json['id'] as String,
    title: json['title'] as String,
    specialtyId: json['specialtyId'] as String,
    estimatedMinutes: json['estimatedMinutes'] as int,
    isFree: json['isFree'] as bool,
    version: json['version'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'specialtyId': specialtyId,
    'estimatedMinutes': estimatedMinutes,
    'isFree': isFree,
    'version': version,
  };

  Topic toEntity() => Topic(
    id: id,
    title: title,
    specialtyId: specialtyId,
    estimatedMinutes: estimatedMinutes,
    isFree: isFree,
  );
}
