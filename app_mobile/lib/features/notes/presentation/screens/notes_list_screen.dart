import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_folder.dart';
import '../../notes_providers.dart';

sealed class _FilterSelection {
  const _FilterSelection();
}

class _AllFilter extends _FilterSelection {
  const _AllFilter();
}

class _UnfiledFilter extends _FilterSelection {
  const _UnfiledFilter();
}

class _BookmarkedFilter extends _FilterSelection {
  const _BookmarkedFilter();
}

class _FolderFilter extends _FilterSelection {
  const _FolderFilter(this.folder);
  final NoteFolder folder;
}

/// The Notes home screen: a folder chip row (All / Unfiled / Bookmarked /
/// each user folder) filtering the note list below it.
class NotesListScreen extends ConsumerStatefulWidget {
  const NotesListScreen({super.key});

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
  _FilterSelection _selection = const _AllFilter();

  NotesFilter get _filter => switch (_selection) {
    _AllFilter() => (folderId: null, unfiledOnly: false, onlyBookmarked: false),
    _UnfiledFilter() => (folderId: null, unfiledOnly: true, onlyBookmarked: false),
    _BookmarkedFilter() => (folderId: null, unfiledOnly: false, onlyBookmarked: true),
    _FolderFilter(:final folder) => (
      folderId: folder.id,
      unfiledOnly: false,
      onlyBookmarked: false,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final foldersAsync = ref.watch(noteFoldersProvider);
    final notesAsync = ref.watch(notesListProvider(_filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: 'New folder',
            onPressed: () => _createFolder(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterChipRow(
            selection: _selection,
            folders: foldersAsync.value ?? const [],
            onSelect: (selection) => setState(() => _selection = selection),
            onFolderLongPress: (folder) => _showFolderActions(context, folder),
          ),
          const Divider(height: 1),
          Expanded(
            child: notesAsync.when(
              data: (notes) => notes.isEmpty
                  ? const _EmptyNotesView()
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.space3),
                      itemCount: notes.length,
                      itemBuilder: (context, index) => _NoteListTile(note: notes[index]),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(child: Text('Could not load notes.')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNote(context),
        tooltip: 'New note',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createNote(BuildContext context) async {
    final folderId = switch (_selection) {
      _FolderFilter(:final folder) => folder.id,
      _ => null,
    };
    final result = await ref.read(createNoteUseCaseProvider)(folderId: folderId);
    if (!context.mounted) return;
    result.when(
      success: (note) =>
          context.pushNamed(AppRoute.noteEditor, pathParameters: {'noteId': note.id}),
      failure: (failure) =>
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _createFolder(BuildContext context) async {
    final name = await _promptForName(context, title: 'New Folder');
    if (name == null || name.trim().isEmpty) return;
    if (!context.mounted) return;
    final result = await ref.read(createFolderUseCaseProvider)(name);
    if (!context.mounted) return;
    result.when(
      success: (folder) => setState(() => _selection = _FolderFilter(folder)),
      failure: (failure) =>
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _showFolderActions(BuildContext context, NoteFolder folder) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () => Navigator.of(sheetContext).pop('rename'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete'),
              onTap: () => Navigator.of(sheetContext).pop('delete'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || action == null) return;

    if (action == 'rename') {
      final name = await _promptForName(context, title: 'Rename Folder', initialValue: folder.name);
      if (name == null || name.trim().isEmpty || !context.mounted) return;
      await ref.read(renameFolderUseCaseProvider)(folderId: folder.id, name: name);
    } else if (action == 'delete') {
      if (_selection is _FolderFilter && (_selection as _FolderFilter).folder.id == folder.id) {
        setState(() => _selection = const _AllFilter());
      }
      await ref.read(deleteFolderUseCaseProvider)(folder.id);
    }
  }

  Future<String?> _promptForName(
    BuildContext context, {
    required String title,
    String initialValue = '',
  }) {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({
    required this.selection,
    required this.folders,
    required this.onSelect,
    required this.onFolderLongPress,
  });

  final _FilterSelection selection;
  final List<NoteFolder> folders;
  final ValueChanged<_FilterSelection> onSelect;
  final ValueChanged<NoteFolder> onFolderLongPress;

  bool _isSelected(_FilterSelection candidate) => switch ((selection, candidate)) {
    (_AllFilter(), _AllFilter()) => true,
    (_UnfiledFilter(), _UnfiledFilter()) => true,
    (_BookmarkedFilter(), _BookmarkedFilter()) => true,
    (_FolderFilter(:final folder), _FolderFilter(folder: final other)) => folder.id == other.id,
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    // A fixed-height `SizedBox` previously wrapped this row — at large
    // accessibility text sizes the `ChoiceChip` labels grow taller than
    // 48px and were clipped. `SingleChildScrollView` + `Row` lets the
    // row's height follow its children's actual (scaled) size instead.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space2,
      ),
      child: Row(
        children: [
          _chip(context, label: 'All', selection: const _AllFilter()),
          const SizedBox(width: AppSpacing.space2),
          _chip(context, label: 'Unfiled', selection: const _UnfiledFilter()),
          const SizedBox(width: AppSpacing.space2),
          _chip(
            context,
            label: 'Bookmarked',
            selection: const _BookmarkedFilter(),
            icon: Icons.bookmark,
          ),
          for (final folder in folders) ...[
            const SizedBox(width: AppSpacing.space2),
            GestureDetector(
              onLongPress: () => onFolderLongPress(folder),
              child: _chip(context, label: folder.name, selection: _FolderFilter(folder)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required _FilterSelection selection,
    IconData? icon,
  }) {
    final selected = _isSelected(selection);
    return ChoiceChip(
      label: Text(label),
      avatar: icon == null ? null : Icon(icon, size: 16),
      selected: selected,
      onSelected: (_) => onSelect(selection),
    );
  }
}

class _NoteListTile extends ConsumerWidget {
  const _NoteListTile({required this.note});
  final Note note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final snippet = note.bodyMarkdown.replaceAll(RegExp(r'[#*`>=_\-\[\]!]'), '').trim();
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.space2),
      child: ListTile(
        title: Text(
          note.title.trim().isEmpty ? 'Untitled' : note.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          snippet.isEmpty ? 'No content' : snippet,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(
                note.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: note.isBookmarked ? colors.warning : colors.labelTertiary,
              ),
              tooltip: note.isBookmarked ? 'Remove bookmark' : 'Add bookmark',
              onPressed: () => ref.read(toggleBookmarkUseCaseProvider)(note.id),
            ),
            Text(
              DateFormat.MMMd().format(note.updatedAt),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.labelTertiary),
            ),
          ],
        ),
        onTap: () => context.pushNamed(AppRoute.noteEditor, pathParameters: {'noteId': note.id}),
      ),
    );
  }
}

class _EmptyNotesView extends StatelessWidget {
  const _EmptyNotesView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.note_outlined, size: 48, color: colors.labelTertiary),
            const SizedBox(height: AppSpacing.space4),
            Text('No notes here yet', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
