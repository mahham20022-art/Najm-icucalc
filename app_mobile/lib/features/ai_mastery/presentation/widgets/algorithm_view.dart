import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/clinical_algorithm.dart';

/// A vertical stepper — each step is a numbered circle connected by a
/// line to the next, with any decision branches shown as indented notes
/// beneath the step. Read top to bottom, not an interactive graph (see
/// `AlgorithmStep`'s doc comment).
class AlgorithmView extends StatelessWidget {
  const AlgorithmView({super.key, required this.algorithm});

  final ClinicalAlgorithm algorithm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final steps = [...algorithm.steps]..sort((a, b) => a.order.compareTo(b.order));

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space5),
      children: [
        Text(algorithm.title, style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.space5),
        for (var i = 0; i < steps.length; i++)
          _buildStep(context, steps[i], isLast: i == steps.length - 1),
      ],
    );
  }

  Widget _buildStep(BuildContext context, AlgorithmStep step, {required bool isLast}) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: colors.accentFill, shape: BoxShape.circle),
                child: Text(
                  '${step.order}',
                  style: textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: colors.separator)),
            ],
          ),
          const SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.text, style: textTheme.bodyLarge),
                  if (step.branches.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.space2),
                    for (final branch in step.branches)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.space1),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.subdirectory_arrow_right,
                              size: 16,
                              color: colors.labelSecondary,
                            ),
                            const SizedBox(width: AppSpacing.space2),
                            Expanded(
                              child: Text(
                                branch,
                                style: textTheme.bodyMedium?.copyWith(color: colors.labelSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
