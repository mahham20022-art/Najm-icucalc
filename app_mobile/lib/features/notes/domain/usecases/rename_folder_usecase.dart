import '../../../../core/error/result.dart';
import '../repositories/notes_repository.dart';

class RenameFolderUseCase {
  const RenameFolderUseCase(this._repository);
  final NotesRepository _repository;

  Future<Result<void>> call({required String folderId, required String name}) =>
      _repository.renameFolder(folderId: folderId, name: name);
}
