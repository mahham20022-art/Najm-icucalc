import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Owns this app's own local copy of note images, under
/// `<app documents>/note_images/`. Not a cache of the Firebase Storage
/// copy — this local file *is* the image on the device that created it;
/// `remoteUrl` (see `NoteImage`) only exists once `NotesSyncWorker`
/// uploads it, for other devices to fetch.
class NoteImageFileDataSource {
  Future<Directory> _imagesDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/note_images');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<String> saveBytes({
    required String imageId,
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    final dir = await _imagesDirectory();
    final file = File('${dir.path}/$imageId.$fileExtension');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// `null` if the file no longer exists on this device (e.g. this note
  /// synced in from another device and the image hasn't been fetched
  /// here) — callers fall back to `remoteUrl` in that case.
  Future<Uint8List?> readBytes(String localPath) async {
    final file = File(localPath);
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  Future<void> delete(String localPath) async {
    final file = File(localPath);
    if (await file.exists()) await file.delete();
  }
}
