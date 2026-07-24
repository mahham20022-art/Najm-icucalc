import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Wraps `image_picker` so nothing outside the data layer depends on the
/// plugin directly (same convention as `RevenueCatDataSource` wrapping
/// `purchases_flutter`). Returns raw bytes + a file extension rather
/// than an `XFile`/path — the caller (`NotesRepositoryImpl.addImage`)
/// only ever needs to persist bytes into this app's own local storage.
class NoteImagePickerDataSource {
  NoteImagePickerDataSource({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Extensions this app will ever construct a local file path or
  /// Firebase Storage object path from. `XFile.name` on web comes
  /// straight from the browser's `File.name` — arbitrary JS-controlled
  /// metadata that could otherwise carry a path separator or an
  /// unexpected extension — so this is a hard allowlist, not just a
  /// cosmetic default, and is checked *before* the value ever reaches
  /// `NoteImageFileDataSource`/`NotesRemoteDataSource`'s string-built
  /// paths.
  static const _allowedExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif'};

  /// Caps decoded pixel dimensions at pick time — a photo straight off a
  /// modern phone camera is typically 3000-4000px on a side, far larger
  /// than this app ever displays a note image (an inline markdown
  /// attachment, not a full-screen viewer), so resizing here shrinks
  /// local storage footprint, Firebase Storage upload size, and later
  /// decode cost all at once.
  static const _maxDimension = 1600.0;

  Future<({Uint8List bytes, String extension})?> pickFromGallery() => _pick(ImageSource.gallery);

  Future<({Uint8List bytes, String extension})?> pickFromCamera() => _pick(ImageSource.camera);

  Future<({Uint8List bytes, String extension})?> _pick(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: _maxDimension,
      maxHeight: _maxDimension,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return (bytes: bytes, extension: _safeExtension(file.name));
  }

  String _safeExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1) return 'jpg';
    final candidate = fileName.substring(dotIndex + 1).toLowerCase();
    return _allowedExtensions.contains(candidate) ? candidate : 'jpg';
  }
}
