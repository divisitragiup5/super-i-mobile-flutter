import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SutmBarChartDataPoint {
  final String bulan;
  final num target;
  final num realisasi;

  const SutmBarChartDataPoint({
    required this.bulan,
    required this.target,
    required this.realisasi,
  });

  factory SutmBarChartDataPoint.fromJson(Map<String, dynamic> json) {
    return SutmBarChartDataPoint(
      bulan: json['bulan']?.toString() ?? json['month']?.toString() ?? '',
      target: (json['target'] as num?) ?? 0,
      realisasi: (json['realisasi'] as num?) ?? 0,
    );
  }
}

class SutmBarChartWidget extends StatefulWidget {
  final List<SutmBarChartDataPoint> data;
  final double height;

  const SutmBarChartWidget({
    super.key,
    required this.data,
    this.height = 220,
  });

  @override
  State<SutmBarChartWidget> createState() => _SutmBarChartWidgetState();
}

class _SutmBarChartWidgetState extends State<SutmBarChartWidget> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    if (widget.data.isNotEmpty) {
      _selectedIndex = widget.data.length - 1;
    }
  }

  @override
  void didUpdateWidget(covariant SutmBarChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.isNotEmpty &&
        (_selectedIndex == null || _selectedIndex! >= widget.data.length)) {
      _selectedIndex = widget.data.length - 1;
    }
  }

  String _formatMonth(String label) {
    if (label.isEmpty) return '';
    final parts = label.split(' ');
    final m = parts.first;
    if (m.length <= 3) return m;
    return m.substring(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    if (data.isEmpty) {
      return Container(
        height: widget.height,
        alignment: Alignment.center,
        child: const Text(
          'Tidak ada data statistik untuk ditampilkan',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }

    final selected = _selectedIndex != null &&
            _selectedIndex! >= 0 &&
            _selectedIndex! < data.length
        ? data[_selectedIndex!]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Legend & Selected Month Pill
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildLegendItem(const Color(0xFF016E7F), 'Target'),
                const SizedBox(width: 14),
                _buildLegendItem(const Color(0xFF0199B0), 'Realisasi'),
              ],
            ),
            if (selected != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${selected.bulan}: ',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'T: ${selected.target} ',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF38BDF8),
                      ),
                    ),
                    Text(
                      'R: ${selected.realisasi}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF34D399),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Chart Painter Area
        SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  final idx = _findClosestIndex(
                    details.localPosition.dx,
                    constraints.maxWidth,
                    data.length,
                  );
                  setState(() => _selectedIndex = idx);
                },
                onHorizontalDragUpdate: (details) {
                  final idx = _findClosestIndex(
                    details.localPosition.dx,
                    constraints.maxWidth,
                    data.length,
                  );
                  setState(() => _selectedIndex = idx);
                },
                child: CustomPaint(
                  size: Size(constraints.maxWidth, widget.height),
                  painter: _SutmBarChartPainter(
                    data: data,
                    selectedIndex: _selectedIndex,
                    formatMonth: _formatMonth,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black87),
        ),
      ],
    );
  }

  int _findClosestIndex(double touchX, double width, int count) {
    if (count <= 1) return 0;
    const leftPad = 36.0;
    const rightPad = 16.0;
    final chartW = width - leftPad - rightPad;
    final step = chartW / count;

    final relativeX = touchX - leftPad;
    final idx = (relativeX / step).floor();
    return idx.clamp(0, count - 1);
  }
}

class _SutmBarChartPainter extends CustomPainter {
  final List<SutmBarChartDataPoint> data;
  final int? selectedIndex;
  final String Function(String) formatMonth;

  _SutmBarChartPainter({
    required this.data,
    required this.selectedIndex,
    required this.formatMonth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const leftPad = 36.0;
    const rightPad = 16.0;
    const topPad = 20.0;
    const bottomPad = 32.0;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    // Find max value
    num maxValue = 10;
    for (final d in data) {
      if (d.target > maxValue) maxValue = d.target;
      if (d.realisasi > maxValue) maxValue = d.realisasi;
    }
    // Round up max for clean grid
    maxValue = (math.max(1, (maxValue / 10).ceil()) * 10).toInt();

    // Draw Grid Lines & Y Axis Labels
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    const gridSteps = 4;
    for (int i = 0; i <= gridSteps; i++) {
      final yVal = (maxValue / gridSteps) * i;
      final yPos = topPad + chartH - (yVal / maxValue) * chartH;

      canvas.drawLine(
        Offset(leftPad, yPos),
        Offset(size.width - rightPad, yPos),
        gridPaint,
      );

      textPainter.text = TextSpan(
        text: yVal.toInt().toString(),
        style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
      );
      textPainter.layout(minWidth: leftPad - 8, maxWidth: leftPad - 8);
      textPainter.paint(
        canvas,
        Offset(0, yPos - textPainter.height / 2),
      );
    }

    // Bar drawing
    final slotW = chartW / data.length;
    final barW = math.min(10.0, slotW * 0.32);

    final targetPaint = Paint()
      ..color = const Color(0xFF016E7F)
      ..style = PaintingStyle.fill;

    final realisasiPaint = Paint()
      ..color = const Color(0xFF0199B0)
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      final slotCenterX = leftPad + i * slotW + slotW / 2;

      // Selection background highlight
      if (selectedIndex == i) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              leftPad + i * slotW + 2,
              topPad,
              slotW - 4,
              chartH,
            ),
            const Radius.circular(8),
          ),
          highlightPaint,
        );
      }

      // Target bar (Left)
      final targetH = (d.target / maxValue) * chartH;
      final targetLeft = slotCenterX - barW - 1.5;
      final targetTop = topPad + chartH - targetH;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(targetLeft, targetTop, barW, targetH),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        targetPaint,
      );

      // Realisasi bar (Right)
      final realisasiH = (d.realisasi / maxValue) * chartH;
      final realisasiLeft = slotCenterX + 1.5;
      final realisasiTop = topPad + chartH - realisasiH;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(realisasiLeft, realisasiTop, barW, realisasiH),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        realisasiPaint,
      );

      // Month Label
      final labelPainter = TextPainter(
        text: TextSpan(
          text: formatMonth(d.bulan),
          style: TextStyle(
            fontSize: 10,
            fontWeight:
                selectedIndex == i ? FontWeight.bold : FontWeight.normal,
            color: selectedIndex == i ? AppColors.primary : Colors.grey.shade600,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      labelPainter.layout(minWidth: slotW, maxWidth: slotW);
      labelPainter.paint(
        canvas,
        Offset(leftPad + i * slotW, topPad + chartH + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SutmBarChartPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.data != data;
  }
}
