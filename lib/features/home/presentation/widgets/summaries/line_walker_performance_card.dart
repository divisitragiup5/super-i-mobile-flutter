import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/circular_gauge.dart';

class LineWalkerPerformanceCard extends StatefulWidget {
  const LineWalkerPerformanceCard({super.key});

  @override
  State<LineWalkerPerformanceCard> createState() =>
      _LineWalkerPerformanceCardState();
}

class _LineWalkerPerformanceCardState extends State<LineWalkerPerformanceCard> {
  bool _showMore = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ─── KARTU UTAMA (rgba(255,255,255,0.8)) ───
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.82),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Judul & Periode
              const Text(
                'Penyelesaian Tugas Minggu 4 Oktober 2026',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Status Badge (BAIK / WASPADA / KURANG)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle, color: AppColors.success, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'BAIK',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Circular Progress Gauge Utama (Radius 70, Stroke 15)
              const CircularGauge(
                progress: 88.50,
                radius: 70,
                strokeWidth: 14,
                color: AppColors.primaryLight,
                centerLabel: 'Performa',
              ),
              const SizedBox(height: 14),

              // Tombol Akordeon "Lebih lengkap / Lebih sedikit"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => setState(() => _showMore = !_showMore),
                    child: Row(
                      children: [
                        Text(
                          _showMore ? 'Lebih sedikit' : 'Lebih lengkap',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _showMore
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  // Filter Button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.filter_list,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ─── RINCIAN ITEM SAAT DI-EXPAND (rgba(0,0,0,0.4)) ───
        if (_showMore)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildPerformItem(
                    title: 'Waterpass',
                    target: 40,
                    realisasi: 38,
                    progress: 95.0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPerformItem(
                    title: 'Pembumian',
                    target: 40,
                    realisasi: 32,
                    progress: 80.0,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Kartu Gelap Transparan Persis perform-item.tsx (rgba(0,0,0,0.4))
  Widget _buildPerformItem({
    required String title,
    required int target,
    required int realisasi,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          CircularGauge(
            progress: progress,
            radius: 46,
            strokeWidth: 10,
            color: AppColors.secondary,
            showPercent: true,
          ),
          const SizedBox(height: 10),
          Text(
            '(T) $target / $realisasi (R)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
