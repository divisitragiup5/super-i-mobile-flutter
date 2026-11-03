import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'field_camera_widget.dart';

/// Komponen Input Foto Lapangan (pengganti PictInput di React Native)
class FieldPictInput extends StatelessWidget {
  final String label;
  final String placeholder;
  final File? pictureFile;
  final String? initialUrl;
  final ValueChanged<File?> onChange;
  final bool isRequired;
  final String? errorText;

  const FieldPictInput({
    super.key,
    required this.label,
    required this.placeholder,
    required this.onChange,
    this.pictureFile,
    this.initialUrl,
    this.isRequired = false,
    this.errorText,
  });

  Future<void> _openCamera(BuildContext context) async {
    final file = await FieldCameraWidget.open(
      context,
      title: label,
    );
    if (file != null) {
      onChange(file);
    }
  }

  void _showImagePreview(BuildContext context, ImageProvider imageProvider) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image(image: imageProvider, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasFile = pictureFile != null && pictureFile!.existsSync();
    final bool hasUrl = initialUrl != null && initialUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            if (isRequired)
              const Text(' *', style: TextStyle(color: AppColors.danger)),
          ],
        ),
        const SizedBox(height: 6),
        if (hasFile || hasUrl) ...[
          // Tampilan Preview Gambar dengan Tombol Hapus
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: () {
                      final provider = hasFile
                          ? FileImage(pictureFile!) as ImageProvider
                          : NetworkImage(initialUrl!) as ImageProvider;
                      _showImagePreview(context, provider);
                    },
                    child: hasFile
                        ? Image.file(pictureFile!, fit: BoxFit.cover)
                        : Image.network(initialUrl!, fit: BoxFit.cover),
                  ),
                  // Tombol Hapus Foto
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                        onPressed: () => onChange(null),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // Tombol Buka Kamera
          InkWell(
            onTap: () => _openCamera(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: errorText != null
                      ? AppColors.danger
                      : const Color(0xFFCBD5E1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    placeholder,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xFF64748B),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ],
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(color: AppColors.danger, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
