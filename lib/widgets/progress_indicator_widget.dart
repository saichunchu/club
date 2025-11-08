import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

/// Matches 8club's Figma wavy progress indicator design
class ProgressIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressIndicatorWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep / totalSteps).clamp(0.0, 1.0);

    return SizedBox(
      width: double.infinity,
      height: 20, // control the vertical spacing area for the wave
      child: CustomPaint(
        painter: _WavyProgressPainter(
          progress: progress,
          activeColor: AppColors.primaryAccent,
          inactiveColor: AppColors.text4.withOpacity(0.4),
        ),
      ),
    );
  }
}

class _WavyProgressPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  _WavyProgressPainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final amplitude = 4.0; // wave height
    final wavelength = 32.0; // distance between wave crests
    final centerY = size.height / 2;

    // Configure paints
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Draw full inactive wave
    final inactivePath = _generateWavePath(size.width, centerY, amplitude, wavelength);
    basePaint.color = inactiveColor;
    canvas.drawPath(inactivePath, basePaint);

    // Draw clipped active wave
    if (progress > 0) {
      final activeWidth = size.width * progress;
      final clipRect = Rect.fromLTWH(0, 0, activeWidth, size.height);

      canvas.save();
      canvas.clipRect(clipRect);

      final activePath = _generateWavePath(size.width, centerY, amplitude, wavelength);
      basePaint.color = activeColor;
      canvas.drawPath(activePath, basePaint);
      canvas.restore();
    }
  }

  Path _generateWavePath(double width, double centerY, double amplitude, double wavelength) {
    final path = Path();
    path.moveTo(0, centerY);
    for (double x = 0; x <= width; x++) {
      final y = centerY + amplitude * math.sin((x / wavelength) * 2 * math.pi);
      path.lineTo(x, y);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _WavyProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}
