import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/accessibility/motion.dart';

/// The Home screen's centerpiece — an animated ring showing how far
/// through the 100-day journey the user is, with the current day number
/// in the center. Re-animates from the previous fraction to the new one
/// whenever [progress] changes (a Done/Skip tap), rather than snapping,
/// per the "Beautiful animations" requirement.
class ChallengeProgressCircle extends StatefulWidget {
  const ChallengeProgressCircle({
    super.key,
    required this.progress,
    required this.currentDay,
    required this.totalDays,
    this.size = 220,
  });

  /// 0.0–1.0.
  final double progress;
  final int currentDay;
  final int totalDays;
  final double size;

  @override
  State<ChallengeProgressCircle> createState() => _ChallengeProgressCircleState();
}

class _ChallengeProgressCircleState extends State<ChallengeProgressCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  // `prefersReducedMotion` reads an InheritedWidget (MediaQuery), which
  // Flutter forbids before the element is fully mounted — initState()
  // runs too early for that. didChangeDependencies() is the framework's
  // designated place for exactly this kind of first-dependency read, and
  // it can fire more than once (e.g. a later MediaQuery change), so this
  // guards the "only on first mount" start-the-animation logic below.
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _animation = Tween<double>(
      begin: 0,
      end: widget.progress,
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
  void didUpdateWidget(covariant ChallengeProgressCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      if (prefersReducedMotion(context)) {
        _controller.value = 1;
      } else {
        _controller
          ..reset()
          ..forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _ProgressRingPainter(
              fraction: _animation.value,
              trackColor: colors.separator,
              progressColor: colors.accentFill,
            ),
            child: child,
          );
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Day ${widget.currentDay}', style: textTheme.headlineLarge),
              Text(
                'of ${widget.totalDays}',
                style: textTheme.bodyMedium?.copyWith(color: colors.labelSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.fraction,
    required this.trackColor,
    required this.progressColor,
  });

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
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
