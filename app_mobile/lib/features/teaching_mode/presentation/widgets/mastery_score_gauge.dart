import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/accessibility/motion.dart';

/// A circular 0-100 gauge for a Teaching Mode result — animates from 0
/// up to [score] on first build, the same "grow into place" treatment
/// `ChallengeProgressCircle` uses for the 100-day journey ring, so the
/// two big circular-progress moments in the app feel like one family.
class MasteryScoreGauge extends StatefulWidget {
  const MasteryScoreGauge({super.key, required this.score, this.size = 200});

  final int score;
  final double size;

  @override
  State<MasteryScoreGauge> createState() => _MasteryScoreGaugeState();
}

class _MasteryScoreGaugeState extends State<MasteryScoreGauge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  // See ChallengeProgressCircle for why the reduced-motion check can't
  // happen in initState() — MediaQuery isn't reachable until
  // didChangeDependencies().
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _animation = Tween<double>(
      begin: 0,
      end: widget.score / 100,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (prefersReducedMotion(context)) {
      _controller.duration = Duration.zero;
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _bandColor(AppColors colors) {
    if (widget.score >= 80) return colors.success;
    if (widget.score >= 50) return colors.warning;
    return colors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final bandColor = _bandColor(colors);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _GaugePainter(
              fraction: _animation.value,
              trackColor: colors.separator,
              progressColor: bandColor,
            ),
            child: child,
          );
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${widget.score}', style: textTheme.displayLarge?.copyWith(color: bandColor)),
              Text(
                'Mastery Score',
                style: textTheme.labelMedium?.copyWith(color: colors.labelSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.fraction, required this.trackColor, required this.progressColor});

  final double fraction;
  final Color trackColor;
  final Color progressColor;

  static const _strokeWidth = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - _strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * fraction.clamp(0, 1);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
