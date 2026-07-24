import '../../../../core/error/result.dart';
import '../entities/note_folder.dart';
import '../repositories/notes_repository.dart';

class CreateFolderUseCase {
  const CreateFolderUseCase(this._repository);
  final NotesRepository _repository;

  Future<Result<NoteFolder>> call(String name) => _repository.createFolder(name);
}
