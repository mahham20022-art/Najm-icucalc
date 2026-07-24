import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class WatchNotesUseCase {
  const WatchNotesUseCase(this._repository);
  final NotesRepository _repository;

  Stream<List<Note>> call({
    String? folderId,
    bool unfiledOnly = false,
    bool onlyBookmarked = false,
  }) => _repository.watchNotes(
    folderId: folderId,
    unfiledOnly: unfiledOnly,
    onlyBookmarked: onlyBookmarked,
  );
}
