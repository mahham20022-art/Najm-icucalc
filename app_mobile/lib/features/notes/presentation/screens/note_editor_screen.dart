import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_folder.dart';
import '../../markdown/highlight_syntax.dart';
import '../../notes_providers.dart';
import '../viewmodels/note_editor_view_model.dart';
import '../widgets/highlight_element_builder.dart';
import '../widgets/note_image_builder.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, required this.noteId});
  final String noteId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _controllersSeeded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(noteEditorViewModelProvider(widget.noteId).notifier).load());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  NoteEditorViewModel get _viewModel =>
      ref.read(noteEditorViewModelProvider(widget.noteId).notifier);

  Future<void> _handleBack() async {
    final failure = await _viewModel.flush();
    if (failure != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
    }
    if (mounted) Navigator.of(context).pop();
  }

  void _seedControllersOnce(Note note) {
    if (_controllersSeeded) return;
    _controllersSeeded = true;
    _titleController.text = note.title;
    _bodyController.text = note.bodyMarkdown;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(noteEditorViewModelProvider(widget.noteId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => unawaited(_handleBack()),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
            onPressed: _handleBack,
          ),
          title: const Text('Note'),
          actions: switch (state) {
            NoteEditorLoaded(:final note, :final isPreviewMode) => [
              IconButton(
                icon: Icon(note.isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                tooltip: note.isBookmarked ? 'Remove bookmark' : 'Add bookmark',
                onPressed: () async {
                  unawaited(HapticFeedback.selectionClick());
                  final failure = await _viewModel.toggleBookmark();
                  if (failure != null && context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(failure.message)));
                  }
                },
              ),
              IconButton(
                icon: Icon(isPreviewMode ? Icons.edit_outlined : Icons.visibility_outlined),
                tooltip: isPreviewMode ? 'Edit' : 'Preview',
                onPressed: _viewModel.togglePreview,
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'move', child: Text('Move to Folder')),
                  PopupMenuItem(value: 'export', child: Text('Export PDF')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
            _ => const <Widget>[],
          },
        ),
        body: switch (state) {
          NoteEditorLoading() => const Center(child: CircularProgressIndicator()),
          NoteEditorNotFound() => const Center(child: Text('This note no longer exists.')),
          NoteEditorLoaded(:final note, :final isPreviewMode) => _buildLoaded(
            context,
            note,
            isPreviewMode,
          ),
        },
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, Note note, bool isPreviewMode) {
    _seedControllersOnce(note);
    return Column(
      children: [
        if (!isPreviewMode)
          _EditorToolbar(
            noteId: widget.noteId,
            bodyController: _bodyController,
            onChanged: _viewModel.updateBody,
          ),
        Expanded(
          child: isPreviewMode
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  child: Markdown(
                    data: note.bodyMarkdown.isEmpty ? '_Nothing here yet._' : note.bodyMarkdown,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    inlineSyntaxes: [HighlightSyntax()],
                    builders: {'mark': HighlightElementBuilder()},
                    imageBuilder: NoteImageBuilder({
                      for (final image in note.images) image.id: image,
                    }).build,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _titleController,
                        style: Theme.of(context).textTheme.headlineSmall,
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          border: InputBorder.none,
                        ),
                        onChanged: _viewModel.updateTitle,
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: TextField(
                          controller: _bodyController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            hintText: 'Write in Markdown…',
                            border: InputBorder.none,
                          ),
                          onChanged: _viewModel.updateBody,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _handleMenuAction(BuildContext context, String action) async {
    switch (action) {
      case 'move':
        await _showMoveToFolderDialog(context);
      case 'export':
        await _exportPdf(context);
      case 'delete':
        await _confirmDelete(context);
    }
  }

  Future<void> _showMoveToFolderDialog(BuildContext context) async {
    final folders = ref.read(noteFoldersProvider).value ?? const <NoteFolder>[];
    final selected = await showDialog<String?>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Move to Folder'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Unfiled'),
          ),
          for (final folder in folders)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(folder.id),
              child: Text(folder.name),
            ),
        ],
      ),
    );
    if (!context.mounted) return;
    await _viewModel.moveToFolder(selected);
  }

  Future<void> _exportPdf(BuildContext context) async {
    final state = ref.read(noteEditorViewModelProvider(widget.noteId));
    if (state is! NoteEditorLoaded) return;
    final result = await ref.read(exportNotePdfUseCaseProvider)(state.note);
    if (!context.mounted) return;
    await result.when(
      success: (bytes) => Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: state.note.title.trim().isEmpty ? 'Note' : state.note.title,
      ),
      failure: (failure) async =>
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final colors = AppColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: colors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(deleteNoteUseCaseProvider)(widget.noteId);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _EditorToolbar extends ConsumerWidget {
  const _EditorToolbar({
    required this.noteId,
    required this.bodyController,
    required this.onChanged,
  });

  final String noteId;
  final TextEditingController bodyController;
  final ValueChanged<String> onChanged;

  void _wrap(String left, [String? right]) {
    final marker = right ?? left;
    final selection = bodyController.selection;
    final text = bodyController.text;
    if (!selection.isValid) return;
    final start = selection.start;
    final end = selection.end;
    final selected = text.substring(start, end);
    final newText = text.replaceRange(start, end, '$left$selected$marker');
    bodyController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: end + left.length + marker.length),
    );
    onChanged(newText);
  }

  Future<void> _insertImage(BuildContext context, WidgetRef ref, {required bool fromCamera}) async {
    final failure = await ref
        .read(noteEditorViewModelProvider(noteId).notifier)
        .insertImage(fromCamera: fromCamera);
    if (failure != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.format_bold),
            tooltip: 'Bold',
            onPressed: () => _wrap('**'),
          ),
          IconButton(
            icon: const Icon(Icons.format_italic),
            tooltip: 'Italic',
            onPressed: () => _wrap('*'),
          ),
          IconButton(
            icon: const Icon(Icons.border_color_outlined),
            tooltip: 'Highlight',
            onPressed: () => _wrap('=='),
          ),
          IconButton(
            icon: const Icon(Icons.image_outlined),
            tooltip: 'Insert image from gallery',
            onPressed: () => _insertImage(context, ref, fromCamera: false),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            tooltip: 'Take a photo',
            onPressed: () => _insertImage(context, ref, fromCamera: true),
          ),
        ],
      ),
    );
  }
}
