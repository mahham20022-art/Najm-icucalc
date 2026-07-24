import 'package:equatable/equatable.dart';

/// An image attached to a [Note], referenced from its Markdown body by
/// stable id (`![alt](med100-image:<id>)`) rather than by raw path —
/// see `Notes.imagesJson`'s doc comment for why.
///
/// At least one of [localPath]/[remoteUrl] is always non-null in
/// practice: [localPath] is set the moment an image is added on this
/// device (before any upload happens); [remoteUrl] is set once
/// `NotesSyncWorker` uploads it, or immediately for an image pulled down
/// from a note synced from another device (where this device has no
/// local copy yet).
class NoteImage extends Equatable {
  const NoteImage({required this.id, this.localPath, this.remoteUrl});

  final String id;
  final String? localPath;
  final String? remoteUrl;

  NoteImage copyWith({String? localPath, String? remoteUrl}) => NoteImage(
    id: id,
    localPath: localPath ?? this.localPath,
    remoteUrl: remoteUrl ?? this.remoteUrl,
  );

  @override
  List<Object?> get props => [id, localPath, remoteUrl];
}
