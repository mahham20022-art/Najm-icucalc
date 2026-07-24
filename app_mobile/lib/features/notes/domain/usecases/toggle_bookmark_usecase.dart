import '../../../../core/error/result.dart';
import '../repositories/notes_repository.dart';

class ToggleBookmarkUseCase {
  const ToggleBookmarkUseCase(this._repository);
  final NotesRepository _repository;

  Future<Result<void>> call(String noteId) => _repository.toggleBookmark(noteId);
}
