import '../../../../core/error/result.dart';
import '../repositories/notes_repository.dart';

class DeleteFolderUseCase {
  const DeleteFolderUseCase(this._repository);
  final NotesRepository _repository;

  Future<Result<void>> call(String folderId) => _repository.deleteFolder(folderId);
}
