import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/permission_service.dart';

/// Halaman Perekaman Video In-App dengan Pembatasan Resolusi & Durasi Otomatis (Anti-413)
class FieldVideoRecorderWidget extends StatefulWidget {
  final int maxDuration;
  final String title;

  const FieldVideoRecorderWidget({
    super.key,
    this.maxDuration = 10,
    this.title = 'Rekam Video Bukti',
  });

  /// Helper untuk membuka layar perekaman video dan mengembalikan File video hasil rekaman
  static Future<File?> recordVideo(
    BuildContext context, {
    int maxDuration = 10,
    String title = 'Rekam Video Bukti',
  }) {
    return Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (ctx) => FieldVideoRecorderWidget(
          maxDuration: maxDuration,
          title: title,
        ),
      ),
    );
  }

  @override
  State<FieldVideoRecorderWidget> createState() =>
      _FieldVideoRecorderWidgetState();
}

class _FieldVideoRecorderWidgetState extends State<FieldVideoRecorderWidget>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  bool _isInit = false;
  bool _isRecording = false;
  bool _isProcessing = false;
  int _recordedSeconds = 0;
  Timer? _timer;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCameras();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initController(_cameras![_selectedCameraIndex]);
    }
  }

  Future<void> _initCameras() async {
    try {
      final hasPermission =
          await PermissionService().requestVideoRecordingPermissions();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Izin Kamera & Mikrofon dibutuhkan untuk merekam video.'),
            ),
          );
          Navigator.pop(context);
        }
        return;
      }

      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        final backCamIndex = _cameras!.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
        );
        _selectedCameraIndex = backCamIndex != -1 ? backCamIndex : 0;
        await _initController(_cameras![_selectedCameraIndex]);
      }
    } catch (e) {
      debugPrint('[FieldVideoRecorder] Gagal inisialisasi kamera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka kamera: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _initController(CameraDescription description) async {
    setState(() => _isInit = false);

    // Gunakan ResolutionPreset.medium (480p) agar video 10 detik berukuran < 3MB (Anti HTTP 413)
    _controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: true,
    );

    try {
      await _controller!.initialize();
      await _controller!.setFlashMode(_flashMode);
      if (mounted) {
        setState(() => _isInit = true);
      }
    } catch (e) {
      debugPrint('[FieldVideoRecorder] Error init controller: $e');
    }
  }

  void _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2 || _isRecording) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    await _initController(_cameras![_selectedCameraIndex]);
  }

  void _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized || _isRecording) {
      return;
    }
    FlashMode nextMode = FlashMode.off;
    if (_flashMode == FlashMode.off) {
      nextMode = FlashMode.torch;
    } else {
      nextMode = FlashMode.off;
    }

    try {
      await _controller!.setFlashMode(nextMode);
      setState(() => _flashMode = nextMode);
    } catch (_) {}
  }

  void _startTimer() {
    _recordedSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _recordedSeconds++;
      });

      // Auto-stop jika durasi mencapai batas maksimal (default 10 detik)
      if (_recordedSeconds >= widget.maxDuration) {
        _stopRecording();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _toggleRecording() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) {
      return;
    }

    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
      _startTimer();
    } catch (e) {
      debugPrint('[FieldVideoRecorder] Error start recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mulai merekam: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _isProcessing) return;

    _stopTimer();
    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });

    try {
      final XFile rawVideo = await _controller!.stopVideoRecording();
      final file = File(rawVideo.path);

      if (mounted) {
        Navigator.pop(context, file);
      }
    } catch (e) {
      debugPrint('[FieldVideoRecorder] Error stop recording: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan rekaman: $e')),
        );
      }
    }
  }

  String _formatDuration(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Menyiapkan Kamera In-App...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
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

          // 2. Processing Overlay
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Menyimpan video rekaman...',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Top Action Bar: Timer Badge & Close Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Timer Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isRecording
                        ? Colors.red.withValues(alpha: 0.85)
                        : Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _isRecording ? Colors.white : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatDuration(_recordedSeconds)} / ${_formatDuration(widget.maxDuration)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Close Button
                Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _isRecording
                        ? null
                        : () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),

          // 4. Bottom Controls: Flash, Record Button, Switch Camera
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Flash / Torch Toggle
                IconButton(
                  iconSize: 28,
                  icon: Icon(
                    _flashMode == FlashMode.torch
                        ? Icons.flash_on
                        : Icons.flash_off,
                    color: Colors.white,
                  ),
                  onPressed: _isRecording ? null : _toggleFlash,
                ),

                // Main Record Button
                GestureDetector(
                  onTap: _toggleRecording,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.transparent,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red : Colors.white,
                        borderRadius: BorderRadius.circular(
                          _isRecording ? 12 : 36,
                        ),
                      ),
                    ),
                  ),
                ),

                // Switch Camera
                IconButton(
                  iconSize: 28,
                  icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                  onPressed: _isRecording ? null : _switchCamera,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
