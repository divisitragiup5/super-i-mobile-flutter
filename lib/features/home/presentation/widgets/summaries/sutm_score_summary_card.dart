import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/circular_gauge.dart';

class SutmScoreSummaryCard extends StatelessWidget {
  final String title;

  const SutmScoreSummaryCard({super.key, this.title = 'Penilaian Hari Ini'});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Distribusi Saluran Udara Tegangan Menengah',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // 1. Gauge Utama (Performa)
          const CircularGauge(
            progress: 92.0,
            radius: 65,
            strokeWidth: 13,
            color: AppColors.success,
            centerLabel: 'Performa',
          ),
          const SizedBox(height: 16),

          // 2. Dua Gauge Sekunder (Pencapaian vs Durasi)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Column(
                children: [
                  CircularGauge(
                    progress: 88.0,
                    radius: 46,
                    strokeWidth: 10,
                    color: AppColors.warning,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'PENCAPAIAN',
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
                    progress: 96.0,
                    radius: 46,
                    strokeWidth: 10,
                    color: AppColors.info,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'DURASI INSPEKSI',
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
        ],
      ),
    );
  }
}
