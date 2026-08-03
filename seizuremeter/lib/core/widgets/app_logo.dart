import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Brainwave/EEG-mark logo used on the home screen and splash, built purely
/// from vector paint so no image asset is required.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ink700, AppColors.ink900],
        ),
        border: Border.all(color: AppColors.line2),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand3.withValues(alpha: 0.25),
            blurRadius: 32,
            spreadRadius: -6,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.22),
      child: CustomPaint(painter: _WavePainter()),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [AppColors.brand, AppColors.brand3],
      ).createShader(Offset.zero & size);

    final path = Path();
    final w = size.width;
    final h = size.height;
    final midY = h / 2;
    path.moveTo(0, midY);
    path.lineTo(w * 0.22, midY);
    path.lineTo(w * 0.34, midY - h * 0.32);
    path.lineTo(w * 0.46, midY + h * 0.42);
    path.lineTo(w * 0.58, midY - h * 0.5);
    path.lineTo(w * 0.68, midY + h * 0.18);
    path.lineTo(w * 0.8, midY);
    path.lineTo(w, midY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
