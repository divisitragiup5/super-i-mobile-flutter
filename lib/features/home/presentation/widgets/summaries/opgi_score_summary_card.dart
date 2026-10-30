import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/circular_gauge.dart';

class OpgiScoreSummaryCard extends StatefulWidget {
  const OpgiScoreSummaryCard({super.key});

  @override
  State<OpgiScoreSummaryCard> createState() => _OpgiScoreSummaryCardState();
}

class _OpgiScoreSummaryCardState extends State<OpgiScoreSummaryCard> {
  bool _showMore = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ─── KARTU KACA UTAMA OPGI 20KV ───
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
              const Text(
                'Penilaian Kinerja',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Jumat, 30 Oktober 2026',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // 1. GAUGE BESAR (NILAI HARIAN)
              const CircularGauge(
                progress: 96.50,
                radius: 65,
                strokeWidth: 13,
                color: AppColors.primary,
              ),
              const SizedBox(height: 4),
              const Text(
                'NILAI HARIAN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // 2 & 3. DUA GAUGE SEKUNDER (POINT ABSENSI & POINT PERFORMA)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Column(
                    children: [
                      CircularGauge(
                        progress: 100.0,
                        radius: 46,
                        strokeWidth: 10,
                        color: AppColors.primaryLight,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'POINT ABSENSI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      CircularGauge(
                        progress: 93.0,
                        radius: 46,
                        strokeWidth: 10,
                        color: AppColors.secondary,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'POINT PERFORMA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Toggle Akordeon
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => setState(() => _showMore = !_showMore),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
              ),
            ],
          ),
        ),

        // ─── DETAIL METRIK SAAT DI-EXPAND (Grid 2 Kolom Khas Legacy) ───
        if (_showMore)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildOpgiDetailItem('Catat Beban', 24, 24, 100.0),
                _buildOpgiDetailItem('Inspeksi IL 1', 12, 12, 100.0),
                _buildOpgiDetailItem('Log Manuver', 4, 3, 75.0),
                _buildOpgiDetailItem('Tindak Anomali', 2, 2, 100.0),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOpgiDetailItem(
    String title,
    int target,
    int realisasi,
    double progress,
  ) {
    return Container(
      width: (MediaQuery.of(context).size.width - 52) / 2, // 2 Kolom presisi
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(
          200,
          255,
          255,
          0.65,
        ), // Persis legacy rgba(200,255,255,0.6)
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          CircularGauge(
            progress: progress,
            radius: 40,
            strokeWidth: 8,
            color: AppColors.primary,
            showPercent: true,
          ),
          const SizedBox(height: 8),
          Text(
            '(T) $target / $realisasi (R)',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
