import 'package:flutter/material.dart';

class LivenessOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double strokeWidth;

  const LivenessOverlayPainter({
    required this.borderColor,
    this.strokeWidth = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Tentukan ukuran dan posisi bingkai Oval adaptif terhadap orientasi layar
    final bool isLandscape = size.width > size.height;
    final double ovalWidth;
    final double ovalHeight;
    final Offset center;

    if (isLandscape) {
      // Pada mode landscape (tablet atau HP horizontal), perbesar oval (86% tinggi layar)
      // dan rasio lebih lapang (~1.18) agar wajah sangat mudah diposisikan di dalam oval
      ovalHeight = size.height * 0.86;
      ovalWidth = ovalHeight / 1.18;
      center = Offset(size.width / 2, size.height * 0.50);
    } else {
      // Pada mode portrait:
      ovalWidth = size.width * 0.80;
      ovalHeight = ovalWidth * 1.30;
      center = Offset(size.width / 2, size.height * 0.40);
    }

    final Rect ovalRect = Rect.fromCenter(
      center: center,
      width: ovalWidth,
      height: ovalHeight,
    );

    // 2. Buat Path layar penuh dikurangi Path Oval (Cutout Hole)
    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final Path ovalPath = Path()..addOval(ovalRect);

    final Path transparentHole = Path.combine(
      PathOperation.difference,
      backgroundPath,
      ovalPath,
    );

    // 3. Gambar background gelap di luar area wajah
    final Paint backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    canvas.drawPath(transparentHole, backgroundPaint);

    // 4. Gambar border garis pada Oval
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawOval(ovalRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant LivenessOverlayPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
