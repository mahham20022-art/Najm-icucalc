import '../entities/note_folder.dart';
import '../repositories/notes_repository.dart';

class WatchFoldersUseCase {
  const WatchFoldersUseCase(this._repository);
  final NotesRepository _repository;

  Stream<List<NoteFolder>> call() => _repository.watchFolders();
}
