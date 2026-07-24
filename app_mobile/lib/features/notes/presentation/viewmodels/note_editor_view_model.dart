import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/note.dart';
import '../../notes_providers.dart';

sealed class NoteEditorState extends Equatable {
  const NoteEditorState();

  @override
  List<Object?> get props => [];
}

class NoteEditorLoading extends NoteEditorState {
  const NoteEditorLoading();
}

class NoteEditorNotFound extends NoteEditorState {
  const NoteEditorNotFound();
}

class NoteEditorLoaded extends NoteEditorState {
  const NoteEditorLoaded({required this.note, required this.isPreviewMode});

  final Note note;
  final bool isPreviewMode;

  NoteEditorLoaded copyWith({Note? note, bool? isPreviewMode}) =>
      NoteEditorLoaded(note: note ?? this.note, isPreviewMode: isPreviewMode ?? this.isPreviewMode);

  @override
  List<Object?> get props => [note, isPreviewMode];
}

/// Loads a note once (never re-watches the live stream afterwards — see
/// below), then holds it as locally-editable state, autosaving on a
/// debounce so every keystroke doesn't enqueue its own `Outbox` row and
/// Firestore write.
///
/// Deliberately loads with a one-time read (`.first` on the watch
/// stream) rather than continuing to `ref.watch` it: this note's row
/// keeps changing out from under the user as *this same save flow*
/// writes it, and could also change from a concurrent background
/// `NotesSyncWorker.pullIncremental` — reactively rebuilding editor state
/// from either would silently overwrite whatever the user is mid-typing.
/// An editor is load-once-then-locally-authoritative-until-saved, the
/// same model most note apps use.
class NoteEditorViewModel extends Notifier<NoteEditorState> {
  NoteEditorViewModel(this._noteId);
  final String _noteId;

  Timer? _debounce;
  bool _dirty = false;

  static const _debounceDuration = Duration(milliseconds: 800);

  @override
  NoteEditorState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const NoteEditorLoading();
  }

  Future<void> load() async {
    final note = await ref.read(watchNoteByIdUseCaseProvider)(_noteId).first;
    state = note == null
        ? const NoteEditorNotFound()
        : NoteEditorLoaded(note: note, isPreviewMode: false);
  }

  void updateTitle(String title) => _update((note) => note.copyWith(title: title));

  void updateBody(String body) => _update((note) => note.copyWith(bodyMarkdown: body));

  void togglePreview() {
    final current = state;
    if (current is! NoteEditorLoaded) return;
    state = current.copyWith(isPreviewMode: !current.isPreviewMode);
  }

  Future<Failure?> toggleBookmark() async {
    final current = state;
    if (current is! NoteEditorLoaded) return null;
    state = current.copyWith(note: current.note.copyWith(isBookmarked: !current.note.isBookmarked));
    return flush();
  }

  Future<Failure?> moveToFolder(String? folderId) async {
    final current = state;
    if (current is! NoteEditorLoaded) return null;
    state = current.copyWith(
      note: current.note.copyWith(folderId: folderId, clearFolder: folderId == null),
    );
    return flush();
  }

  Future<Failure?> insertImage({required bool fromCamera}) async {
    final current = state;
    if (current is! NoteEditorLoaded) return null;

    final result = fromCamera
        ? await ref.read(addNoteImageFromCameraUseCaseProvider)()
        : await ref.read(addNoteImageFromGalleryUseCaseProvider)();

    return result.when(
      success: (image) {
        if (image == null) return null; // User cancelled the picker.
        _update(
          (note) => note.copyWith(
            images: [...note.images, image],
            bodyMarkdown: '${note.bodyMarkdown}\n\n![](med100-image:${image.id})\n',
          ),
        );
        return null;
      },
      failure: (failure) => failure,
    );
  }

  void _update(Note Function(Note note) transform) {
    final current = state;
    if (current is! NoteEditorLoaded) return;
    state = current.copyWith(note: transform(current.note));
    _dirty = true;
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () => unawaited(flush()));
  }

  /// Cancels any pending debounce and saves immediately if there are
  /// unsaved changes — called both by the debounce timer itself and
  /// explicitly by the screen before navigating away, so an intentional
  /// exit never waits out the debounce window.
  Future<Failure?> flush() async {
    _debounce?.cancel();
    if (!_dirty) return null;
    final current = state;
    if (current is! NoteEditorLoaded) return null;
    _dirty = false;
    final result = await ref.read(saveNoteUseCaseProvider)(current.note);
    return result.failureOrNull;
  }
}

final noteEditorViewModelProvider =
    NotifierProvider.family<NoteEditorViewModel, NoteEditorState, String>(NoteEditorViewModel.new);
