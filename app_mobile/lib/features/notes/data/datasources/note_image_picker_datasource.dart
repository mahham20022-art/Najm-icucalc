import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Wraps `image_picker` so nothing outside the data layer depends on the
/// plugin directly (same convention as `PurchaseDataSource` wrapping
/// `in_app_purchase`). Returns raw bytes + a file extension rather than
/// an `XFile`/path — the caller (`NotesRepositoryImpl.addImage`) only
/// ever needs to persist bytes into this app's own local storage.
class NoteImagePickerDataSource {
  NoteImagePickerDataSource({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<({Uint8List bytes, String extension})?> pickFromGallery() => _pick(ImageSource.gallery);

  Future<({Uint8List bytes, String extension})?> pickFromCamera() => _pick(ImageSource.camera);

  Future<({Uint8List bytes, String extension})?> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final dotIndex = file.name.lastIndexOf('.');
    final extension = dotIndex == -1 ? 'jpg' : file.name.substring(dotIndex + 1).toLowerCase();
    return (bytes: bytes, extension: extension);
  }
}
