import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/color_parser.dart';
import '../../../../../core/widgets/circular_gauge.dart';
import '../../cubit/sutm_inspeksi_score_cubit.dart';
import '../../cubit/sutm_inspeksi_score_state.dart';

class SutmInspeksiScoreCard extends StatelessWidget {
  const SutmInspeksiScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SutmInspeksiScoreCubit, SutmInspeksiScoreState>(
      builder: (context, state) {
        if (state is SutmInspeksiScoreLoading) {
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is SutmInspeksiScoreError) {
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.message,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<SutmInspeksiScoreCubit>().fetchScore();
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (state is SutmInspeksiScoreLoaded) {
          final score = state.score;
          final dateParsed = DateTime.tryParse(score.date) ?? DateTime.now();
          final formattedDate =
              DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dateParsed);

          final performaColor = ColorParser.parse(
            score.performaConfig?.color,
            fallback: const Color(0xFF10B981),
          );
          final pencapaianColor = ColorParser.parse(
            score.pencapaianInspeksiConfig?.color,
            fallback: const Color(0xFFF59E0B),
          );
          final durasiColor = ColorParser.parse(
            score.durasiInspeksiConfig?.color,
            fallback: const Color(0xFF3B82F6),
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
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
                // Header Judul & Tanggal
                const Text(
                  'Penilaian Hari Ini',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // 1. Gauge Performa (Besar di Atas)
                CircularGauge(
                  progress: score.performa,
                  radius: 65,
                  strokeWidth: 12,
                  color: performaColor,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Performa',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Dua Sub-Metrik Bersebelahan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Kiri: Pencapaian Inspeksi
                    Expanded(
                      child: Column(
                        children: [
                          CircularGauge(
                            progress: score.pointPencapaianInspeksi,
                            radius: 46,
                            strokeWidth: 10,
                            color: pencapaianColor,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Pencapaian Inspeksi',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Kanan: Durasi Inspeksi
                    Expanded(
                      child: Column(
                        children: [
                          CircularGauge(
                            progress: score.pointDurasiInspeksi,
                            radius: 46,
                            strokeWidth: 10,
                            color: durasiColor,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Durasi Inspeksi',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
