import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../di/injection_container.dart';
import '../services/notification_service.dart';

class DownloadBaHelper {
  static String sanitizeFileName(String rawFileName, [String? contentType]) {
    String ext = '';
    if (contentType != null) {
      if (contentType.contains('pdf')) {
        ext = '.pdf';
      } else if (contentType.contains('png')) {
        ext = '.png';
      } else if (contentType.contains('jpg') || contentType.contains('jpeg')) {
        ext = '.jpg';
      }
    }
    if (ext.isEmpty && !rawFileName.contains('.')) {
      ext = '.pdf';
    }

    String sanitizedName = rawFileName.replaceAll('#', '').replaceAll(' ', '-');
    if (!sanitizedName.endsWith(ext)) {
      sanitizedName = '$sanitizedName$ext';
    }
    return sanitizedName;
  }

  static Future<String> saveFile({
    required List<int> bytes,
    required String rawFileName,
    String? contentType,
  }) async {
    final sanitizedName = sanitizeFileName(rawFileName, contentType);

    Directory? dir;
    if (!kIsWeb && Platform.isAndroid) {
      final publicDownload = Directory('/storage/emulated/0/Download');
      if (await publicDownload.exists()) {
        dir = publicDownload;
      } else {
        try {
          dir = await getExternalStorageDirectory();
        } catch (_) {}
      }
    }
    if (dir == null) {
      try {
        dir = await getDownloadsDirectory();
      } catch (_) {}
    }
    if (dir == null) {
      try {
        dir = await getApplicationDocumentsDirectory();
      } catch (_) {}
    }
    dir ??= Directory.systemTemp;

    final filePath = p.join(dir.path, sanitizedName);
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    try {
      if (sl.isRegistered<NotificationService>()) {
        await sl<NotificationService>().showDownloadNotification(
          filePath: filePath,
          fileName: sanitizedName,
        );
      }
    } catch (e) {
      debugPrint('[DownloadBaHelper] Gagal memicu notifikasi: $e');
    }

    return filePath;
  }
}
