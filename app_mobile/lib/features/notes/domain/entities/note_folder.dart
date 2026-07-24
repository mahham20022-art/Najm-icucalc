import 'package:equatable/equatable.dart';

/// A user-created folder for organizing Notes. Deliberately flat — see
/// `core/database/app_database.dart`'s `NoteFolders` table doc comment.
class NoteFolder extends Equatable {
  const NoteFolder({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteFolder copyWith({String? name, DateTime? updatedAt}) => NoteFolder(
    id: id,
    name: name ?? this.name,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt];
}
