import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/color_parser.dart';
import '../../../../../core/widgets/circular_gauge.dart';
import '../../cubit/sutm_pemeliharaan_score_cubit.dart';
import '../../cubit/sutm_pemeliharaan_score_state.dart';

class SutmPemeliharaanScoreCard extends StatefulWidget {
  const SutmPemeliharaanScoreCard({super.key});

  @override
  State<SutmPemeliharaanScoreCard> createState() =>
      _SutmPemeliharaanScoreCardState();
}

class _SutmPemeliharaanScoreCardState extends State<SutmPemeliharaanScoreCard> {
  bool _showMore = false;

  String _formatDuration(int? minutes) {
    if (minutes == null || minutes <= 0) return '0 Menit';
    if (minutes < 60) return '$minutes Menit';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '$h Jam $m Menit' : '$h Jam';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SutmPemeliharaanScoreCubit, SutmPemeliharaanScoreState>(
      builder: (context, state) {
        if (state is SutmPemeliharaanScoreLoading) {
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is SutmPemeliharaanScoreError) {
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
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
                    context.read<SutmPemeliharaanScoreCubit>().fetchScore();
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (state is SutmPemeliharaanScoreLoaded) {
          final score = state.score;
          final dateParsed = DateTime.tryParse(score.date) ?? DateTime.now();
          final formattedDate =
              DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dateParsed);

          final performaColor = ColorParser.parse(
            score.performaConfig?.color,
            fallback: const Color(0xFF10B981),
          );
          final pencapaianColor = ColorParser.parse(
            score.pencapaianPemeliharaanConfig?.color,
            fallback: const Color(0xFFF59E0B),
          );
          final penyelesaianColor = ColorParser.parse(
            score.penyelesaianRencanaConfig?.color,
            fallback: const Color(0xFF3B82F6),
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header: Judul, Tanggal, & Badge Kategori ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Penilaian Hari Ini',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (score.performaConfig?.category != null &&
                        score.performaConfig!.category!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: performaColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: performaColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          score.performaConfig!.category!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: performaColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 0.8),
                const SizedBox(height: 12),

                // ─── 3 Circular Gauges ───
                // Gauge Utama: Performa
                Center(
                  child: Column(
                    children: [
                      CircularGauge(
                        progress: score.performa,
                        radius: 65,
                        strokeWidth: 11,
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
                      if (score.performaConfig?.category != null)
                        Text(
                          '(${score.performaConfig!.category})',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: performaColor,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Dua Sub-Metrik Bersebelahan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Kiri: Pencapaian Pemeliharaan
                    Expanded(
                      child: Column(
                        children: [
                          CircularGauge(
                            progress: score.pointPencapaianPemeliharaan,
                            radius: 46,
                            strokeWidth: 10,
                            color: pencapaianColor,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Pencapaian Pemeliharaan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (score.pencapaianPemeliharaanConfig?.category !=
                              null)
                            Text(
                              '(${score.pencapaianPemeliharaanConfig!.category})',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: pencapaianColor,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Kanan: Penyelesaian Rencana
                    Expanded(
                      child: Column(
                        children: [
                          CircularGauge(
                            progress: score.pointPenyelesaianRencana,
                            radius: 46,
                            strokeWidth: 10,
                            color: penyelesaianColor,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Penyelesaian Rencana',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (score.penyelesaianRencanaConfig?.category != null)
                            Text(
                              '(${score.penyelesaianRencanaConfig!.category})',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: penyelesaianColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ─── Accordion Rincian (Show More) ───
                if (_showMore) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 0.8),
                  const SizedBox(height: 12),

                  // Card 1: Target & Realisasi Pemeliharaan
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.assignment_turned_in_outlined,
                                  size: 16,
                                  color: Color(0xFF0284C7),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Target & Realisasi Pemeliharaan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${score.pencapaianPemeliharaan.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0369A1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (score.pencapaianPemeliharaan / 100)
                                .clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF0EA5E9),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const Text(
                                    'Target',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${score.targetPemeliharaan}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 24,
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  const Text(
                                    'Realisasi',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${score.realisasiPemeliharaan}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF10B981),
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
                  const SizedBox(height: 10),

                  // Card 2: Volume Pekerjaan
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.layers_outlined,
                                  size: 16,
                                  color: Color(0xFF4F46E5),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Volume Pekerjaan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${score.penyelesaianRencana.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4338CA),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (score.penyelesaianRencana / 100)
                                .clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF6366F1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const Text(
                                    'Rencana',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${score.volumeRencana}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 24,
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  const Text(
                                    'Terlaksana',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${score.volumeTerlaksana}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 24,
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  const Text(
                                    'Kendala',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${score.volumeKendala}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE11D48),
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
                  const SizedBox(height: 10),

                  // Card 3: Durasi Pemeliharaan
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFEF3C7)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFDE68A),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Color(0xFFB45309),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Durasi Pemeliharaan',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  _formatDuration(score.durasiPemeliharaan),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFFDE68A),
                            ),
                          ),
                          child: Text(
                            '${score.durasiPemeliharaan} mnt',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ─── Footer: Toggle Accordion & Shortcut Riwayat ───
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 0.8),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showMore = !_showMore;
                        });
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 4,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Lebih ${_showMore ? 'sedikit' : 'lengkap'}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _showMore
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        context.push('/riwayat-penilaian-har');
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 4,
                        ),
                        child: Row(
                          children: const [
                            Text(
                              'Riwayat',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: Color(0xFF0284C7),
                            ),
                          ],
                        ),
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
