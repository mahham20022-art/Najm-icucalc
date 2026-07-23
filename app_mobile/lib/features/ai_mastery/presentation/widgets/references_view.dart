import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/reference_entry.dart';

class ReferencesView extends StatelessWidget {
  const ReferencesView({super.key, required this.references});

  final List<ReferenceEntry> references;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    if (references.isEmpty) {
      return const Center(child: Text('No references available.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.space5),
      itemCount: references.length,
      separatorBuilder: (context, index) => const Divider(height: AppSpacing.space5),
      itemBuilder: (context, index) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.menu_book_outlined, size: 18, color: colors.labelSecondary),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Text(references[index].citation, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
