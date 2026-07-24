import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_folder.dart';
import '../../domain/entities/note_image.dart';

/// Owns all Drift access for `Notes` and `NoteFolders`, including the
/// row <-> domain-entity mapping (`imagesJson` encode/decode) — the same
/// "mapping lives with the datasource" convention as every other local
/// datasource in this codebase.
class NotesLocalDataSource {
  NotesLocalDataSource(this._db);
  final AppDatabase _db;

  // ---------------------------------------------------------------- Folders

  Stream<List<NoteFolder>> watchFolders(String userId) {
    final query = _db.select(_db.noteFolders)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.watch().map((rows) => rows.map(_folderToEntity).toList());
  }

  Future<NoteFolder?> getFolder(String userId, String folderId) async {
    final query = _db.select(_db.noteFolders)
      ..where((t) => t.id.equals(folderId) & t.userId.equals(userId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _folderToEntity(row);
  }

  Future<void> upsertFolder(NoteFolder folder, {required String userId}) {
    return _db
        .into(_db.noteFolders)
        .insertOnConflictUpdate(
          NoteFoldersCompanion(
            id: Value(folder.id),
            userId: Value(userId),
            name: Value(folder.name),
            createdAt: Value(folder.createdAt),
            updatedAt: Value(folder.updatedAt),
          ),
        );
  }

  Future<void> deleteFolder(String userId, String folderId) async {
    await (_db.delete(
      _db.noteFolders,
    )..where((t) => t.id.equals(folderId) & t.userId.equals(userId))).go();
  }

  /// Unfiles every note that referenced [folderId] — called immediately
  /// before [deleteFolder] so no note is left pointing at a folder that
  /// no longer exists. Returns the affected note ids so the repository
  /// can enqueue an `Outbox` entry for each — this bulk `UPDATE` bypasses
  /// `upsertNote`/`saveNote` entirely, so without this the affected
  /// notes' cleared `folderId` would never reach Firestore.
  Future<List<String>> clearFolderReferences(String userId, String folderId) async {
    final affected =
        await (_db.select(_db.notes)
              ..where((t) => t.folderId.equals(folderId) & t.userId.equals(userId)))
            .map((row) => row.id)
            .get();
    await (_db.update(_db.notes)
          ..where((t) => t.folderId.equals(folderId) & t.userId.equals(userId)))
        .write(const NotesCompanion(folderId: Value(null)));
    return affected;
  }

  // ------------------------------------------------------------------ Notes

  Stream<List<Note>> watchNotes(
    String userId, {
    String? folderId,
    bool unfiledOnly = false,
    bool onlyBookmarked = false,
  }) {
    final query = _db.select(_db.notes)
      ..where((t) {
        var predicate = t.userId.equals(userId);
        if (unfiledOnly) {
          predicate = predicate & t.folderId.isNull();
        } else if (folderId != null) {
          predicate = predicate & t.folderId.equals(folderId);
        }
        if (onlyBookmarked) predicate = predicate & t.isBookmarked.equals(true);
        return predicate;
      })
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    return query.watch().map((rows) => rows.map(_noteToEntity).toList());
  }

  Stream<Note?> watchNoteById(String userId, String noteId) {
    final query = _db.select(_db.notes)
      ..where((t) => t.id.equals(noteId) & t.userId.equals(userId));
    return query.watchSingleOrNull().map((row) => row == null ? null : _noteToEntity(row));
  }

  Future<Note?> getNoteById(String userId, String noteId) async {
    final query = _db.select(_db.notes)
      ..where((t) => t.id.equals(noteId) & t.userId.equals(userId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _noteToEntity(row);
  }

  Future<void> upsertNote(Note note, {required String userId}) {
    return _db
        .into(_db.notes)
        .insertOnConflictUpdate(
          NotesCompanion(
            id: Value(note.id),
            userId: Value(userId),
            folderId: Value(note.folderId),
            title: Value(note.title),
            bodyMarkdown: Value(note.bodyMarkdown),
            imagesJson: Value(_encodeImages(note.images)),
            isBookmarked: Value(note.isBookmarked),
            createdAt: Value(note.createdAt),
            updatedAt: Value(note.updatedAt),
          ),
        );
  }

  Future<void> deleteNote(String userId, String noteId) async {
    await (_db.delete(_db.notes)..where((t) => t.id.equals(noteId) & t.userId.equals(userId))).go();
  }

  // ---------------------------------------------------------------- Mapping

  NoteFolder _folderToEntity(NoteFolderRow row) =>
      NoteFolder(id: row.id, name: row.name, createdAt: row.createdAt, updatedAt: row.updatedAt);

  Note _noteToEntity(NoteRow row) => Note(
    id: row.id,
    folderId: row.folderId,
    title: row.title,
    bodyMarkdown: row.bodyMarkdown,
    images: _decodeImages(row.imagesJson),
    isBookmarked: row.isBookmarked,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  String _encodeImages(List<NoteImage> images) => jsonEncode([
    for (final image in images)
      {'id': image.id, 'localPath': image.localPath, 'remoteUrl': image.remoteUrl},
  ]);

  List<NoteImage> _decodeImages(String json) {
    final decoded = jsonDecode(json) as List;
    return decoded
        .cast<Map<String, dynamic>>()
        .map(
          (map) => NoteImage(
            id: map['id'] as String,
            localPath: map['localPath'] as String?,
            remoteUrl: map['remoteUrl'] as String?,
          ),
        )
        .toList();
  }
}
