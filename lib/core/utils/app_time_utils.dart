import 'package:intl/intl.dart';

/// Utilitas waktu dan timezone untuk menyesuaikan representasi waktu dengan zona waktu user.
class AppTimeUtils {
  AppTimeUtils._();

  /// Mendapatkan nama IANA timezone perangkat (fallback ke zona Indonesia: WIB, WITA, WIT).
  static String get deviceTimezone {
    final offsetHours = DateTime.now().timeZoneOffset.inHours;
    if (offsetHours >= 9) return 'Asia/Jayapura'; // WIT (UTC+9)
    if (offsetHours >= 8) return 'Asia/Makassar'; // WITA (UTC+8)
    return 'Asia/Jakarta'; // WIB (UTC+7)
  }

  /// Parse string ISO/waktu ke DateTime dalam zona waktu lokal perangkat user.
  static DateTime? parseToLocal(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final dt = DateTime.parse(raw.trim());
      return dt.toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Format string ISO/waktu dari backend ke format lokal user (default: 'dd MMMM yyyy HH:mm').
  static String formatLocal(
    String? raw, {
    String pattern = 'dd MMMM yyyy HH:mm',
    String? locale = 'id',
    String fallback = '-',
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final dt = parseToLocal(raw);
    if (dt == null) return raw;
    try {
      return DateFormat(pattern, locale).format(dt);
    } catch (_) {
      try {
        return DateFormat(pattern).format(dt);
      } catch (_) {
        return raw;
      }
    }
  }
}
