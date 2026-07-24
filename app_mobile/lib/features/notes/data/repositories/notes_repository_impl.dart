// ignore_for_file: prefer_initializing_formals
// The constructor's named parameters intentionally use public names
// distinct from their private backing fields for a readable call site —
// an initializing formal would force the parameter name itself to be
// private.

import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/session/current_user.dart';
import '../../../../core/sync/data/outbox_local_datasource.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_folder.dart';
import '../../domain/entities/note_image.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/note_image_file_datasource.dart';
import '../datasources/note_image_picker_datasource.dart';
import '../datasources/notes_local_datasource.dart';
import '../notes_sync_worker.dart' show NotesSyncWorker;
import '../services/note_pdf_exporter.dart';

/// Local-first, offline-capable: every write lands in the local Drift
/// database first (so it's immediately reflected in `watch*` streams
/// regardless of connectivity) and enqueues an `Outbox` entry describing
/// the same mutation; `NotesSyncWorker` (constructed and triggered from
/// `notes_providers.dart`, on connectivity restore and app resume) is
/// what actually reaches Firestore. This repository never calls
/// Firestore directly — reads always come from Drift, and there is
/// deliberately no "wait for the network" path anywhere in here.
class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl({
    required NotesLocalDataSource localDataSource,
    required OutboxLocalDataSource outbox,
    required NoteImagePickerDataSource imagePicker,
    required NoteImageFileDataSource imageFiles,
    required NotePdfExporter pdfExporter,
    required CurrentUser currentUser,
  }) : _local = localDataSource,
       _outbox = outbox,
       _imagePicker = imagePicker,
       _imageFiles = imageFiles,
       _pdfExporter = pdfExporter,
       _currentUser = currentUser;

  final NotesLocalDataSource _local;
  final OutboxLocalDataSource _outbox;
  final NoteImagePickerDataSource _imagePicker;
  final NoteImageFileDataSource _imageFiles;
  final NotePdfExporter _pdfExporter;
  final CurrentUser _currentUser;

  static const _uuid = Uuid();

  String get _userId => _currentUser.userId ?? guestScopeId;

  // ---------------------------------------------------------------- Folders

  @override
  Stream<List<NoteFolder>> watchFolders() => _local.watchFolders(_userId);

  @override
  Future<Result<NoteFolder>> createFolder(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Result.failure(ValidationFailure('Folder name cannot be empty.'));
    }
    final now = DateTime.now();
    final folder = NoteFolder(id: _uuid.v4(), name: trimmed, createdAt: now, updatedAt: now);
    try {
      await _local.upsertFolder(folder, userId: _userId);
      await _enqueueFolder(folder.id, 'create');
      return Result.success(folder);
    } catch (_) {
      return const Result.failure(CacheFailure());
    }
  }

  @override
  Future<Result<void>> renameFolder({required String folderId, required String name}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Result.failure(ValidationFailure('Folder name cannot be empty.'));
    }
    try {
      final existing = await _local.getFolder(folderId);
      if (existing == null) return const Result.failure(CacheFailure('Folder no longer exists.'));
      final updated = existing.copyWith(name: trimmed, updatedAt: DateTime.now());
      await _local.upsertFolder(updated, userId: _userId);
      await _enqueueFolder(folderId, 'update');
      return const Result.success(null);
    } catch (_) {
      return const Result.failure(CacheFailure());
    }
  }

  @override
  Future<Result<void>> deleteFolder(String folderId) async {
    try {
      final unfiledNoteIds = await _local.clearFolderReferences(folderId);
      await _local.deleteFolder(folderId);
      for (final noteId in unfiledNoteIds) {
        await _enqueueNote(noteId, 'update');
      }
      await _enqueueFolder(folderId, 'delete');
      return const Result.success(null);
    } catch (_) {
      return const Result.failure(CacheFailure());
    }
  }

  Future<void> _enqueueFolder(String folderId, String operation) => _outbox.enqueue(
    userId: _userId,
    entityType: NotesSyncWorker.noteFolderEntityType,
    entityId: folderId,
    operation: operation,
  );

  // ------------------------------------------------------------------ Notes

  @override
  Stream<List<Note>> watchNotes({
    String? folderId,
    bool unfiledOnly = false,
    bool onlyBookmarked = false,
  }) => _local.watchNotes(
    _userId,
    folderId: folderId,
    unfiledOnly: unfiledOnly,
    onlyBookmarked: onlyBookmarked,
  );

  @override
  Stream<Note?> watchNoteById(String noteId) => _local.watchNoteById(noteId);

  @override
  Future<Result<Note>> createNote({String? folderId}) async {
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(),
      folderId: folderId,
      title: '',
      bodyMarkdown: '',
      images: const [],
      isBookmarked: false,
      createdAt: now,
      updatedAt: now,
    );
    try {
      await _local.upsertNote(note, userId: _userId);
      await _enqueueNote(note.id, 'create');
      return Result.success(note);
    } catch (_) {
      return const Result.failure(CacheFailure());
    }
  }

  @override
  Future<Result<void>> saveNote(Note note) async {
    try {
      final updated = note.copyWith(updatedAt: DateTime.now());
      await _local.upsertNote(updated, userId: _userId);
      await _enqueueNote(note.id, 'update');
      return const Result.success(null);
    } catch (_) {
      return const Result.failure(CacheFailure());
    }
  }

  @override
  Future<Result<void>> deleteNote(String noteId) async {
    try {
      final existing = await _local.getNoteById(noteId);
      if (existing != null) {
        for (final image in existing.images) {
          final localPath = image.localPath;
          if (localPath != null) await _imageFiles.delete(localPath);
        }
      }
      await _local.deleteNote(noteId);
      await _enqueueNote(noteId, 'delete');
      return const Result.success(null);
    } catch (_) {
      return const Result.failure(CacheFailure());
    }
  }

  @override
  Future<Result<void>> toggleBookmark(String noteId) async {
    try {
      final existing = await _local.getNoteById(noteId);
      if (existing == null) return const Result.failure(CacheFailure('Note no longer exists.'));
      final updated = existing.copyWith(
        isBookmarked: !existing.isBookmarked,
        updatedAt: DateTime.now(),
      );
      await _local.upsertNote(updated, userId: _userId);
      await _enqueueNote(noteId, 'update');
      return const Result.success(null);
    } catch (_) {
      return const Result.failure(CacheFailure());
    }
  }

  Future<void> _enqueueNote(String noteId, String operation) => _outbox.enqueue(
    userId: _userId,
    entityType: NotesSyncWorker.noteEntityType,
    entityId: noteId,
    operation: operation,
  );

  // ----------------------------------------------------------------- Images

  @override
  Future<Result<NoteImage?>> addImageFromGallery() => _addImage(_imagePicker.pickFromGallery());

  @override
  Future<Result<NoteImage?>> addImageFromCamera() => _addImage(_imagePicker.pickFromCamera());

  Future<Result<NoteImage?>> _addImage(Future<({Uint8List bytes, String extension})?> pick) async {
    try {
      final picked = await pick;
      if (picked == null) return const Result.success(null);
      final imageId = _uuid.v4();
      final localPath = await _imageFiles.saveBytes(
        imageId: imageId,
        bytes: picked.bytes,
        fileExtension: picked.extension,
      );
      return Result.success(NoteImage(id: imageId, localPath: localPath));
    } catch (_) {
      return const Result.failure(ImagePickFailure());
    }
  }

  // ------------------------------------------------------------------- PDF

  @override
  Future<Result<Uint8List>> exportToPdf(Note note) async {
    try {
      final bytes = await _pdfExporter.export(note);
      return Result.success(bytes);
    } catch (_) {
      return const Result.failure(NotePdfExportFailure());
    }
  }
}
