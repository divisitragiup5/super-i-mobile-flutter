import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class WatermarkService {
  WatermarkService._();

  /// Menambahkan watermark proporsional ke foto dan menyimpannya sebagai file baru
  static Future<File> addWatermark({
    required File imageFile,
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    required String address,
    String? userName,
  }) async {
    // 1. Baca bytes gambar asli dan decode ke ui.Image
    final bytes = await imageFile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image originalImage = frameInfo.image;

    final double width = originalImage.width.toDouble();
    final double height = originalImage.height.toDouble();

    // 2. Siapkan Canvas dengan PictureRecorder
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    // Gambar foto asli
    final Paint paint = Paint()..filterQuality = FilterQuality.high;
    canvas.drawImage(originalImage, Offset.zero, paint);

    // Gambar Logo PLN ES di pojok kiri atas
    try {
      final ByteData logoData =
          await rootBundle.load('assets/images/pln_es.png');
      final ui.Codec logoCodec =
          await ui.instantiateImageCodec(logoData.buffer.asUint8List());
      final ui.FrameInfo logoFrame = await logoCodec.getNextFrame();
      final ui.Image logoImage = logoFrame.image;

      final double logoMargin = width * 0.03;
      final double targetLogoWidth = width * 0.16;
      final double logoScale = targetLogoWidth / logoImage.width;
      final double targetLogoHeight = logoImage.height * logoScale;

      final Rect srcRect = Rect.fromLTWH(
        0,
        0,
        logoImage.width.toDouble(),
        logoImage.height.toDouble(),
      );
      final Rect dstRect = Rect.fromLTWH(
        logoMargin,
        logoMargin,
        targetLogoWidth,
        targetLogoHeight,
      );

      // Background semi-transparan halus di belakang logo
      final RRect logoBgRRect = RRect.fromRectAndRadius(
        dstRect.inflate(targetLogoWidth * 0.06),
        Radius.circular(targetLogoWidth * 0.05),
      );
      final Paint logoBgPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.0)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(logoBgRRect, logoBgPaint);

      canvas.drawImageRect(logoImage, srcRect, dstRect, paint);
    } catch (e) {
      debugPrint('[WatermarkService] Error rendering PLN ES logo: $e');
    }

    // 3. Susun teks watermark
    final formattedDate = DateFormat(
      'dd MMMM yyyy HH:mm:ss',
      'id_ID',
    ).format(timestamp);

    final StringBuffer textBuffer = StringBuffer();
    if (userName != null && userName.isNotEmpty) {
      textBuffer.writeln('Petugas : $userName');
    }
    textBuffer.writeln('Waktu   : $formattedDate WIB');
    textBuffer.writeln('Posisi  : $latitude, $longitude');
    textBuffer.write('Lokasi  : $address');

    final String watermarkText = textBuffer.toString();

    // 4. Hitung skala font proporsional terhadap lebar foto
    // Base ukuran font 28px untuk lebar 1080px
    final double fontSize = (width / 1080.0) * 10.0;
    final double padding = fontSize * 0.8;

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: watermarkText,
        style: TextStyle(
          fontFamily: 'SpaceMono',
          color: const Color(0xFFFFCC00), // Kuning PLN GAMA
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          height: 1.35,
          shadows: const [
            Shadow(
              offset: Offset(2.0, 2.0),
              blurRadius: 3.0,
              color: Colors.black,
            ),
          ],
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      textScaler: TextScaler.noScaling,
      maxLines: 6,
    );

    // Batasi lebar kotak watermark maksimal 90% dari lebar foto
    final double maxTextWidth = width * 0.90 - (padding * 2);
    textPainter.layout(maxWidth: maxTextWidth);

    final double boxWidth = textPainter.width + (padding * 2);
    final double boxHeight = textPainter.height + (padding * 2);

    // Posisi di pojok kiri bawah foto dengan margin
    final double margin = width * 0.03;
    final double boxLeft = margin;
    final double boxTop = height - boxHeight - margin;

    // 5. Gambar background hitam semi-transparan di belakang teks
    final RRect bgRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boxLeft, boxTop, boxWidth, boxHeight),
      Radius.circular(fontSize * 0.4),
    );

    final Paint bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(bgRRect, bgPaint);

    // 6. Gambar teks watermark
    textPainter.paint(canvas, Offset(boxLeft + padding, boxTop + padding));

    // 7. Render Canvas menjadi Image
    final ui.Picture picture = recorder.endRecording();
    final ui.Image watermarkedImage = await picture.toImage(
      width.toInt(),
      height.toInt(),
    );

    // 8. Kompres menjadi format PNG/JPEG bytes
    final byteData = await watermarkedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw Exception('Gagal mengompres gambar watermark');
    }

    // 9. Simpan file baru di direktori cache sementara
    final tempDir = await getTemporaryDirectory();
    final String targetPath =
        '${tempDir.path}/absen_watermarked_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File resultFile = File(targetPath);
    await resultFile.writeAsBytes(byteData.buffer.asUint8List());

    return resultFile;
  }
}