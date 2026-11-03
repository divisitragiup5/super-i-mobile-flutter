import 'package:flutter/material.dart';

/// Palet warna terpusat aplikasi.
/// Berisi warna identitas brand, netral, dan status (sukses, bahaya, peringatan).
class AppColors {
  // Private constructor agar class ini tidak bisa di-instansiasi (karena isinya static)
  AppColors._();

  // Brand Colors (Berdasarkan tema PLN / GAMA di project lama)
  static const Color primary = Color(0xFF016E7F);
  static const Color primaryDark = Color(0xFF014F5B);
  static const Color primaryLight = Color(0xFF0199B0);
  static const Color secondary = Color(0xFFFFB703); // Kuning aksen PLN

  // Background & Surface
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Status Colors (Notifikasi, Validasi, Kondisi Anomali)
  static const Color success = Color(0xFF10B981); // Hijau sukses/aman
  static const Color warning = Color(0xFFF59E0B); // Kuning peringatan/investigasi
  static const Color danger = Color(0xFFEF4444);  // Merah bahaya/error
  static const Color error = Color(0xFFEF4444);   // Alias error
  static const Color info = Color(0xFF3B82F6);    // Biru info

  // Neutral / Greyscale (Untuk teks dan border)
  static const Color textPrimary = Color(0xFF0F172A);   // Teks judul gelap
  static const Color textSecondary = Color(0xFF64748B); // Teks deskripsi/label abu
  static const Color textDisabled = Color(0xFF94A3B8);  // Teks disabled
  static const Color border = Color(0xFFE2E8F0);        // Garis pemisah / border input
  static const Color inputBackground = Color(0xFFF1F5F9);
}