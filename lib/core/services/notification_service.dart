import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../utils/file_viewer_helper.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service terpusat untuk mengelola notifikasi lokal, pengingat shift, dan notifikasi unduhan.
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _shiftChannelId = 'shift_clock_out_channel';
  static const String _shiftChannelName = 'Pengingat Shift Presensi';
  static const String _shiftChannelDesc =
      'Notifikasi pengingat waktu absen pulang kerja (Clock Out)';

  static const String _downloadChannelId = 'download_channel';
  static const String _downloadChannelName = 'Unduhan File & Berita Acara';
  static const String _downloadChannelDesc =
      'Notifikasi saat file Berita Acara atau dokumen berhasil diunduh';

  // ID Notifikasi unik agar tidak bentrok
  static const int notificationIdBeforeEnd = 1001; // 20 menit sebelum usai
  static const int notificationIdExactEnd = 1002; // Tepat saat usai

  /// Inisialisasi awal notifikasi & basis data timezone (WIB/WITA/WIT).
  Future<void> init() async {
    // 1. Inisialisasi database zona waktu dunia
    tz.initializeTimeZones();

    // 2. Konfigurasi Android (menggunakan icon app bawaan)
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) async {
        debugPrint(
          '[NOTIFICATION] User tapped notification: ${response.payload}',
        );
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          await FileViewerHelper.openFile(payload);
        }
      },
    );

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // 3. Buat Notification Channels
    final shiftChannel = AndroidNotificationChannel(
      _shiftChannelId,
      _shiftChannelName,
      description: _shiftChannelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final downloadChannel = AndroidNotificationChannel(
      _downloadChannelId,
      _downloadChannelName,
      description: _downloadChannelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await androidPlugin?.createNotificationChannel(shiftChannel);
    await androidPlugin?.createNotificationChannel(downloadChannel);

    // 4. Minta izin notifikasi di Android 13+
    await androidPlugin?.requestNotificationsPermission();

    // 5. Cek jika aplikasi dibuka dari notifikasi saat terminated
    final launchDetails =
        await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      final payload = launchDetails?.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        await FileViewerHelper.openFile(payload);
      }
    }
  }

  /// Menjadwalkan pengingat Clock Out saat petugas selesai melakukan Clock In.
  /// Sesuai legacy:
  /// - Notifikasi 1: 20 menit sebelum jam shift selesai.
  /// - Notifikasi 2: Tepat saat jam shift selesai.
  Future<void> scheduleShiftNotifications({
    required DateTime shiftEndTime,
    int minutesBefore = 20,
  }) async {
    final now = DateTime.now();

    // Waktu pengingat pertama (misal 20 menit sebelum pulang)
    final reminderBeforeTime = shiftEndTime.subtract(
      Duration(minutes: minutesBefore),
    );
    final hourEndFormatted = DateFormat('HH:mm').format(shiftEndTime);

    const androidDetails = AndroidNotificationDetails(
      _shiftChannelId,
      _shiftChannelName,
      channelDescription: _shiftChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    // 1. Jadwalkan pengingat 20 menit sebelum shift usai (jika waktunya masih di masa depan)
    if (reminderBeforeTime.isAfter(now)) {
      await _notificationsPlugin.zonedSchedule(
        id: notificationIdBeforeEnd,
        title: 'Shift Hampir Selesai ⏱️',
        body:
            'Persiapkan diri untuk absen pulang pada pukul $hourEndFormatted WIB.',
        scheduledDate: tz.TZDateTime.from(reminderBeforeTime, tz.local),
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('[NOTIFICATION] Scheduled reminder at: $reminderBeforeTime');
    }

    // 2. Jadwalkan pengingat tepat saat jam shift selesai
    if (shiftEndTime.isAfter(now)) {
      await _notificationsPlugin.zonedSchedule(
        id: notificationIdExactEnd,
        title: 'Shift Berakhir 🔔',
        body:
            'Jangan lupa lakukan Clock Out pulang sekarang (pukul $hourEndFormatted WIB).',
        scheduledDate: tz.TZDateTime.from(shiftEndTime, tz.local),
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint(
        '[NOTIFICATION] Scheduled exact end reminder at: $shiftEndTime',
      );
    }
  }

  /// Membatalkan jadwal notifikasi pengingat shift
  /// (Dipanggil saat petugas sudah sukses melakukan Clock Out).
  Future<void> cancelShiftNotifications() async {
    await _notificationsPlugin.cancel(id: notificationIdBeforeEnd);
    await _notificationsPlugin.cancel(id: notificationIdExactEnd);
    debugPrint('[NOTIFICATION] Shift reminders cancelled.');
  }

  /// Notifikasi instan untuk feedback testing
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _shiftChannelId,
      _shiftChannelName,
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      id: 999,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  /// Menampilkan notifikasi download selesai dengan payload path file
  /// Ketika notifikasi diklik, file akan langsung dibuka via open_filex
  Future<void> showDownloadNotification({
    required String filePath,
    required String fileName,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _downloadChannelId,
      _downloadChannelName,
      channelDescription: _downloadChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const details = NotificationDetails(android: androidDetails);

    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _notificationsPlugin.show(
      id: notificationId,
      title: 'Unduhan Selesai 📄',
      body: '$fileName berhasil diunduh. Ketuk untuk membuka file.',
      notificationDetails: details,
      payload: filePath,
    );
    debugPrint('[NOTIFICATION] Download notification shown for: $filePath');
  }
}
