import 'dart:typed_data';

import '../../../../core/error/result.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class ExportNotePdfUseCase {
  const ExportNotePdfUseCase(this._repository);
  final NotesRepository _repository;

  Future<Result<Uint8List>> call(Note note) => _repository.exportToPdf(note);
}
