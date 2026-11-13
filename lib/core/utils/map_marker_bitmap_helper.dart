import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerBitmapHelper {
  static final Map<String, BitmapDescriptor> _cache = {};

  static Future<BitmapDescriptor> getCustomMarker({
    required String label,
    required Color color,
    bool isUser = false,
    bool showLabel = true,
  }) async {
    final cacheKey = '$label-${color.toARGB32()}-$isUser-$showLabel';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final descriptor = await _drawMarker(
      label: label,
      color: color,
      isUser: isUser,
      showLabel: showLabel,
    );
    _cache[cacheKey] = descriptor;
    return descriptor;
  }

  static Future<BitmapDescriptor> _drawMarker({
    required String label,
    required Color color,
    required bool isUser,
    bool showLabel = true,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const double scale = 2.0;

    const circleDiameter = 28.0 * scale;
    const arrowSize = 6.0 * scale;
    const spacing = 2.0 * scale;

    final bool hasLabel = showLabel && label.isNotEmpty;
    TextPainter? textPainter;
    double tooltipWidth = 0.0;
    double tooltipHeight = 0.0;
    double tooltipPaddingH = 8.0 * scale;
    double tooltipPaddingV = 3.0 * scale;

    if (hasLabel) {
      textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tooltipWidth = textPainter.width + (tooltipPaddingH * 2);
      tooltipHeight = textPainter.height + (tooltipPaddingV * 2);
    }

    final totalWidth = hasLabel
        ? (tooltipWidth > circleDiameter
            ? tooltipWidth + (6 * scale)
            : circleDiameter + (12 * scale))
        : circleDiameter + (12 * scale);

    final totalHeight = hasLabel
        ? tooltipHeight + spacing + circleDiameter + arrowSize + (6 * scale)
        : circleDiameter + arrowSize + (6 * scale);

    final centerX = totalWidth / 2;

    // 1. Tooltip RRect (jika ada label)
    if (hasLabel && textPainter != null) {
      final tooltipRect = Rect.fromCenter(
        center: Offset(centerX, tooltipHeight / 2 + (2 * scale)),
        width: tooltipWidth,
        height: tooltipHeight,
      );
      final tooltipRRect =
          RRect.fromRectAndRadius(tooltipRect, const Radius.circular(6 * scale));

      final tooltipPaint = Paint()
        ..color = isUser ? const Color(0xFF016E7F) : const Color(0xFF1E293B)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(tooltipRRect, tooltipPaint);

      final tooltipBorderPaint = Paint()
        ..color = isUser ? const Color(0xFF015A68) : const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 * scale;
      canvas.drawRRect(tooltipRRect, tooltipBorderPaint);

      // Text in tooltip
      textPainter.paint(
        canvas,
        Offset(centerX - textPainter.width / 2, (2 * scale) + tooltipPaddingV),
      );
    }

    // 2. Pin Circle
    final circleCenter = Offset(
      centerX,
      hasLabel
          ? tooltipHeight + spacing + (circleDiameter / 2) + (2 * scale)
          : (circleDiameter / 2) + (2 * scale),
    );

    final circlePaint = Paint()
      ..color = isUser ? const Color(0xFF0199B0) : color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(circleCenter, circleDiameter / 2, circlePaint);

    final circleBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale;
    canvas.drawCircle(circleCenter, circleDiameter / 2, circleBorderPaint);

    // Icon in circle (person or lightning bolt)
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    if (isUser) {
      final headCenter = Offset(circleCenter.dx, circleCenter.dy - 3.5 * scale);
      canvas.drawCircle(headCenter, 3.0 * scale, iconPaint);
      final bodyRect = Rect.fromCenter(
        center: Offset(circleCenter.dx, circleCenter.dy + 4.5 * scale),
        width: 10.0 * scale,
        height: 7.0 * scale,
      );
      canvas.drawArc(bodyRect, 3.14159, 3.14159, true, iconPaint);
    } else {
      final boltPath = Path();
      final cx = circleCenter.dx;
      final cy = circleCenter.dy;
      boltPath.moveTo(cx + 0.5 * scale, cy - 7 * scale);
      boltPath.lineTo(cx - 5 * scale, cy + 0.5 * scale);
      boltPath.lineTo(cx - 0.5 * scale, cy + 0.5 * scale);
      boltPath.lineTo(cx - 1.5 * scale, cy + 7 * scale);
      boltPath.lineTo(cx + 5 * scale, cy - 0.5 * scale);
      boltPath.lineTo(cx + 0.5 * scale, cy - 0.5 * scale);
      boltPath.close();
      canvas.drawPath(boltPath, iconPaint);
    }

    // 3. Pointer Arrow
    final arrowTop = circleCenter.dy + (circleDiameter / 2) - (2.0 * scale);
    final arrowPath = Path();
    arrowPath.moveTo(centerX - (3.5 * scale), arrowTop);
    arrowPath.lineTo(centerX, arrowTop + (5.5 * scale));
    arrowPath.lineTo(centerX + (3.5 * scale), arrowTop);
    arrowPath.close();

    final arrowPaint = Paint()
      ..color = isUser ? const Color(0xFF0199B0) : color
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, arrowPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(totalWidth.ceil(), totalHeight.ceil());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(uint8List, imagePixelRatio: scale);
  }

  static Future<BitmapDescriptor> getRadiusLabelMarker({
    required String label,
    required double radius,
    required bool isInside,
    required bool isDark,
  }) async {
    final cacheKey = 'radius-label-$label-${radius.toInt()}-$isInside-$isDark';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final descriptor = await _drawRadiusLabel(
      label: label,
      radius: radius,
      isInside: isInside,
      isDark: isDark,
    );
    _cache[cacheKey] = descriptor;
    return descriptor;
  }

  static Future<BitmapDescriptor> _drawRadiusLabel({
    required String label,
    required double radius,
    required bool isInside,
    required bool isDark,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const double scale = 2.0;

    final displayText = label.trim().isNotEmpty ? label.trim() : 'Titik Presensi';
    final titleSpan = TextSpan(
      text: displayText,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontSize: 10.5 * scale,
        fontWeight: FontWeight.bold,
      ),
    );

    final titlePainter = TextPainter(
      text: titleSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    )..layout();

    final statusText = 'Radius ${radius.toInt()}m';
    final subtitleSpan = TextSpan(
      text: statusText,
      style: TextStyle(
        color: isInside
            ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
            : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626)),
        fontSize: 9.0 * scale,
        fontWeight: FontWeight.w600,
      ),
    );

    final subtitlePainter = TextPainter(
      text: subtitleSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final paddingH = 10.0 * scale;
    final paddingV = 5.0 * scale;
    final dotRadius = 2.5 * scale;
    final dotSpacing = 4.0 * scale;
    final lineSpacing = 2.0 * scale;

    final dotAndSubWidth = (dotRadius * 2) + dotSpacing + subtitlePainter.width;
    final contentWidth = math.max(titlePainter.width, dotAndSubWidth);

    final totalWidth = contentWidth + (paddingH * 2) + (6 * scale);
    final totalHeight =
        titlePainter.height + subtitlePainter.height + lineSpacing + (paddingV * 2) + (6 * scale);

    final cardRect = Rect.fromCenter(
      center: Offset(totalWidth / 2, totalHeight / 2),
      width: totalWidth - (4 * scale),
      height: totalHeight - (4 * scale),
    );
    final cardRRect =
        RRect.fromRectAndRadius(cardRect, const Radius.circular(8 * scale));

    // 1. Shadow
    final shadowPaint = Paint()
      ..color = const Color(0x33000000)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(cardRRect.shift(const Offset(0, 1.5 * scale)), shadowPaint);

    // 2. Background Fill
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xEE1E293B) : const Color(0xFAFFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(cardRRect, bgPaint);

    // 3. Border Stroke
    final borderPaint = Paint()
      ..color = isInside
          ? (isDark ? const Color(0xFF16A34A) : const Color(0xFF22C55E))
          : (isDark ? const Color(0xFFDC2626) : const Color(0xFFEF4444))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * scale;
    canvas.drawRRect(cardRRect, borderPaint);

    // 4. Title Text
    final titleX = cardRect.left + (cardRect.width - titlePainter.width) / 2;
    final titleY = cardRect.top + paddingV;
    titlePainter.paint(canvas, Offset(titleX, titleY));

    // 5. Subtitle Row (Dot + Text)
    final subY = titleY + titlePainter.height + lineSpacing;
    final subStartX = cardRect.left + (cardRect.width - dotAndSubWidth) / 2;

    final dotPaint = Paint()
      ..color = isInside
          ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
          : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(subStartX + dotRadius, subY + (subtitlePainter.height / 2)),
      dotRadius,
      dotPaint,
    );

    subtitlePainter.paint(
      canvas,
      Offset(subStartX + (dotRadius * 2) + dotSpacing, subY),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(totalWidth.ceil(), totalHeight.ceil());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(uint8List, imagePixelRatio: scale);
  }
}
