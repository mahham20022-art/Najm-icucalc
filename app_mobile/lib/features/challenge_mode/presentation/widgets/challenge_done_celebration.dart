import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/accessibility/motion.dart';

/// A brief full-screen celebration shown once when a day is marked
/// Done — scales and fades in a checkmark, holds briefly, then fades
/// out and calls [onCompleted] so the caller can remove it from the
/// tree. Purely decorative: it carries no state of its own beyond the
/// animation.
class ChallengeDoneCelebration extends StatefulWidget {
  const ChallengeDoneCelebration({super.key, required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  State<ChallengeDoneCelebration> createState() => _ChallengeDoneCelebrationState();
}

class _ChallengeDoneCelebrationState extends State<ChallengeDoneCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  // See ChallengeProgressCircle for why the reduced-motion check can't
  // happen in initState() — MediaQuery isn't reachable until
  // didChangeDependencies().
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 1.15).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
    ]).animate(_controller);
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (prefersReducedMotion(context)) {
      _controller.duration = Duration.zero;
    }
    _controller.forward().whenComplete(widget.onCompleted);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return IgnorePointer(
      child: FadeTransition(
        opacity: _opacity,
        child: Container(
          color: colors.backgroundPrimary.withValues(alpha: 0.85),
          alignment: Alignment.center,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: colors.success),
                  child: const Icon(Icons.check, color: Colors.white, size: 56),
                ),
                const SizedBox(height: 16),
                Text(
                  'Day complete!',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: colors.labelPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
