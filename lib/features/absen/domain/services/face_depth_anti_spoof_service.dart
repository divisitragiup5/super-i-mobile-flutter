import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Hasil inspeksi kedalaman 3D wajah dan anti-spoofing
class DepthInspectionResult {
  final bool isReal;
  final double depthScore;
  final double laplacianVariance;
  final String? failureReason;

  const DepthInspectionResult({
    required this.isReal,
    required this.depthScore,
    required this.laplacianVariance,
    this.failureReason,
  });

  @override
  String toString() =>
      'DepthInspectionResult(isReal: $isReal, depthScore: ${depthScore.toStringAsFixed(3)}, lapVar: ${laplacianVariance.toStringAsFixed(1)}, reason: $failureReason)';
}

/// Service untuk memverifikasi keaslian wajah (depthness & anti-spoof)
/// menggunakan model FaceAntiSpoofing (Deep Tree Learning) dan analisis tekstur
class FaceDepthAntiSpoofService {
  static Interpreter? _interpreter;
  static bool _isLoading = false;

  /// Memastikan model TFLite MiniFASNetV2 telah dimuat
  static Future<bool> initModel() async {
    if (_interpreter != null) return true;
    if (_isLoading) return false;

    _isLoading = true;
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/MiniFASNetV2.tflite');
      _interpreter!.allocateTensors();
      debugPrint('[FaceDepthAntiSpoofService] Model MiniFASNetV2 berhasil dimuat');
      _isLoading = false;
      return true;
    } catch (e) {
      debugPrint('[FaceDepthAntiSpoofService] Gagal memuat model MiniFASNetV2: $e');
      _isLoading = false;
      return false;
    }
  }

  /// Menjalankan inspeksi penuh pada file foto wajah hasil capture
  static Future<DepthInspectionResult> inspectPhotoFile(File photoFile) async {
    final bytes = await photoFile.readAsBytes();
    return inspectPhotoBytes(bytes, filePath: photoFile.path);
  }

  /// Menjalankan inspeksi penuh pada bytes foto
  static Future<DepthInspectionResult> inspectPhotoBytes(
    Uint8List bytes, {
    String? filePath,
  }) async {
    // 1. Inisialisasi model
    final ready = await initModel();
    if (!ready || _interpreter == null) {
      return const DepthInspectionResult(
        isReal: false,
        depthScore: 0.0,
        laplacianVariance: 0.0,
        failureReason: 'Model verifikasi wajah offline belum siap.',
      );
    }

    // 2. Decode gambar ke objek img.Image
    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      return const DepthInspectionResult(
        isReal: false,
        depthScore: 0.0,
        laplacianVariance: 0.0,
        failureReason: 'Format foto tidak valid.',
      );
    }

    // 3. Deteksi wajah menggunakan Google ML Kit
    InputImage inputImage;
    File? tempFile;
    if (filePath != null) {
      inputImage = InputImage.fromFilePath(filePath);
    } else {
      final tempDir = await getTemporaryDirectory();
      tempFile = File('${tempDir.path}/temp_inspect_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(bytes);
      inputImage = InputImage.fromFilePath(tempFile.path);
    }

    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    List<Face> faces;
    try {
      faces = await faceDetector.processImage(inputImage);
    } catch (e) {
      debugPrint('[FaceDepthAntiSpoofService] ML Kit Face Detection error: $e');
      return DepthInspectionResult(
        isReal: false,
        depthScore: 0.0,
        laplacianVariance: 0.0,
        failureReason: 'Gagal mendeteksi wajah: $e',
      );
    } finally {
      await faceDetector.close();
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }

    // 4. Validasi keberadaan wajah
    if (faces.isEmpty) {
      return const DepthInspectionResult(
        isReal: false,
        depthScore: 0.0,
        laplacianVariance: 0.0,
        failureReason: 'Tidak ada wajah terdeteksi. Posisikan wajah di dalam oval.',
      );
    }

    if (faces.length > 1) {
      return const DepthInspectionResult(
        isReal: false,
        depthScore: 0.0,
        laplacianVariance: 0.0,
        failureReason: 'Terdeteksi lebih dari satu wajah. Hanya satu orang yang diperbolehkan.',
      );
    }

    final face = faces.first;
    final box = face.boundingBox;

    // 5. Validasi ukuran dan orientasi wajah
    final imgW = decodedImage.width;
    final imgH = decodedImage.height;
    if (box.width < imgW * 0.10 || box.height < imgH * 0.10) {
      return const DepthInspectionResult(
        isReal: false,
        depthScore: 0.0,
        laplacianVariance: 0.0,
        failureReason: 'Wajah terlalu jauh dari kamera. Dekatkan wajah Anda.',
      );
    }

    // Cek sudut kemiringan kepala (toleran hingga 30 derajat untuk kamera tablet)
    final rotY = face.headEulerAngleY ?? 0.0;
    final rotX = face.headEulerAngleX ?? 0.0;
    if (rotY.abs() > 30.0 || rotX.abs() > 30.0) {
      return const DepthInspectionResult(
        isReal: false,
        depthScore: 0.0,
        laplacianVariance: 0.0,
        failureReason: 'Posisikan kepala menghadap lurus ke depan kamera.',
      );
    }

    // 6. Analisis Tekstur & Pantulan Spekular (Deteksi Layar Smartphone / Kaca)
    final lapScore = _computeLaplacianScore(decodedImage, box);
    final specularRatio = _computeSpecularHighlightRatio(decodedImage, box);

    debugPrint('[FaceDepthAntiSpoofService] lapScore=$lapScore, specularRatio=${specularRatio.toStringAsFixed(3)}');

    // Layar HP yang menampilkan foto memiliki pantulan spekular tajam dari kaca layar
    if (specularRatio > 0.28) {
      return DepthInspectionResult(
        isReal: false,
        depthScore: 0.1,
        laplacianVariance: lapScore.toDouble(),
        failureReason: 'Pantulan layar smartphone terdeteksi! Harap gunakan wajah asli, bukan layar smartphone.',
      );
    }

    // Foto kertas print yang buram atau foto sangat low-res (threshold 25 ramah kamera tablet)
    if (lapScore < 25) {
      return DepthInspectionResult(
        isReal: false,
        depthScore: 0.2,
        laplacianVariance: lapScore.toDouble(),
        failureReason: 'Gambar tidak fokus atau terlalu buram. Pastikan pencahayaan cukup dan kamera fokus.',
      );
    }

    // 7. Pengecekan AI Anti-Spoofing Neural Network (MiniFASNetV2, 80x80, BGR, scale 2.7)
    final boxW = box.width;
    final boxH = box.height;
    const double targetScale = 2.7;
    final scale = math.min((imgH - 1) / boxH, math.min((imgW - 1) / boxW, targetScale));
    final newW = boxW * scale;
    final newH = boxH * scale;
    final centerX = box.left + boxW * 0.5;
    final centerY = box.top + boxH * 0.5;

    final x1 = math.max(0, (centerX - newW * 0.5).floor());
    final y1 = math.max(0, (centerY - newH * 0.5).floor());
    final x2 = math.min(imgW - 1, (centerX + newW * 0.5).floor());
    final y2 = math.min(imgH - 1, (centerY + newH * 0.5).floor());
    final cropW = (x2 - x1 + 1).clamp(1, imgW - x1);
    final cropH = (y2 - y1 + 1).clamp(1, imgH - y1);

    // Siapkan tensor input 1x80x80x3 (Float32, format BGR mentah 0..255 sesuai standar OpenCV/MiniFASNet)
    final input = Float32List(1 * 80 * 80 * 3);
    int idx = 0;
    for (int dy = 0; dy < 80; dy++) {
      for (int dx = 0; dx < 80; dx++) {
        final sx = (x1 + dx * cropW ~/ 80).clamp(0, imgW - 1);
        final sy = (y1 + dy * cropH ~/ 80).clamp(0, imgH - 1);
        final pixel = decodedImage.getPixel(sx, sy);

        input[idx++] = pixel.b.toDouble(); // Channel B
        input[idx++] = pixel.g.toDouble(); // Channel G
        input[idx++] = pixel.r.toDouble(); // Channel R
      }
    }

    _interpreter!.getInputTensor(0).data = input.buffer.asUint8List();
    _interpreter!.invoke();

    final outTensors = _interpreter!.getOutputTensors();
    final byteData0 = ByteData.sublistView(outTensors[0].data);
    final logits = List<double>.generate(
      3,
      (i) => byteData0.getFloat32(i * 4, Endian.host),
    );

    // Softmax: 3 kelas [0: paper/print, 1: real face, 2: screen/replay]
    final maxLogit = math.max(logits[0], math.max(logits[1], logits[2]));
    final exp0 = math.exp(logits[0] - maxLogit);
    final exp1 = math.exp(logits[1] - maxLogit);
    final exp2 = math.exp(logits[2] - maxLogit);
    final sumExp = exp0 + exp1 + exp2;

    final probPaper = exp0 / sumExp;
    final probReal = exp1 / sumExp;
    final probScreen = exp2 / sumExp;

    debugPrint(
      '[FaceDepthAntiSpoofService] MiniFASNetV2: '
      'paper=${(probPaper * 100).toStringAsFixed(1)}%, '
      'real=${(probReal * 100).toStringAsFixed(1)}%, '
      'screen=${(probScreen * 100).toStringAsFixed(1)}%',
    );

    // Threshold untuk wajah asli: probReal >= 0.40
    final bool isReal = probReal >= 0.40;

    if (!isReal) {
      final String failureReason;
      if (probScreen >= probPaper) {
        failureReason =
            'Layar smartphone / monitor terdeteksi (${(probScreen * 100).toStringAsFixed(0)}%)! Harap gunakan wajah asli Anda.';
      } else {
        failureReason =
            'Foto 2D atau cetakan kertas terdeteksi (${(probPaper * 100).toStringAsFixed(0)}%)! Harap gunakan wajah asli Anda.';
      }
      return DepthInspectionResult(
        isReal: false,
        depthScore: probReal,
        laplacianVariance: lapScore.toDouble(),
        failureReason: failureReason,
      );
    }

    return DepthInspectionResult(
      isReal: true,
      depthScore: probReal,
      laplacianVariance: lapScore.toDouble(),
    );
  }

  /// Menghitung skor kejelasan tekstur wajah menggunakan kernel Laplacian 3x3
  static int _computeLaplacianScore(img.Image image, Rect box) {
    final cx = (box.left + box.right) * 0.5;
    final cy = (box.top + box.bottom) * 0.5;
    final maxSide = math.max(box.width, box.height) * 1.25;
    final half = maxSide * 0.5;

    final x0 = (cx - half).clamp(0.0, (image.width - 1).toDouble()).toInt();
    final y0 = (cy - half).clamp(0.0, (image.height - 1).toDouble()).toInt();
    final x1 = (cx + half).clamp(0.0, image.width.toDouble()).toInt();
    final y1 = (cy + half).clamp(0.0, image.height.toDouble()).toInt();
    final cropW = (x1 - x0).clamp(1, image.width - x0);
    final cropH = (y1 - y0).clamp(1, image.height - y0);

    int score = 0;
    const laplaceThreshold = 50;

    for (int dy = 1; dy < 255; dy += 2) {
      for (int dx = 1; dx < 255; dx += 2) {
        final sx = (x0 + dx * cropW ~/ 256).clamp(1, image.width - 2);
        final sy = (y0 + dy * cropH ~/ 256).clamp(1, image.height - 2);

        final pC = image.getPixel(sx, sy);
        final pU = image.getPixel(sx, sy - 1);
        final pD = image.getPixel(sx, sy + 1);
        final pL = image.getPixel(sx - 1, sy);
        final pR = image.getPixel(sx + 1, sy);

        final lC = (0.299 * pC.r + 0.587 * pC.g + 0.114 * pC.b).toInt();
        final lU = (0.299 * pU.r + 0.587 * pU.g + 0.114 * pU.b).toInt();
        final lD = (0.299 * pD.r + 0.587 * pD.g + 0.114 * pD.b).toInt();
        final lL = (0.299 * pL.r + 0.587 * pL.g + 0.114 * pL.b).toInt();
        final lR = (0.299 * pR.r + 0.587 * pR.g + 0.114 * pR.b).toInt();

        final result = lU + lD + lL + lR - 4 * lC;
        if (result > laplaceThreshold) {
          score++;
        }
      }
    }
    return score;
  }

  /// Menghitung rasio pantulan cahaya spekular (layar smartphone / kaca)
  static double _computeSpecularHighlightRatio(img.Image image, Rect box) {
    final left = box.left.clamp(0, image.width - 1).toInt();
    final top = box.top.clamp(0, image.height - 1).toInt();
    final width = box.width.clamp(1, image.width - left).toInt();
    final height = box.height.clamp(1, image.height - top).toInt();

    const stride = 3;
    int totalSampled = 0;
    int specularCount = 0;

    for (int y = top; y < top + height; y += stride) {
      for (int x = left; x < left + width; x += stride) {
        final p = image.getPixel(x, y);
        // Pantulan kaca / layar smartphone biasanya sangat terang dan jenuh (luma > 248)
        final luma = 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;
        if (luma > 248.0) {
          specularCount++;
        }
        totalSampled++;
      }
    }

    if (totalSampled == 0) return 0.0;
    return specularCount / totalSampled;
  }

  /// Membersihkan sumber daya model jika diperlukan
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoading = false;
  }
}
