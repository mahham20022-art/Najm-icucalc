import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/mcq.dart';

/// The MCQs section's practice view — every question expands in place
/// with an immediate right/wrong reveal on tap, unlike Exam Mode (which
/// reuses the same generated bank sequentially with feedback withheld
/// until the end).
class McqPracticeList extends StatefulWidget {
  const McqPracticeList({super.key, required this.mcqs});

  final List<Mcq> mcqs;

  @override
  State<McqPracticeList> createState() => _McqPracticeListState();
}

class _McqPracticeListState extends State<McqPracticeList> {
  final Map<int, int> _selectedOptionByQuestion = {};

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.space5),
      itemCount: widget.mcqs.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.space4),
      itemBuilder: (context, index) {
        final mcq = widget.mcqs[index];
        return _McqCard(
          index: index,
          mcq: mcq,
          selectedOption: _selectedOptionByQuestion[index],
          onSelect: (optionIndex) => setState(() => _selectedOptionByQuestion[index] = optionIndex),
        );
      },
    );
  }
}

class _McqCard extends StatelessWidget {
  const _McqCard({
    required this.index,
    required this.mcq,
    required this.selectedOption,
    required this.onSelect,
  });

  final int index;
  final Mcq mcq;
  final int? selectedOption;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final answered = selectedOption != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${index + 1}',
              style: textTheme.labelMedium?.copyWith(color: colors.labelSecondary),
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(mcq.question, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.space3),
            for (var i = 0; i < mcq.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                child: _OptionTile(
                  label: mcq.options[i],
                  state: !answered
                      ? _OptionState.unanswered
                      : i == mcq.correctIndex
                      ? _OptionState.correct
                      : i == selectedOption
                      ? _OptionState.incorrectSelected
                      : _OptionState.neutral,
                  onTap: answered ? null : () => onSelect(i),
                ),
              ),
            if (answered) ...[
              const SizedBox(height: AppSpacing.space2),
              Container(
                padding: const EdgeInsets.all(AppSpacing.space3),
                decoration: BoxDecoration(
                  color: colors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusControlMd),
                ),
                child: Text(mcq.explanation, style: textTheme.bodyMedium),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _OptionState { unanswered, correct, incorrectSelected, neutral }

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.label, required this.state, required this.onTap});

  final String label;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final (background, border, icon) = switch (state) {
      _OptionState.unanswered => (colors.backgroundSecondary, colors.separator, null),
      _OptionState.correct => (
        colors.success.withValues(alpha: 0.12),
        colors.success,
        Icons.check_circle,
      ),
      _OptionState.incorrectSelected => (
        colors.danger.withValues(alpha: 0.12),
        colors.danger,
        Icons.cancel,
      ),
      _OptionState.neutral => (colors.backgroundSecondary, colors.separator, null),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusControlMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space3,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusControlMd),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
            if (icon != null)
              Icon(
                icon,
                size: 20,
                color: state == _OptionState.correct ? colors.success : colors.danger,
              ),
          ],
        ),
      ),
    );
  }
}
