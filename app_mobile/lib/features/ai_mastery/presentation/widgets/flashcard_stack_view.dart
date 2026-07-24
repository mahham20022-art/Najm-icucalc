import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/accessibility/motion.dart';
import '../../domain/entities/flashcard.dart';

class FlashcardStackView extends StatefulWidget {
  const FlashcardStackView({super.key, required this.cards});

  final List<Flashcard> cards;

  @override
  State<FlashcardStackView> createState() => _FlashcardStackViewState();
}

class _FlashcardStackViewState extends State<FlashcardStackView> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return const Center(child: Text('No flashcards yet.'));
    }
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final card = widget.cards[_index];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space5),
        child: Column(
          children: [
            Text(
              '${_index + 1} / ${widget.cards.length}',
              style: textTheme.labelMedium?.copyWith(color: colors.labelSecondary),
            ),
            const SizedBox(height: AppSpacing.space4),
            Expanded(
              child: Center(
                child: _FlipCard(key: ValueKey(_index), front: card.front, back: card.back),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _index > 0 ? () => setState(() => _index--) : null,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _index < widget.cards.length - 1
                        ? () => setState(() => _index++)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Taps flip the card between front and back with a 3D rotation —
/// re-created (via the parent's `ValueKey`) rather than reused when the
/// card index changes, so it always starts front-side-up on a new card.
class _FlipCard extends StatefulWidget {
  const _FlipCard({super.key, required this.front, required this.back});

  final String front;
  final String back;

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  bool _showingFront = true;

  void _flip() {
    final flippingToBack = _showingFront;
    if (prefersReducedMotion(context)) {
      _controller.value = flippingToBack ? 1 : 0;
    } else if (flippingToBack) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _showingFront = !_showingFront);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * math.pi;
          final showBack = angle > math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _CardFace(text: widget.back, isFront: false),
                  )
                : _CardFace(text: widget.front, isFront: true),
          );
        },
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({required this.text, required this.isFront});

  final String text;
  final bool isFront;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      padding: const EdgeInsets.all(AppSpacing.space5),
      decoration: BoxDecoration(
        color: isFront ? colors.surfaceElevated : colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: colors.separator),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, textAlign: TextAlign.center, style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.space4),
          Text(
            isFront ? 'Tap to reveal answer' : 'Tap to flip back',
            style: textTheme.labelSmall?.copyWith(color: colors.labelTertiary),
          ),
        ],
      ),
    );
  }
}
