import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/app_time_utils.dart';
import '../../../../../core/widgets/circular_gauge.dart';
import '../../cubit/opgi_score_cubit.dart';
import '../../cubit/opgi_score_state.dart';

class OpgiScoreSummaryCard extends StatefulWidget {
  const OpgiScoreSummaryCard({super.key});

  @override
  State<OpgiScoreSummaryCard> createState() => _OpgiScoreSummaryCardState();
}

class _OpgiScoreSummaryCardState extends State<OpgiScoreSummaryCard> {
  bool _showMore = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpgiScoreCubit, OpgiScoreState>(
      builder: (context, state) {
        if (state is OpgiScoreLoading) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is OpgiScoreError) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
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
                    context.read<OpgiScoreCubit>().fetchScore();
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (state is OpgiScoreLoaded) {
          final score = state.score;
          final isEmpty = state.isEmpty;
          final formattedDate = score?.formattedDate ??
              AppTimeUtils.formatDateTime(
                DateTime.now(),
                pattern: 'EEEE, dd MMMM yyyy',
              );

          final nilaiHarian = score?.nilaiHarian;
          final pointAbsensi = score?.pointAbsensi;
          final pointPerforma = score?.pointPerforma;
          final detailItems = score?.detail ?? [];

          return Column(
            children: [
              // ─── KARTU KACA UTAMA OPGI 20KV ───
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.82),
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
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (isEmpty) ...[
                      // Empty state matching super-i-mobile
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.storage_rounded,
                              size: 36,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Data tidak ditemukan',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // 1. GAUGE BESAR (NILAI HARIAN)
                      CircularGauge(
                        progress: nilaiHarian?.point ?? 0.0,
                        radius: 65,
                        strokeWidth: 13,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nilaiHarian?.label ?? 'NILAI HARIAN',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2 & 3. DUA GAUGE SEKUNDER (POINT ABSENSI & POINT PERFORMA)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              CircularGauge(
                                progress: pointAbsensi?.point ?? 0.0,
                                radius: 46,
                                strokeWidth: 10,
                                color: AppColors.primaryLight,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pointAbsensi?.label ?? 'POINT ABSENSI',
                                style: const TextStyle(
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
                                progress: pointPerforma?.point ?? 0.0,
                                radius: 46,
                                strokeWidth: 10,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pointPerforma?.label ?? 'POINT PERFORMA',
                                style: const TextStyle(
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
                      if (detailItems.isNotEmpty)
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
                  ],
                ),
              ),

              // ─── DETAIL METRIK SAAT DI-EXPAND (Grid 2 Kolom Khas Legacy) ───
              if (_showMore && detailItems.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: detailItems.map((item) {
                      return _buildOpgiDetailItem(
                        item.label,
                        item.target,
                        item.realisasi,
                        item.score,
                      );
                    }).toList(),
                  ),
                ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
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
