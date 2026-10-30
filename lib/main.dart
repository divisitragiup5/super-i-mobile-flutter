import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/di/injection_container.dart';

void main() async {
  // 1. Pastikan binding native Flutter sudah terinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi format tanggal bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  // 2. Muat variabel lingkungan dari file .env
  await dotenv.load(fileName: ".env");

  // 3. Inisialisasi Service Locator (GetIt) & seluruh dependensi
  await initDependencies();

  // 4. Jalankan aplikasi utama
  runApp(const MyApp());
}
