import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/mastery_content.dart';

sealed class _ContentBlock {}

class _Paragraph extends _ContentBlock {
  _Paragraph(this.text);
  final String text;
}

class _BulletList extends _ContentBlock {
  _BulletList(this.items);
  final List<String> items;
}

/// Renders Summary/Clinical Pearls/Diagnosis/Management/Guidelines/
/// Explain Simply/Explain Deeply's generated text as actual paragraphs
/// and bullet lists rather than one unstyled text blob — the prompt
/// templates ask the model for `- ` bullet lines where a list makes
/// sense (`mastery_prompt_templates.dart`), and this is where that
/// convention gets turned into real UI.
class ProseSectionView extends StatelessWidget {
  const ProseSectionView({super.key, required this.content});

  final MasteryContent content;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final blocks = _parseBlocks(content.body);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space5),
      children: [
        for (final block in blocks)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space4),
            child: switch (block) {
              _Paragraph(:final text) => Text(text, style: textTheme.bodyLarge),
              _BulletList(:final items) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 7, right: AppSpacing.space3),
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: colors.accentFill,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Expanded(child: Text(item, style: textTheme.bodyLarge)),
                        ],
                      ),
                    ),
                ],
              ),
            },
          ),
        if (content.cached)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.space2),
            child: Text(
              'Previously generated',
              style: textTheme.labelSmall?.copyWith(color: colors.labelTertiary),
            ),
          ),
      ],
    );
  }

  List<_ContentBlock> _parseBlocks(String body) {
    final blocks = <_ContentBlock>[];
    var currentParagraph = <String>[];
    var currentBullets = <String>[];

    void flushParagraph() {
      if (currentParagraph.isNotEmpty) {
        blocks.add(_Paragraph(currentParagraph.join(' ').trim()));
        currentParagraph = [];
      }
    }

    void flushBullets() {
      if (currentBullets.isNotEmpty) {
        blocks.add(_BulletList(List.of(currentBullets)));
        currentBullets = [];
      }
    }

    for (final rawLine in body.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        flushParagraph();
        flushBullets();
        continue;
      }
      if (line.startsWith('- ') || line.startsWith('* ')) {
        flushParagraph();
        currentBullets.add(line.substring(2).trim());
      } else {
        flushBullets();
        currentParagraph.add(line);
      }
    }
    flushParagraph();
    flushBullets();
    return blocks;
  }
}
