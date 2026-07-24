import 'dart:typed_data';

import '../../../../core/error/result.dart';
import '../entities/note.dart';
import '../entities/note_folder.dart';
import '../entities/note_image.dart';

abstract class NotesRepository {
  Stream<List<NoteFolder>> watchFolders();

  Future<Result<NoteFolder>> createFolder(String name);

  Future<Result<void>> renameFolder({required String folderId, required String name});

  /// Notes inside the folder become unfiled (`folderId` cleared) rather
  /// than deleted with it.
  Future<Result<void>> deleteFolder(String folderId);

  /// Folder filtering is a 3-way choice: pass [folderId] for a specific
  /// folder, [unfiledOnly] for notes with no folder, or neither for
  /// every note regardless of folder. [onlyBookmarked] narrows further,
  /// independent of the folder filter.
  Stream<List<Note>> watchNotes({
    String? folderId,
    bool unfiledOnly = false,
    bool onlyBookmarked = false,
  });

  Stream<Note?> watchNoteById(String noteId);

  Future<Result<Note>> createNote({String? folderId});

  /// Persists every field of [note] — the editor's single save point,
  /// rather than granular per-field update methods.
  Future<Result<void>> saveNote(Note note);

  Future<Result<void>> deleteNote(String noteId);

  Future<Result<void>> toggleBookmark(String noteId);

  /// Opens the native image picker, copies the picked image into local
  /// app storage, and returns a [NoteImage] referencing it. Returns
  /// `Result.success(null)` (not a failure) if the user cancels the
  /// picker — the caller (the editor ViewModel) is responsible for
  /// inserting `![alt](med100-image:<id>)` into the note's Markdown and
  /// including the returned image in the note it next saves.
  Future<Result<NoteImage?>> addImageFromGallery();

  Future<Result<NoteImage?>> addImageFromCamera();

  Future<Result<Uint8List>> exportToPdf(Note note);
}
