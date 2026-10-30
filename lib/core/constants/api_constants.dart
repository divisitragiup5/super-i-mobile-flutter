import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Konstanta konfigurasi API dan Network.
class ApiConstants {
  ApiConstants._();

  // Mengambil URL dari file .env secara dinamis, dengan fallback jika .env tidak terbaca
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://super-i-app.haleyorapower.co.id/api';

  // Durasi batas waktu koneksi (30 detik untuk kondisi sinyal lapangan)
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Endpoints Autentikasi
  static const String login = '/auth/login-mobile';
  static const String userMe = '/data/user/me';
  static const String changePassword = '/change-password';
}
