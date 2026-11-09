import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../line_walker/data/models/line_walker_performance_model.dart';

class PerformanceTrendChartSheet extends StatefulWidget {
  final String title;
  final List<TrendDataPoint> points;

  const PerformanceTrendChartSheet({
    super.key,
    required this.title,
    required this.points,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<TrendDataPoint> points,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => PerformanceTrendChartSheet(
        title: title,
        points: points,
      ),
    );
  }

  @override
  State<PerformanceTrendChartSheet> createState() =>
      _PerformanceTrendChartSheetState();
}

class _PerformanceTrendChartSheetState
    extends State<PerformanceTrendChartSheet> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    final latestPoint = points.isNotEmpty ? points.last : null;
    final prevPoint = points.length > 1 ? points[points.length - 2] : null;

    double? diff;
    if (latestPoint != null && prevPoint != null) {
      diff = latestPoint.value - prevPoint.value;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Title & Close
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.insights,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 20),

            if (points.isEmpty) ...[
              // Empty State
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Data tren performa belum tersedia',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Summary Badge
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nilai Terakhir',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          latestPoint!.value.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (diff != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: diff >= 0
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: diff >= 0
                                ? Colors.green.shade300
                                : Colors.red.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              diff >= 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 14,
                              color: diff >= 0 ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: diff >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Interactive Chart View
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  height: 230,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) {
                          final idx = _findClosestPointIndex(
                            details.localPosition.dx,
                            constraints.maxWidth,
                            points.length,
                          );
                          setState(() => _selectedIndex = idx);
                        },
                        child: CustomPaint(
                          size: Size(constraints.maxWidth, 230),
                          painter: TrendLineChartPainter(
                            points: points,
                            selectedIndex: _selectedIndex,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Data tren performa dinilai secara periodik per bulan',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _findClosestPointIndex(double touchX, double width, int count) {
    if (count <= 1) return 0;
    const leftPad = 36.0;
    const rightPad = 36.0;
    final chartW = width - leftPad - rightPad;
    final step = chartW / (count - 1);

    int closest = 0;
    double minDistance = double.infinity;
    for (int i = 0; i < count; i++) {
      final px = leftPad + i * step;
      final dist = (touchX - px).abs();
      if (dist < minDistance) {
        minDistance = dist;
        closest = i;
      }
    }
    return closest;
  }
}

class TrendLineChartPainter extends CustomPainter {
  final List<TrendDataPoint> points;
  final int? selectedIndex;

  TrendLineChartPainter({
    required this.points,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const leftPadding = 36.0;
    const rightPadding = 36.0;
    const topPadding = 36.0;
    const bottomPadding = 46.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    final values = points.map((p) => p.value).toList();
    final minVal = values.reduce(math.min);
    final maxVal = values.reduce(math.max);

    // Padding vertikal agar garis tidak menempel tepi
    double diffY = maxVal - minVal;
    if (diffY == 0) diffY = 10.0;
    final effectiveMinY = math.max(0.0, minVal - diffY * 0.25);
    final effectiveMaxY = maxVal + diffY * 0.35;
    final spanY = (effectiveMaxY - effectiveMinY).abs() == 0
        ? 1.0
        : (effectiveMaxY - effectiveMinY);

    // 1. Gambar Garis Kisi Horizontal (Gridlines)
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;

    const gridSteps = 3;
    for (int i = 0; i <= gridSteps; i++) {
      final y = topPadding + (chartHeight / gridSteps) * i;
      canvas.drawLine(
        Offset(leftPadding - 8, y),
        Offset(size.width - rightPadding + 8, y),
        gridPaint,
      );
    }

    // Hitung posisi tiap titik di canvas
    final List<Offset> coords = [];
    final stepX = points.length > 1 ? chartWidth / (points.length - 1) : 0.0;

    for (int i = 0; i < points.length; i++) {
      final x = points.length > 1
          ? leftPadding + i * stepX
          : leftPadding + chartWidth / 2;
      final normY = (points[i].value - effectiveMinY) / spanY;
      final y = topPadding + chartHeight - (normY * chartHeight);
      coords.add(Offset(x, y));
    }

    // 2. Gambar Area Gradien di Bawah Kurva
    if (coords.length > 1) {
      final fillPath = Path();
      fillPath.moveTo(coords.first.dx, topPadding + chartHeight);
      fillPath.lineTo(coords.first.dx, coords.first.dy);

      for (int i = 0; i < coords.length - 1; i++) {
        final p0 = coords[i];
        final p1 = coords[i + 1];
        final cp1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final cp2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
        fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
      }

      fillPath.lineTo(coords.last.dx, topPadding + chartHeight);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.25),
            AppColors.primary.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, topPadding, size.width, chartHeight));

      canvas.drawPath(fillPath, fillPaint);
    }

    // 3. Gambar Garis Kurva Alami (Natural Cubic Bezier)
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();
    if (coords.length == 1) {
      linePath.moveTo(coords.first.dx - 15, coords.first.dy);
      linePath.lineTo(coords.first.dx + 15, coords.first.dy);
    } else {
      linePath.moveTo(coords.first.dx, coords.first.dy);
      for (int i = 0; i < coords.length - 1; i++) {
        final p0 = coords[i];
        final p1 = coords[i + 1];
        final cp1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final cp2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
        linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
      }
    }
    canvas.drawPath(linePath, linePaint);

    // 4. Gambar Titik Data (Scatter Points), Label Nilai, dan Label Sumbu X
    final pointOuterPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final pointInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final selectedOuterPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;

    for (int i = 0; i < coords.length; i++) {
      final p = coords[i];
      final isSelected = selectedIndex == i;

      // Titik Luar & Dalam
      if (isSelected) {
        canvas.drawCircle(p, 8.0, selectedOuterPaint);
        canvas.drawCircle(p, 4.0, pointInnerPaint);
      } else {
        canvas.drawCircle(p, 5.5, pointOuterPaint);
        canvas.drawCircle(p, 3.0, pointInnerPaint);
      }

      // Label Nilai di Atas Titik
      final valueText = points[i].value.toStringAsFixed(2);
      final valueSpan = TextSpan(
        text: valueText,
        style: TextStyle(
          color: isSelected ? AppColors.secondary : AppColors.textPrimary,
          fontSize: 10.5,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.bold,
        ),
      );
      final valueTp = TextPainter(
        text: valueSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      valueTp.layout();
      valueTp.paint(canvas, Offset(p.dx - valueTp.width / 2, p.dy - 18));

      // Label Sumbu X (Bulan di Baris 1, Tahun di Baris 2 seperti tick.split(" "))
      final parts = points[i].label.split(' ');
      final bulanTxt = parts.isNotEmpty ? parts[0] : '';
      final tahunTxt = parts.length > 1 ? parts[1] : '';

      final xSpan = TextSpan(
        children: [
          TextSpan(
            text: '$bulanTxt\n',
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontSize: 9.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              height: 1.2,
            ),
          ),
          if (tahunTxt.isNotEmpty)
            TextSpan(
              text: tahunTxt,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 8.5,
              ),
            ),
        ],
      );

      final xTp = TextPainter(
        text: xSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      xTp.layout();
      xTp.paint(
        canvas,
        Offset(p.dx - xTp.width / 2, topPadding + chartHeight + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant TrendLineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
