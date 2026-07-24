import '../../../../core/error/result.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class CreateNoteUseCase {
  const CreateNoteUseCase(this._repository);
  final NotesRepository _repository;

  Future<Result<Note>> call({String? folderId}) => _repository.createNote(folderId: folderId);
}
