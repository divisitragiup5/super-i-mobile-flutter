import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_colors.dart';
import '../utils/app_url_utils.dart';

/// Widget pemutar video in-app universal untuk File lokal maupun URL remote
class AppVideoPlayer extends StatefulWidget {
  final File? videoFile;
  final String? videoUrl;
  final double height;
  final bool autoPlay;
  final bool looping;
  final bool startMuted;
  final BorderRadius? borderRadius;

  const AppVideoPlayer({
    super.key,
    this.videoFile,
    this.videoUrl,
    this.height = 220,
    this.autoPlay = false,
    this.looping = true,
    this.startMuted = true,
    this.borderRadius,
  });

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isMuted = true;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _isMuted = widget.startMuted;
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant AppVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final fileChanged = widget.videoFile?.path != oldWidget.videoFile?.path;
    final urlChanged = widget.videoUrl != oldWidget.videoUrl;
    if (fileChanged || urlChanged) {
      _disposePlayer();
      _initPlayer();
    }
  }

  Future<void> _initPlayer() async {
    _hasError = false;
    _isInitialized = false;

    try {
      if (widget.videoFile != null && widget.videoFile!.existsSync()) {
        _controller = VideoPlayerController.file(widget.videoFile!);
      } else if (widget.videoUrl != null && widget.videoUrl!.trim().isNotEmpty) {
        final resolvedUrl = AppUrlUtils.resolveMediaUrl(widget.videoUrl);
        if (resolvedUrl == null || resolvedUrl.isEmpty) {
          throw Exception('URL video tidak valid');
        }
        _controller = VideoPlayerController.networkUrl(Uri.parse(resolvedUrl));
      } else {
        throw Exception('File atau URL video tidak ditemukan');
      }

      await _controller!.initialize();
      await _controller!.setLooping(widget.looping);
      await _controller!.setVolume(_isMuted ? 0.0 : 1.0);

      if (widget.autoPlay) {
        await _controller!.play();
      }

      _controller!.addListener(_onControllerUpdate);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (msg.contains('channel-error') || msg.contains('pigeon')) {
          msg = 'Plugin pemutar video membutuhkan Full Rebuild/Restart aplikasi (Stop & Run ulang).';
        }
        setState(() {
          _hasError = true;
          _errorMessage = msg;
        });
      }
    }
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _disposePlayer() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  void _toggleMute() {
    if (_controller == null || !_isInitialized) return;
    final newMuted = !_isMuted;
    setState(() => _isMuted = newMuted);
    _controller!.setVolume(newMuted ? 0.0 : 1.0);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(8);

    if (_hasError) {
      return Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: radius,
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off_outlined, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            const Text(
              'Gagal memuat video',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _initPlayer,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text('Coba Lagi', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: radius,
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
        ),
      );
    }

    final isPlaying = _controller!.value.isPlaying;
    final position = _controller!.value.position;
    final duration = _controller!.value.duration;

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        height: widget.height,
        width: double.infinity,
        color: Colors.black,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _showControls = !_showControls;
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Video surface
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio > 0
                      ? _controller!.value.aspectRatio
                      : 16 / 9,
                  child: VideoPlayer(_controller!),
                ),
              ),

              // Controls overlay
              if (_showControls || !isPlaying)
                Container(
                  color: isPlaying ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.4),
                  child: Stack(
                    children: [
                      // Mute Button (Top Left - identical to super-i-mobile)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _toggleMute,
                            child: Padding(
                              padding: const EdgeInsets.all(7),
                              child: Icon(
                                _isMuted ? Icons.volume_off : Icons.volume_up,
                                size: 18,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Play / Pause Center Button
                      Center(
                        child: Material(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: const CircleBorder(),
                          child: IconButton(
                            iconSize: 42,
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: _togglePlayPause,
                          ),
                        ),
                      ),

                      // Bottom Progress & Duration Bar
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              VideoProgressIndicator(
                                _controller!,
                                allowScrubbing: true,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                colors: const VideoProgressColors(
                                  playedColor: AppColors.primary,
                                  bufferedColor: Colors.white38,
                                  backgroundColor: Colors.white24,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _togglePlayPause,
                                    child: Text(
                                      isPlaying ? 'PAUSE' : 'PLAY',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
