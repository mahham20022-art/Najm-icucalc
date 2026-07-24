import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/entities/note.dart';
import '../../domain/entities/note_folder.dart';
import '../../domain/entities/note_image.dart';

/// Owns Firestore (`users/{userId}/notes`, `users/{userId}/noteFolders`)
/// and Firebase Storage (`users/{userId}/notes/{noteId}/images/`) access
/// for `features/notes` — the first feature in this codebase to
/// implement real bidirectional cloud sync (see `NotesSyncWorker`).
///
/// A note's Firestore `images` field intentionally omits `localPath`
/// (a device-local path is meaningless on another device) — only `id`
/// and `remoteUrl` cross the wire.
class NotesRemoteDataSource {
  NotesRemoteDataSource({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _notes(String userId) =>
      _firestore.collection('users').doc(userId).collection('notes');

  CollectionReference<Map<String, dynamic>> _folders(String userId) =>
      _firestore.collection('users').doc(userId).collection('noteFolders');

  Future<void> pushNote(String userId, Note note) {
    return _notes(userId).doc(note.id).set({
      'folderId': note.folderId,
      'title': note.title,
      'bodyMarkdown': note.bodyMarkdown,
      'images': [
        for (final image in note.images)
          if (image.remoteUrl != null) {'id': image.id, 'remoteUrl': image.remoteUrl},
      ],
      'isBookmarked': note.isBookmarked,
      'createdAt': Timestamp.fromDate(note.createdAt),
      'updatedAt': Timestamp.fromDate(note.updatedAt),
    });
  }

  Future<void> deleteNote(String userId, String noteId) => _notes(userId).doc(noteId).delete();

  Future<void> pushFolder(String userId, NoteFolder folder) {
    return _folders(userId).doc(folder.id).set({
      'name': folder.name,
      'createdAt': Timestamp.fromDate(folder.createdAt),
      'updatedAt': Timestamp.fromDate(folder.updatedAt),
    });
  }

  Future<void> deleteFolder(String userId, String folderId) =>
      _folders(userId).doc(folderId).delete();

  /// `since == null` pulls every note (first sync on this device).
  Future<List<Note>> pullNotesSince(String userId, DateTime? since) async {
    Query<Map<String, dynamic>> query = _notes(userId).orderBy('updatedAt');
    if (since != null) {
      query = query.where('updatedAt', isGreaterThan: Timestamp.fromDate(since));
    }
    final snapshot = await query.get();
    return snapshot.docs.map(_noteFromDoc).toList();
  }

  Future<List<NoteFolder>> pullFoldersSince(String userId, DateTime? since) async {
    Query<Map<String, dynamic>> query = _folders(userId).orderBy('updatedAt');
    if (since != null) {
      query = query.where('updatedAt', isGreaterThan: Timestamp.fromDate(since));
    }
    final snapshot = await query.get();
    return snapshot.docs.map(_folderFromDoc).toList();
  }

  Future<String> uploadImage({
    required String userId,
    required String noteId,
    required String imageId,
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    final ref = _storage.ref('users/$userId/notes/$noteId/images/$imageId.$fileExtension');
    final snapshot = await ref.putData(bytes);
    return snapshot.ref.getDownloadURL();
  }

  /// Best-effort cleanup when a note is deleted — a failure here leaves
  /// orphaned Storage objects, which costs storage but not correctness,
  /// so it's never allowed to fail the delete itself.
  Future<void> deleteAllImages(String userId, String noteId) async {
    try {
      final folderRef = _storage.ref('users/$userId/notes/$noteId/images');
      final listing = await folderRef.listAll();
      for (final item in listing.items) {
        await item.delete();
      }
    } catch (_) {
      // Orphaned Storage objects are a cost-cleanup concern, not a
      // correctness one — never block a note deletion on this.
    }
  }

  Note _noteFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final rawImages = (data['images'] as List?) ?? const [];
    return Note(
      id: doc.id,
      folderId: data['folderId'] as String?,
      title: data['title'] as String? ?? '',
      bodyMarkdown: data['bodyMarkdown'] as String? ?? '',
      images: rawImages
          .cast<Map<String, dynamic>>()
          .map((map) => NoteImage(id: map['id'] as String, remoteUrl: map['remoteUrl'] as String?))
          .toList(),
      isBookmarked: data['isBookmarked'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  NoteFolder _folderFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return NoteFolder(
      id: doc.id,
      name: data['name'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
