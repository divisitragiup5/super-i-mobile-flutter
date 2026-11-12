import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Loading indicator card yang menampilkan animasi loading dan status progres persentase,
/// persis sesuai dengan komponen `LoadingIndicator` pada `super-i-mobile`.
class LoadingIndicator extends StatelessWidget {
  final String? text;
  final String? progress;
  final EdgeInsetsGeometry? margin;

  const LoadingIndicator({
    super.key,
    this.text,
    this.progress,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            if (text != null && text!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                text!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (progress != null && progress!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                progress!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
