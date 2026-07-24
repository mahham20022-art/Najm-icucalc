import '../../../../core/error/result.dart';
import '../entities/note_image.dart';
import '../repositories/notes_repository.dart';

class AddNoteImageFromCameraUseCase {
  const AddNoteImageFromCameraUseCase(this._repository);
  final NotesRepository _repository;

  Future<Result<NoteImage?>> call() => _repository.addImageFromCamera();
}
