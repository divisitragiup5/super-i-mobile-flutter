import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service terpusat untuk memeriksa dan meminta izin sistem operasi (Android/iOS).
class PermissionService {
  /// Meminta izin Kamera untuk modul Liveness & Foto Presensi.
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Meminta izin Mikrofon untuk modul Perekaman Video Anomali.
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Meminta izin Kamera & Mikrofon sekaligus untuk Perekaman Video.
  Future<bool> requestVideoRecordingPermissions() async {
    final cameraGranted = await requestCameraPermission();
    final micGranted = await requestMicrophonePermission();
    return cameraGranted && micGranted;
  }

  /// Meminta izin Lokasi Presisi (GPS).
  /// Memastikan GPS hardware di perangkat aktif dan izin aplikasi diberikan.
  Future<bool> requestLocationPermission() async {
    // 1. Cek apakah GPS fisik di HP sedang aktif (bukan mode mati)
    final isLocationServiceEnabled =
        await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      // Jika GPS mati di HP, minta user menyalakannya
      await Geolocator.openLocationSettings();
      return false;
    }

    // 2. Minta izin aplikasi (Fine & Coarse Location)
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Jika ditolak permanen, user harus mengaktifkan via Pengaturan
      return false;
    }

    return true;
  }

  /// Meminta izin Notifikasi (Wajib untuk Android 13+ seperti Redmi Note 11 Pro).
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Meminta seluruh izin yang diperlukan saat membuka halaman Presensi sekaligus:
  /// (Lokasi GPS, Kamera, dan Notifikasi Pengingat).
  Future<Map<String, bool>> requestAttendancePermissions() async {
    final hasLocation = await requestLocationPermission();
    final hasCamera = await requestCameraPermission();
    final hasNotification = await requestNotificationPermission();

    return {
      'location': hasLocation,
      'camera': hasCamera,
      'notification': hasNotification,
    };
  }

  /// Helper untuk membuka halaman Pengaturan Aplikasi jika izin ditolak permanen.
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
