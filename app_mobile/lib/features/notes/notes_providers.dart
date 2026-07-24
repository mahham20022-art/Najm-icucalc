import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap/bootstrap.dart';
import '../../core/session/current_user.dart';
import '../../core/sync/sync_providers.dart';
import 'data/datasources/note_image_file_datasource.dart';
import 'data/datasources/note_image_picker_datasource.dart';
import 'data/datasources/notes_local_datasource.dart';
import 'data/datasources/notes_remote_datasource.dart';
import 'data/notes_sync_worker.dart';
import 'data/repositories/notes_repository_impl.dart';
import 'data/services/note_pdf_exporter.dart';
import 'domain/entities/note.dart';
import 'domain/entities/note_folder.dart';
import 'domain/repositories/notes_repository.dart';
import 'domain/usecases/add_note_image_from_camera_usecase.dart';
import 'domain/usecases/add_note_image_from_gallery_usecase.dart';
import 'domain/usecases/create_folder_usecase.dart';
import 'domain/usecases/create_note_usecase.dart';
import 'domain/usecases/delete_folder_usecase.dart';
import 'domain/usecases/delete_note_usecase.dart';
import 'domain/usecases/export_note_pdf_usecase.dart';
import 'domain/usecases/rename_folder_usecase.dart';
import 'domain/usecases/save_note_usecase.dart';
import 'domain/usecases/toggle_bookmark_usecase.dart';
import 'domain/usecases/watch_folders_usecase.dart';
import 'domain/usecases/watch_note_by_id_usecase.dart';
import 'domain/usecases/watch_notes_usecase.dart';

final notesLocalDataSourceProvider = Provider<NotesLocalDataSource>((ref) {
  return NotesLocalDataSource(ref.watch(appDatabaseProvider));
});

final notesRemoteDataSourceProvider = Provider<NotesRemoteDataSource>((ref) {
  return NotesRemoteDataSource();
});

final noteImagePickerDataSourceProvider = Provider<NoteImagePickerDataSource>((ref) {
  return NoteImagePickerDataSource();
});

final noteImageFileDataSourceProvider = Provider<NoteImageFileDataSource>((ref) {
  return NoteImageFileDataSource();
});

final notePdfExporterProvider = Provider<NotePdfExporter>((ref) {
  return NotePdfExporter(ref.watch(noteImageFileDataSourceProvider));
});

final notesSyncWorkerProvider = Provider<NotesSyncWorker>((ref) {
  return NotesSyncWorker(
    localDataSource: ref.watch(notesLocalDataSourceProvider),
    remoteDataSource: ref.watch(notesRemoteDataSourceProvider),
    outbox: ref.watch(outboxLocalDataSourceProvider),
    syncState: ref.watch(syncStateLocalDataSourceProvider),
    imageFiles: ref.watch(noteImageFileDataSourceProvider),
    currentUser: ref.watch(currentUserProvider),
  );
});

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepositoryImpl(
    localDataSource: ref.watch(notesLocalDataSourceProvider),
    outbox: ref.watch(outboxLocalDataSourceProvider),
    imagePicker: ref.watch(noteImagePickerDataSourceProvider),
    imageFiles: ref.watch(noteImageFileDataSourceProvider),
    pdfExporter: ref.watch(notePdfExporterProvider),
    currentUser: ref.watch(currentUserProvider),
  );
});

final watchFoldersUseCaseProvider = Provider<WatchFoldersUseCase>((ref) {
  return WatchFoldersUseCase(ref.watch(notesRepositoryProvider));
});

final createFolderUseCaseProvider = Provider<CreateFolderUseCase>((ref) {
  return CreateFolderUseCase(ref.watch(notesRepositoryProvider));
});

final renameFolderUseCaseProvider = Provider<RenameFolderUseCase>((ref) {
  return RenameFolderUseCase(ref.watch(notesRepositoryProvider));
});

final deleteFolderUseCaseProvider = Provider<DeleteFolderUseCase>((ref) {
  return DeleteFolderUseCase(ref.watch(notesRepositoryProvider));
});

final watchNotesUseCaseProvider = Provider<WatchNotesUseCase>((ref) {
  return WatchNotesUseCase(ref.watch(notesRepositoryProvider));
});

final watchNoteByIdUseCaseProvider = Provider<WatchNoteByIdUseCase>((ref) {
  return WatchNoteByIdUseCase(ref.watch(notesRepositoryProvider));
});

final createNoteUseCaseProvider = Provider<CreateNoteUseCase>((ref) {
  return CreateNoteUseCase(ref.watch(notesRepositoryProvider));
});

final saveNoteUseCaseProvider = Provider<SaveNoteUseCase>((ref) {
  return SaveNoteUseCase(ref.watch(notesRepositoryProvider));
});

final deleteNoteUseCaseProvider = Provider<DeleteNoteUseCase>((ref) {
  return DeleteNoteUseCase(ref.watch(notesRepositoryProvider));
});

final toggleBookmarkUseCaseProvider = Provider<ToggleBookmarkUseCase>((ref) {
  return ToggleBookmarkUseCase(ref.watch(notesRepositoryProvider));
});

final addNoteImageFromGalleryUseCaseProvider = Provider<AddNoteImageFromGalleryUseCase>((ref) {
  return AddNoteImageFromGalleryUseCase(ref.watch(notesRepositoryProvider));
});

final addNoteImageFromCameraUseCaseProvider = Provider<AddNoteImageFromCameraUseCase>((ref) {
  return AddNoteImageFromCameraUseCase(ref.watch(notesRepositoryProvider));
});

final exportNotePdfUseCaseProvider = Provider<ExportNotePdfUseCase>((ref) {
  return ExportNotePdfUseCase(ref.watch(notesRepositoryProvider));
});

final noteFoldersProvider = StreamProvider<List<NoteFolder>>((ref) {
  return ref.watch(watchFoldersUseCaseProvider)();
});

typedef NotesFilter = ({String? folderId, bool unfiledOnly, bool onlyBookmarked});

final notesListProvider = StreamProvider.autoDispose.family<List<Note>, NotesFilter>((ref, filter) {
  return ref.watch(watchNotesUseCaseProvider)(
    folderId: filter.folderId,
    unfiledOnly: filter.unfiledOnly,
    onlyBookmarked: filter.onlyBookmarked,
  );
});

final noteByIdProvider = StreamProvider.autoDispose.family<Note?, String>((ref, noteId) {
  return ref.watch(watchNoteByIdUseCaseProvider)(noteId);
});

/// Attempts a pull-then-drain sync pass — safe to call opportunistically
/// (connectivity restored, app resumed): every step is a no-op for a
/// guest session, and both the pull and drain sides are idempotent, so
/// overlapping or repeated calls never corrupt state.
///
/// Takes a [WidgetRef] rather than a bare [Ref] since its only caller so
/// far, `ReminderLifecycleGate`, calls it from widget-lifecycle code.
Future<void> triggerNotesSync(WidgetRef ref) async {
  final userId = ref.read(currentUserProvider).userId;
  if (userId == null) return;

  final worker = ref.read(notesSyncWorkerProvider);
  await worker.pullIncremental('note_folders');
  await worker.pullIncremental('notes');
  await worker.drainOutbox(userId);
}
