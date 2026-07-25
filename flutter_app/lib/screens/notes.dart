import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: context.read<AppState>().notes);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        InfoCard(
          title: 'Shift Notes',
          subtitle: 'Plain-text scratchpad — stored locally on this device only.',
          children: [
            TextField(
              controller: _c,
              maxLines: 12,
              onChanged: (v) => context.read<AppState>().setNotes(v),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14, height: 1.5),
              decoration: const InputDecoration(
                hintText: 'Patient summary, plan, pending tasks, handover…',
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _c.text));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard'), duration: Duration(milliseconds: 1200)),
                    );
                  },
                  child: const Text('Copy'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        backgroundColor: AppColors.panel,
                        title: const Text('Clear all notes?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text('Clear', style: TextStyle(color: AppColors.danger)),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      _c.clear();
                      if (context.mounted) context.read<AppState>().setNotes('');
                    }
                  },
                  child: const Text('Clear', style: TextStyle(color: AppColors.danger)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
