import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../daily_topic/domain/entities/topic.dart';
import '../../domain/entities/mastery_section_type.dart';
import '../viewmodels/mastery_content_providers.dart';
import '../widgets/algorithm_view.dart';
import '../widgets/comparison_table_view.dart';
import '../widgets/consultant_chat_view.dart';
import '../widgets/exam_mode_view.dart';
import '../widgets/flashcard_stack_view.dart';
import '../widgets/mastery_async_section.dart';
import '../widgets/mcq_practice_list.dart';
import '../widgets/prose_section_view.dart';
import '../widgets/references_view.dart';

/// AI Mastery Mode's main screen — every topic's 14 sections, reachable
/// from a horizontally-scrollable chip bar, per this task's "Professional
/// UI" bar and `MED100_UI_UX_SPEC.md`'s general Material 3 design
/// language (`AppColors`/`AppSpacing`/`Theme.of(context).textTheme`
/// throughout, no literal colors or sizes).
class MasteryHomeScreen extends StatefulWidget {
  const MasteryHomeScreen({super.key, required this.topic});

  final Topic topic;

  @override
  State<MasteryHomeScreen> createState() => _MasteryHomeScreenState();
}

class _MasteryHomeScreenState extends State<MasteryHomeScreen> {
  MasterySectionType _selected = MasterySectionType.summary;

  static const _icons = <MasterySectionType, IconData>{
    MasterySectionType.summary: Icons.article_outlined,
    MasterySectionType.clinicalPearls: Icons.lightbulb_outline,
    MasterySectionType.diagnosis: Icons.search,
    MasterySectionType.management: Icons.healing_outlined,
    MasterySectionType.guidelines: Icons.gavel_outlined,
    MasterySectionType.comparisonTables: Icons.table_chart_outlined,
    MasterySectionType.algorithms: Icons.account_tree_outlined,
    MasterySectionType.mcqs: Icons.quiz_outlined,
    MasterySectionType.flashcards: Icons.style_outlined,
    MasterySectionType.references: Icons.menu_book_outlined,
    MasterySectionType.explainSimply: Icons.child_care_outlined,
    MasterySectionType.explainDeeply: Icons.school_outlined,
    MasterySectionType.examMode: Icons.timer_outlined,
    MasterySectionType.consultantMode: Icons.forum_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.topic.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: Column(
        children: [
          Container(
            color: colors.backgroundSecondary,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
                itemCount: MasterySectionType.values.length,
                separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.space2),
                itemBuilder: (context, index) {
                  final section = MasterySectionType.values[index];
                  final isSelected = section == _selected;
                  return ChoiceChip(
                    label: Text(section.fallbackLabel),
                    avatar: Icon(_icons[section], size: 18),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selected = section),
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _SectionBody(topic: widget.topic, section: _selected),
          ),
        ],
      ),
    );
  }
}

class _SectionBody extends ConsumerWidget {
  const _SectionBody({required this.topic, required this.section});

  final Topic topic;
  final MasterySectionType section;

  static const _proseSections = {
    MasterySectionType.summary,
    MasterySectionType.clinicalPearls,
    MasterySectionType.diagnosis,
    MasterySectionType.management,
    MasterySectionType.guidelines,
    MasterySectionType.explainSimply,
    MasterySectionType.explainDeeply,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_proseSections.contains(section)) {
      final key = (topic: topic, section: section);
      return MasteryAsyncSection(
        value: ref.watch(proseSectionProvider(key)),
        onRetry: () => ref.invalidate(proseSectionProvider(key)),
        builder: (context, content) => ProseSectionView(content: content),
      );
    }

    return switch (section) {
      MasterySectionType.comparisonTables => MasteryAsyncSection(
        value: ref.watch(comparisonTableProvider(topic)),
        onRetry: () => ref.invalidate(comparisonTableProvider(topic)),
        builder: (context, table) => ComparisonTableView(table: table),
      ),
      MasterySectionType.algorithms => MasteryAsyncSection(
        value: ref.watch(algorithmProvider(topic)),
        onRetry: () => ref.invalidate(algorithmProvider(topic)),
        builder: (context, algorithm) => AlgorithmView(algorithm: algorithm),
      ),
      MasterySectionType.mcqs => MasteryAsyncSection(
        value: ref.watch(mcqsProvider(topic)),
        onRetry: () => ref.invalidate(mcqsProvider(topic)),
        builder: (context, mcqs) => McqPracticeList(mcqs: mcqs),
      ),
      MasterySectionType.flashcards => MasteryAsyncSection(
        value: ref.watch(flashcardsProvider(topic)),
        onRetry: () => ref.invalidate(flashcardsProvider(topic)),
        builder: (context, cards) => FlashcardStackView(cards: cards),
      ),
      MasterySectionType.references => MasteryAsyncSection(
        value: ref.watch(referencesProvider(topic)),
        onRetry: () => ref.invalidate(referencesProvider(topic)),
        builder: (context, references) => ReferencesView(references: references),
      ),
      MasterySectionType.examMode => ExamModeView(topic: topic),
      MasterySectionType.consultantMode => ConsultantChatView(topic: topic),
      _ => const SizedBox.shrink(),
    };
  }
}
