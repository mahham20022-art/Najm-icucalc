import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class WatchNoteByIdUseCase {
  const WatchNoteByIdUseCase(this._repository);
  final NotesRepository _repository;

  Stream<Note?> call(String noteId) => _repository.watchNoteById(noteId);
}
