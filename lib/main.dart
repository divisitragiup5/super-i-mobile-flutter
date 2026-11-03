import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:super_i_mobile/core/services/notification_service.dart';

import 'app.dart';
import 'core/di/injection_container.dart';

void main() async {
  // 1. Pastikan binding native Flutter sudah terinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Kunci orientasi ke Portrait secara keseluruhan
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Inisialisasi format tanggal bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  // 2. Muat variabel lingkungan dari file .env
  await dotenv.load(fileName: ".env");

  // 3. Inisialisasi Service Locator (GetIt) & seluruh dependensi
  await initDependencies();

  // Inisialisasi notifikasi lokal & zona waktu
  await sl<NotificationService>().init();

  // 4. Jalankan aplikasi utama
  runApp(const MyApp());
}
