import '../../../../core/error/result.dart';
import '../repositories/notes_repository.dart';

class DeleteNoteUseCase {
  const DeleteNoteUseCase(this._repository);
  final NotesRepository _repository;

  Future<Result<void>> call(String noteId) => _repository.deleteNote(noteId);
}
