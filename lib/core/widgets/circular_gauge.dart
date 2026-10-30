import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Circular Gauge grafis ringan berbasis Canvas (GPU Accelerated)
class CircularGauge extends StatelessWidget {
  final double progress; // 0.0 - 100.0
  final double radius;
  final double strokeWidth;
  final Color color;
  final String? centerLabel;
  final bool showPercent;

  const CircularGauge({
    super.key,
    required this.progress,
    this.radius = 65,
    this.strokeWidth = 12,
    this.color = AppColors.primaryLight,
    this.centerLabel,
    this.showPercent = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: CustomPaint(
        painter: _GaugePainter(
          progress: progress.clamp(0.0, 100.0) / 100.0,
          strokeWidth: strokeWidth,
          color: color,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                showPercent
                    ? '${progress.toStringAsFixed(1)}%'
                    : progress.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: radius * 0.32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (centerLabel != null)
                Text(
                  centerLabel!,
                  style: TextStyle(
                    fontSize: radius * 0.18,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _GaugePainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track latar belakang abu-abu
    final trackPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Arc warna progress
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Mulai dari atas (-90 derajat atau -pi/2)
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

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
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
