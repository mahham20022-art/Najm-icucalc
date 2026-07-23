import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/comparison_table.dart';

class ComparisonTableView extends StatelessWidget {
  const ComparisonTableView({super.key, required this.table});

  final ComparisonTable table;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space5),
      children: [
        Text(table.title, style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.space4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(colors.backgroundSecondary),
            columns: [for (final column in table.columns) DataColumn(label: Text(column))],
            rows: [
              for (final row in table.rows)
                DataRow(cells: [for (final cell in row) DataCell(Text(cell))]),
            ],
          ),
        ),
      ],
    );
  }
}
