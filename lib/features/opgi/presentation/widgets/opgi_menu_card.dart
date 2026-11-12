import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Kartu Menu OPGI dengan styling & behavior persis seperti React Native `super-i-mobile`.
/// Jika [useScanner] aktif, sisi kanan kartu memiliki tombol QR Scanner berwarna primer
/// yang tersemat rapi (pinned to right edge) dengan icon QR Scanner putih.
class OpgiMenuCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final bool useScanner;
  final VoidCallback onTap;
  final VoidCallback? onScanTap;

  const OpgiMenuCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.useScanner = false,
    required this.onTap,
    this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main card body (tappable)
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: iconColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon, color: iconColor, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  description.isNotEmpty ? description : '-',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (!useScanner)
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Pinned QR Scanner Button on the right edge
              if (useScanner)
                Material(
                  color: AppColors.primary,
                  child: InkWell(
                    onTap: onScanTap,
                    child: Container(
                      width: 64,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
