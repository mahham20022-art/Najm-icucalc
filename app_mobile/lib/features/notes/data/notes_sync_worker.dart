// ignore_for_file: prefer_initializing_formals
// The constructor's named parameters intentionally use public names
// distinct from their private backing fields for a readable call site —
// an initializing formal would force the parameter name itself to be
// private.

import 'dart:async';

import '../../../core/database/app_database.dart';
import '../../../core/session/current_user.dart';
import '../../../core/sync/data/outbox_local_datasource.dart';
import '../../../core/sync/data/sync_state_local_datasource.dart';
import '../../../core/sync/sync_worker.dart';
import '../domain/entities/note_image.dart';
import 'datasources/note_image_file_datasource.dart';
import 'datasources/notes_local_datasource.dart';
import 'datasources/notes_remote_datasource.dart';

/// The first concrete [SyncWorker] implementation in this codebase — see
/// `core/sync/sync_worker.dart`'s doc comment, which explicitly deferred
/// the drain loop and Firestore wiring to whichever feature module
/// needed it first.
///
/// Guest sessions (`CurrentUser.userId == null`, scoped locally under
/// [guestScopeId]) never sync — there is no Firestore account to sync
/// to, and a guest's notes are not expected to survive a reinstall.
class NotesSyncWorker implements SyncWorker {
  NotesSyncWorker({
    required NotesLocalDataSource localDataSource,
    required NotesRemoteDataSource remoteDataSource,
    required OutboxLocalDataSource outbox,
    required SyncStateLocalDataSource syncState,
    required NoteImageFileDataSource imageFiles,
    required CurrentUser currentUser,
  }) : _local = localDataSource,
       _remote = remoteDataSource,
       _outbox = outbox,
       _syncState = syncState,
       _imageFiles = imageFiles,
       _currentUser = currentUser;

  final NotesLocalDataSource _local;
  final NotesRemoteDataSource _remote;
  final OutboxLocalDataSource _outbox;
  final SyncStateLocalDataSource _syncState;
  final NoteImageFileDataSource _imageFiles;
  final CurrentUser _currentUser;

  static const noteEntityType = 'note';
  static const noteFolderEntityType = 'note_folder';

  @override
  Future<void> drainOutbox(String userId) async {
    if (userId == guestScopeId) return;

    final pending = await _outbox.pendingFor(
      userId: userId,
      entityTypes: const [noteEntityType, noteFolderEntityType],
    );

    // Collapse duplicate pending ops for the same entity (e.g. several
    // debounced saves to the same note queued up while offline) down to
    // just the chronologically last one. Every push below reads the
    // *current* local row, never a per-row payload, so replaying the
    // earlier ones would only repeat the same final Firestore write —
    // and since both `create` and `update` push identically here (only
    // `delete` branches differently), the last row is always a safe
    // stand-in for the ones it supersedes, whichever operation it was.
    final latestByEntity = <String, OutboxData>{};
    for (final row in pending) {
      latestByEntity['${row.entityType}:${row.entityId}'] = row;
    }
    for (final row in pending) {
      if (!identical(row, latestByEntity['${row.entityType}:${row.entityId}'])) {
        await _outbox.markSynced(row.id);
      }
    }

    for (final row in latestByEntity.values) {
      try {
        if (row.entityType == noteFolderEntityType) {
          await _drainFolder(userId, row);
        } else {
          await _drainNote(userId, row);
        }
        await _outbox.markSynced(row.id);
      } catch (_) {
        // Left in the outbox (marked `failed`) for the next drain
        // attempt — network calls here are inherently retryable, and
        // Firestore's `.set()`/`.delete()` are idempotent, so re-running
        // a partially-completed drain is always safe.
        await _outbox.markFailed(row);
      }
    }
  }

  Future<void> _drainFolder(String userId, OutboxData row) async {
    if (row.operation == 'delete') {
      await _remote.deleteFolder(userId, row.entityId);
      return;
    }
    final folder = await _local.getFolder(userId, row.entityId);
    if (folder == null) return; // Deleted locally again before the drain ran.
    await _remote.pushFolder(userId, folder);
  }

  Future<void> _drainNote(String userId, OutboxData row) async {
    if (row.operation == 'delete') {
      await _remote.deleteNote(userId, row.entityId);
      unawaited(_remote.deleteAllImages(userId, row.entityId));
      return;
    }

    final note = await _local.getNoteById(userId, row.entityId);
    if (note == null) return;

    var imagesChanged = false;
    final resolvedImages = <NoteImage>[];
    for (final image in note.images) {
      if (image.remoteUrl != null || image.localPath == null) {
        resolvedImages.add(image);
        continue;
      }
      final bytes = await _imageFiles.readBytes(image.localPath!);
      if (bytes == null) {
        resolvedImages.add(image);
        continue;
      }
      final extension = image.localPath!.split('.').last;
      final url = await _remote.uploadImage(
        userId: userId,
        noteId: note.id,
        imageId: image.id,
        bytes: bytes,
        fileExtension: extension,
      );
      resolvedImages.add(image.copyWith(remoteUrl: url));
      imagesChanged = true;
    }

    final noteToPush = imagesChanged ? note.copyWith(images: resolvedImages) : note;
    if (imagesChanged) {
      await _local.upsertNote(noteToPush, userId: userId);
    }
    await _remote.pushNote(userId, noteToPush);
  }

  @override
  Future<void> pullIncremental(String entityType) async {
    final userId = _currentUser.userId;
    if (userId == null) return;

    switch (entityType) {
      case 'notes':
        final since = await _syncState.getLastPulledAt(userId: userId, entityType: 'notes');
        final remoteNotes = await _remote.pullNotesSince(userId, since);
        for (final note in remoteNotes) {
          await _local.upsertNote(note, userId: userId);
        }
        if (remoteNotes.isNotEmpty) {
          await _syncState.setLastPulledAt(
            userId: userId,
            entityType: 'notes',
            lastPulledAt: _maxUpdatedAt(remoteNotes.map((n) => n.updatedAt)),
          );
        }
      case 'note_folders':
        final since = await _syncState.getLastPulledAt(userId: userId, entityType: 'note_folders');
        final remoteFolders = await _remote.pullFoldersSince(userId, since);
        for (final folder in remoteFolders) {
          await _local.upsertFolder(folder, userId: userId);
        }
        if (remoteFolders.isNotEmpty) {
          await _syncState.setLastPulledAt(
            userId: userId,
            entityType: 'note_folders',
            lastPulledAt: _maxUpdatedAt(remoteFolders.map((f) => f.updatedAt)),
          );
        }
    }
  }

  DateTime _maxUpdatedAt(Iterable<DateTime> dates) => dates.reduce((a, b) => a.isAfter(b) ? a : b);
}
