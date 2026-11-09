import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../cubit/ppl_condition_summary_cubit.dart';
import 'package:super_i_mobile/features/home/data/models/ppl_condition_summary_model.dart';

class PplSummaryCard extends StatelessWidget {
  const PplSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PplConditionSummaryCubit, PplConditionSummaryState>(
      builder: (context, state) {
        if (state is PplConditionSummaryLoading) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          );
        }

        if (state is PplConditionSummaryError) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppColors.danger, size: 28),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: const TextStyle(fontSize: 13, color: AppColors.danger),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => context.read<PplConditionSummaryCubit>().fetchSummary(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (state is PplConditionSummaryLoaded) {
          final summary = state.summary;
          return _buildContent(context, summary);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'PPL',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 32,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Data tidak ditemukan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Belum ada data monitoring kondisi & tanda tangan PPL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, PplConditionSummaryModel summary) {
    if (summary.total == 0 || (summary.signatures.isEmpty && summary.statuses.isEmpty)) {
      return _buildEmptyCard(context);
    }

    final statusOrder = ['Kritis', 'Waspada', 'Bahaya', 'Aman'];
    final sortedStatuses = List<PplStatusItem>.from(summary.statuses)
      ..sort((a, b) {
        final iA = statusOrder.indexOf(a.kategoriObjek);
        final iB = statusOrder.indexOf(b.kategoriObjek);
        final orderA = iA == -1 ? 999 : iA;
        final orderB = iB == -1 ? 999 : iB;
        return orderA.compareTo(orderB);
      });

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'PPL',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Donut Chart
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(150, 150),
                  painter: _PplDonutChartPainter(
                    signatures: summary.signatures,
                    total: summary.total,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${summary.total}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'Total Objek',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Legend Signature
          if (summary.signatures.isNotEmpty)
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: summary.signatures.map((sig) {
                final isSudah = sig.status.toLowerCase().contains('sudah');
                final color = isSudah ? const Color(0xFF22C55E) : const Color(0xFFF59E0B);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${sig.count} ${sig.status}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          if (summary.signatures.isNotEmpty && sortedStatuses.isNotEmpty)
            const SizedBox(height: 16),

          // Status Badges (Kritis, Waspada, Bahaya, Aman)
          if (sortedStatuses.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: sortedStatuses.map((st) {
                final color = _getStatusColor(st.kategoriObjek);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${st.count} ${st.kategoriObjek}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    final lower = status.toLowerCase();
    if (lower == 'kritis') return const Color(0xFFEF4444);
    if (lower == 'waspada') return const Color(0xFFF97316);
    if (lower == 'bahaya') return const Color(0xFFEAB308);
    return const Color(0xFF22C55E);
  }
}

class _PplDonutChartPainter extends CustomPainter {
  final List<PplSignatureItem> signatures;
  final int total;

  _PplDonutChartPainter({
    required this.signatures,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 26.0;

    final bgPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    if (total == 0 || signatures.isEmpty) return;

    double startAngle = -math.pi / 2;

    for (final sig in signatures) {
      if (sig.count <= 0) continue;
      final sweepAngle = (sig.count / total) * 2 * math.pi;

      final isSudah = sig.status.toLowerCase().contains('sudah');
      final color = isSudah ? const Color(0xFF22C55E) : const Color(0xFFF59E0B);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PplDonutChartPainter oldDelegate) {
    return oldDelegate.total != total || oldDelegate.signatures != signatures;
  }
}
