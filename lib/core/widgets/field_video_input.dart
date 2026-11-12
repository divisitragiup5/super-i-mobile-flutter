import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_video_player.dart';
import 'field_video_recorder_widget.dart';

/// Komponen Input Video Lapangan (pengganti VideoInput di React Native)
/// Menyediakan perekaman video in-app beresolusi optimal (anti-413),
/// preview player in-app langsung, dan tombol Hapus Video.
/// HANYA mengizinkan rekam in-app kamera (tidak ada upload/galeri).
class FieldVideoInput extends StatelessWidget {
  final String label;
  final String placeholder;
  final File? videoFile;
  final String? initialUrl;
  final ValueChanged<File?> onChange;
  final bool isRequired;
  final String? errorText;
  final int maxDuration;

  const FieldVideoInput({
    super.key,
    required this.label,
    this.placeholder = 'Ambil video (Maks 10 Detik)',
    required this.onChange,
    this.videoFile,
    this.initialUrl,
    this.isRequired = false,
    this.errorText,
    this.maxDuration = 10,
  });

  Future<void> _recordVideo(BuildContext context) async {
    final recorded = await FieldVideoRecorderWidget.recordVideo(
      context,
      maxDuration: maxDuration,
      title: label,
    );
    if (recorded != null) {
      onChange(recorded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasFile = videoFile != null;
    final bool hasUrl = initialUrl != null && initialUrl!.trim().isNotEmpty;
    final bool hasVideo = hasFile || hasUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Form
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),

        // Video Player Preview atau Tombol Input
        if (hasVideo) ...[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppVideoPlayer(
                videoFile: hasFile ? videoFile : null,
                videoUrl: !hasFile && hasUrl ? initialUrl : null,
                height: 220,
                autoPlay: true,
                looping: true,
                startMuted: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => onChange(null),
              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
              label: const Text(
                'Hapus Video',
                style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ] else ...[
          InkWell(
            onTap: () => _recordVideo(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: errorText != null ? AppColors.danger : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    placeholder,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                  const Icon(
                    Icons.videocam_outlined,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ],

        // Error text jika ada
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(
              color: AppColors.danger,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
