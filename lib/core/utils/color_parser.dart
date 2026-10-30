import 'package:flutter/material.dart';

class ColorParser {
  ColorParser._();

  /// Parse string warna seperti "#22c55e", "#10b981", "rgb(16, 185, 129)"
  /// Menghasilkan Color yang valid, atau fallback jika format tidak valid/null.
  static Color parse(String? colorStr, {Color fallback = const Color(0xFF10B981)}) {
    if (colorStr == null || colorStr.trim().isEmpty) return fallback;

    final trimmed = colorStr.trim();

    try {
      if (trimmed.startsWith('#')) {
        final hex = trimmed.replaceAll('#', '');
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        } else if (hex.length == 8) {
          return Color(int.parse(hex, radix: 16));
        }
      } else if (trimmed.startsWith('rgb')) {
        final match =
            RegExp(r'rgba?\((\d+),\s*(\d+),\s*(\d+)').firstMatch(trimmed);
        if (match != null) {
          final r = int.parse(match.group(1)!);
          final g = int.parse(match.group(2)!);
          final b = int.parse(match.group(3)!);
          return Color.fromARGB(255, r, g, b);
        }
      }
    } catch (_) {
      return fallback;
    }

    return fallback;
  }
}
