import 'package:equatable/equatable.dart';

import 'note_image.dart';

/// A user's note — Markdown body (supporting `**bold**`, headings, lists,
/// and a `==highlight==` inline extension), optionally filed into a
/// folder, optionally bookmarked, with zero or more attached images.
class Note extends Equatable {
  const Note({
    required this.id,
    required this.folderId,
    required this.title,
    required this.bodyMarkdown,
    required this.images,
    required this.isBookmarked,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? folderId;
  final String title;
  final String bodyMarkdown;
  final List<NoteImage> images;
  final bool isBookmarked;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note copyWith({
    String? folderId,
    bool clearFolder = false,
    String? title,
    String? bodyMarkdown,
    List<NoteImage>? images,
    bool? isBookmarked,
    DateTime? updatedAt,
  }) => Note(
    id: id,
    folderId: clearFolder ? null : (folderId ?? this.folderId),
    title: title ?? this.title,
    bodyMarkdown: bodyMarkdown ?? this.bodyMarkdown,
    images: images ?? this.images,
    isBookmarked: isBookmarked ?? this.isBookmarked,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    folderId,
    title,
    bodyMarkdown,
    images,
    isBookmarked,
    createdAt,
    updatedAt,
  ];
}
