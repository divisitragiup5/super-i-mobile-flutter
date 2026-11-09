import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../services/watermark_service.dart';
import '../theme/app_colors.dart';

/// Halaman Kamera Lapangan dengan Watermark GPS & Waktu Otomatis
class FieldCameraWidget extends StatefulWidget {
  final String title;
  final bool useWatermark;
  final bool forceLandscape;

  const FieldCameraWidget({
    super.key,
    this.title = 'Ambil Foto Dokumentasi',
    this.useWatermark = true,
    this.forceLandscape = false,
  });

  /// Helper untuk membuka kamera dan mengembalikan File foto bertanda air
  static Future<File?> open(
    BuildContext context, {
    String title = 'Ambil Foto Dokumentasi',
    bool useWatermark = true,
    bool forceLandscape = false,
  }) {
    return Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (ctx) => FieldCameraWidget(
          title: title,
          useWatermark: useWatermark,
          forceLandscape: forceLandscape,
        ),
      ),
    );
  }

  /// Alias takePhoto untuk fleksibilitas pemanggilan
  static Future<File?> takePhoto({
    required BuildContext context,
    String title = 'Ambil Foto Dokumentasi',
    bool useWatermark = true,
    bool forceLandscape = false,
  }) {
    return open(
      context,
      title: title,
      useWatermark: useWatermark,
      forceLandscape: forceLandscape,
    );
  }

  @override
  State<FieldCameraWidget> createState() => _FieldCameraWidgetState();
}

class _FieldCameraWidgetState extends State<FieldCameraWidget> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  bool _isInit = false;
  bool _isCapturing = false;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    if (widget.forceLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Cari kamera belakang
        final backCamIndex = _cameras!.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
        );
        _selectedCameraIndex = backCamIndex != -1 ? backCamIndex : 0;
        await _initController(_cameras![_selectedCameraIndex]);
      }
    } catch (e) {
      debugPrint('[FieldCameraWidget] Gagal inisialisasi kamera: $e');
    }
  }

  Future<void> _initController(CameraDescription description) async {
    _controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      await _controller!.setFlashMode(_flashMode);
      if (mounted) setState(() => _isInit = true);
    } catch (e) {
      debugPrint('[FieldCameraWidget] Error controller init: $e');
    }
  }

  void _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    FlashMode nextMode = FlashMode.off;
    if (_flashMode == FlashMode.off) {
      nextMode = FlashMode.auto;
    } else if (_flashMode == FlashMode.auto) {
      nextMode = FlashMode.always;
    } else {
      nextMode = FlashMode.off;
    }

    try {
      await _controller!.setFlashMode(nextMode);
      setState(() => _flashMode = nextMode);
    } catch (_) {}
  }

  void _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    setState(() => _isInit = false);
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    await _initController(_cameras![_selectedCameraIndex]);
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final XFile rawXFile = await _controller!.takePicture();
      File resultFile = File(rawXFile.path);

      if (widget.useWatermark) {
        // 1. Ambil koordinat GPS live
        Position? position;
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 5),
            ),
          );
        } catch (_) {
          position = await Geolocator.getLastKnownPosition();
        }

        final double lat = position?.latitude ?? 0.0;
        final double lng = position?.longitude ?? 0.0;
        final String address = 'Lat: ${lat.toStringAsFixed(5)}, Long: ${lng.toStringAsFixed(5)}';

        // 2. Ambil identitas user
        String? userName;
        if (!mounted) return;
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          userName = '${authState.user.namaLengkap} (${authState.user.nip})';
        }

        // 3. Tambahkan Watermark
        resultFile = await WatermarkService.addWatermark(
          imageFile: resultFile,
          timestamp: DateTime.now(),
          latitude: lat,
          longitude: lng,
          address: address,
          userName: userName,
        );
      }

      // 4. Kompresi gambar optimal
      final bytes = await resultFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        // Batasi resolusi maksimal 1600px sisi terpanjang
        img.Image resized = decoded;
        if (decoded.width > 1600 || decoded.height > 1600) {
          resized = img.copyResize(
            decoded,
            width: decoded.width >= decoded.height ? 1600 : null,
            height: decoded.height > decoded.width ? 1600 : null,
          );
        }
        final compressedJpg = img.encodeJpg(resized, quality: 85);
        final tempDir = await getTemporaryDirectory();
        final finalFile = File(
          '${tempDir.path}/field_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await finalFile.writeAsBytes(compressedJpg);
        resultFile = finalFile;
      }

      if (mounted) {
        Navigator.pop(context, resultFile);
      }
    } catch (e) {
      debugPrint('[FieldCameraWidget] Gagal memotret: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil foto: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    if (widget.forceLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit || _controller == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (widget.forceLandscape) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Camera Preview
            Center(
              child: CameraPreview(_controller!),
            ),

            // 2. Top Header Controls
            Positioned(
              top: 12,
              left: 16,
              right: 120,
              child: SafeArea(
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _flashMode == FlashMode.off
                            ? Icons.flash_off
                            : _flashMode == FlashMode.auto
                                ? Icons.flash_auto
                                : Icons.flash_on,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFlash,
                    ),
                  ],
                ),
              ),
            ),

            // 3. Right Side Controls
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol Switch Kamera
                      IconButton(
                        icon: const Icon(
                          Icons.cameraswitch,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: _switchCamera,
                      ),
                      const SizedBox(height: 24),
                      // Tombol Capture Shutter
                      GestureDetector(
                        onTap: _isCapturing ? null : _takePicture,
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color: _isCapturing
                                ? Colors.grey
                                : AppColors.primary.withAlpha(220),
                          ),
                          child: _isCapturing
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 36,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Preview
          Center(
            child: CameraPreview(_controller!),
          ),

          // 2. Top Header Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _flashMode == FlashMode.off
                        ? Icons.flash_off
                        : _flashMode == FlashMode.auto
                            ? Icons.flash_auto
                            : Icons.flash_on,
                    color: Colors.white,
                  ),
                  onPressed: _toggleFlash,
                ),
              ],
            ),
          ),

          // 3. Bottom Controls
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tombol Switch Kamera
                IconButton(
                  icon: const Icon(
                    Icons.cameraswitch,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: _switchCamera,
                ),

                // Tombol Capture Shutter
                GestureDetector(
                  onTap: _isCapturing ? null : _takePicture,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: _isCapturing
                          ? Colors.grey
                          : AppColors.primary.withAlpha(220),
                    ),
                    child: _isCapturing
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 36,
                          ),
                  ),
                ),

                // Spacing placeholder
                const SizedBox(width: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
