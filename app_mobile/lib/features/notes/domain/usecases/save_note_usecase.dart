import '../../../../core/error/result.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class SaveNoteUseCase {
  const SaveNoteUseCase(this._repository);
  final NotesRepository _repository;

  Future<Result<void>> call(Note note) => _repository.saveNote(note);
}
