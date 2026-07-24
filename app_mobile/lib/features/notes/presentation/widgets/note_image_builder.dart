import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/note_image.dart';

/// Resolves a `![alt](med100-image:<id>)` reference (see
/// `Notes.imagesJson`'s doc comment) to an actual image widget: the
/// local file if this device has one, else the Firebase Storage URL if
/// synced, else a broken-image placeholder (e.g. a note synced in from
/// another device whose images haven't been fetched to this one yet).
class NoteImageBuilder {
  const NoteImageBuilder(this.images);

  final Map<String, NoteImage> images;

  static const _scheme = 'med100-image';

  /// A note image is an inline markdown attachment, never a full-screen
  /// viewer — decoding at the picker's already-capped 1600px source
  /// resolution just to paint a few hundred logical pixels wastes
  /// decode time and memory on every render. `imageBuilder` has no
  /// `BuildContext` to size this against the actual layout width, so a
  /// fixed value that comfortably covers this app's inline display size
  /// (including higher-DPI devices) is used instead of a dynamic one.
  static const _cacheWidth = 800;

  Widget build(Uri uri, String? title, String? alt) {
    if (uri.scheme != _scheme) return const SizedBox.shrink();
    final image = images[uri.path];
    if (image == null) return _placeholder();

    final localPath = image.localPath;
    if (localPath != null) {
      return Image.file(
        File(localPath),
        cacheWidth: _cacheWidth,
        errorBuilder: (context, error, stackTrace) =>
            image.remoteUrl != null
                ? Image.network(image.remoteUrl!, cacheWidth: _cacheWidth)
                : _placeholder(),
      );
    }
    if (image.remoteUrl != null) {
      return Image.network(image.remoteUrl!, cacheWidth: _cacheWidth);
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
    width: 120,
    height: 120,
    color: Colors.grey.shade300,
    child: const Icon(Icons.broken_image_outlined),
  );
}
