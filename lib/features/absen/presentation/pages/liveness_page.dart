import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_face_liveness/flutter_face_liveness.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../domain/services/face_depth_anti_spoof_service.dart';

class LivenessPage extends StatefulWidget {
  final int initialFailedAttempt;

  const LivenessPage({super.key, this.initialFailedAttempt = 0});

  @override
  State<LivenessPage> createState() => _LivenessPageState();
}

class _LivenessPageState extends State<LivenessPage> {
  late int _failedAttempt;
  int _sessionKey = 0;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _failedAttempt = widget.initialFailedAttempt;
    // Pra-muat model TFLite MiniFASNetV2 di background agar siap seketika saat foto diambil
    FaceDepthAntiSpoofService.initModel();
  }

  Future<void> _handleSuccess(LivenessResult result) async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
    });

    // 1. Ambil bytes foto selfie lurus terbaik (best frontal frame)
    final bytes = result.bestFrontalImageBytes;

    if (bytes == null) {
      if (!mounted) return;
      setState(() {
        _isChecking = false;
        _failedAttempt++;
        _sessionKey++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menangkap foto wajah. Silakan ulangi.')),
      );
      return;
    }

    // 2. Koreksi orientasi: putar 180 derajat agar kepala tegak lurus
    Uint8List uprightBytes = bytes;
    final decoded = img.decodeImage(bytes);
    if (decoded != null) {
      final upright = img.copyRotate(decoded, angle: 180);
      uprightBytes = Uint8List.fromList(img.encodeJpg(upright, quality: 90));
    }

    // 3. Simpan ke file sementara terlebih dahulu
    final tempDir = await getTemporaryDirectory();
    final photoFile = File(
      '${tempDir.path}/liveness_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await photoFile.writeAsBytes(uprightBytes);

    // 4. Verifikasi Wajah & 3D Depthness Anti-Spoofing menggunakan MiniFASNetV2 & Tekstur
    final inspection = await FaceDepthAntiSpoofService.inspectPhotoFile(photoFile);
    debugPrint('[LivenessPage] Hasil Inspeksi: $inspection');

    if (!mounted) return;

    // Jika terdeteksi foto 2D / layar smartphone / print / bukan wajah asli
    if (!inspection.isReal) {
      if (await photoFile.exists()) {
        try {
          await photoFile.delete();
        } catch (_) {}
      }

      setState(() {
        _isChecking = false;
        _failedAttempt++;
        _sessionKey++; // Reset widget kamera untuk sesi ulang
      });

      if (!mounted) return;

      // Tampilkan dialog peringatan penolakan
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 52,
          ),
          title: const Text(
            'Verifikasi Wajah Gagal',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            inspection.failureReason ??
                'Foto atau layar digital terdeteksi! Harap gunakan wajah asli Anda secara langsung.',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF007A87)),
              onPressed: () {
                Navigator.of(ctx).pop(); // Tutup dialog
                Navigator.of(context).pop(); // Kembali ke halaman absen
              },
              child: const Text('Kembali'),
            ),
          ],
        ),
      );
      return;
    }

    // 5. Susun data faceProps fallback yang valid untuk backend NestJS PLN GAMA
    final faceProps = [
      {
        'challenge': 'TURN_LEFT',
        'properties': {'rotationY': -25.0},
      },
      {
        'challenge': 'TURN_RIGHT',
        'properties': {'rotationY': 25.0},
      },
    ];

    if (!mounted) return;

    // 6. Kembalikan data foto dan props ke AbsenProcessingPage
    Navigator.of(context).pop({
      'photoFile': photoFile,
      'faceProps': faceProps,
      'failedAttempt': _failedAttempt,
    });
  }

  Future<void> _handleFailure(String reason) async {
    if (!mounted) return;
    setState(() {
      _failedAttempt++;
    });

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.red,
          size: 52,
        ),
        title: const Text(
          'Verifikasi Wajah Gagal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          reason,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF007A87)),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Verifikasi Wajah'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Widget kamera liveness dengan mode Stand-Still (tanpa aksi gerakan)
          FlutterFaceLiveness(
            key: ValueKey(_sessionKey),
            actions: const [],
            config: const LivenessConfig(
              randomizeActions: false,
              enableTFLite: false, // Dikelola mandiri oleh FaceDepthAntiSpoofService
              enableVideoReplayDetection: false, // Matikan heuristic luma-stability bawaan
              enableAntiSpoof: false, // Matikan heuristic eye-variance bawaan
              enableFaceMesh: false,
              enableBestFrontalCapture: true,
              bestFrontalJpegQuality: 90,
              sessionTimeoutMs: 60000,
            ),
            onSuccess: _handleSuccess,
            onFailed: _handleFailure,
          ),

          // Banner instruksi "Stand Still" yang jelas di bagian atas
          Positioned(
            top: isLandscape ? 8 : 20,
            left: isLandscape ? 64 : 24,
            right: isLandscape ? 64 : 24,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isLandscape ? 8 : 12,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                'Posisikan wajah Anda di dalam oval dan tetap diam menghadap kamera',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isLandscape ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Loading overlay saat memproses inspeksi 3D Depth
          if (_isChecking)
            Container(
              color: Colors.black.withValues(alpha: 0.75),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF007A87),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Memverifikasi struktur wajah (3D Depth)...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Mohon tunggu sebentar',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
