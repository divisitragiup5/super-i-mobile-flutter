import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../widgets/app_snackbar.dart';

class FileViewerHelper {
  FileViewerHelper._();

  /// Membuka file menggunakan penampil dokumen bawaan sistem perangkat.
  /// Menangani MissingPluginException secara aman jika aplikasi belum di-restart penuh setelah instalasi plugin baru.
  static Future<OpenResult?> openFile(
    String filePath, {
    BuildContext? context,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('[FileViewerHelper] File does not exist at: $filePath');
        if (context != null && context.mounted) {
          AppSnackbar.showError(context, 'File tidak ditemukan di penyimpanan!');
        }
        return null;
      }

      final result = await OpenFilex.open(filePath);
      debugPrint('[FileViewerHelper] Result: ${result.type} - ${result.message}');

      if (result.type != ResultType.done) {
        if (context != null && context.mounted) {
          AppSnackbar.showWarning(
            context,
            'Tidak dapat membuka file: ${result.message}',
          );
        }
      }
      return result;
    } catch (e) {
      debugPrint('[FileViewerHelper] Error opening file: $e');
      if (context != null && context.mounted) {
        AppSnackbar.showError(
          context,
          'Gagal membuka file. Harap jalankan ulang aplikasi (re-run) dari terminal agar plugin pembuka file aktif.',
        );
      }
      return null;
    }
  }
}
