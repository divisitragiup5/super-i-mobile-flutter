import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/history_penilaian_model.dart';
import '../cubit/history_penilaian_cubit.dart';
import '../cubit/history_penilaian_state.dart';
import '../widgets/penilaian_header_card.dart';

class DetailHistoryPenilaianPage extends StatelessWidget {
  final NilaiBulananItemModel item;

  const DetailHistoryPenilaianPage({super.key, required this.item});

  void _showComponentSheet(BuildContext context, NilaiHarianItemModel harian) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Komponen Point Performa Nilai Harian',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (harian.scoreComponents.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Tidak ada rincian komponen performa untuk hari ini.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: harian.scoreComponents.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final comp = harian.scoreComponents[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comp.code,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildCompRow('Total Point', comp.totalPoint.toStringAsFixed(2)),
                            const SizedBox(height: 4),
                            _buildCompRow('Total Target', comp.totalTarget.toStringAsFixed(2)),
                            const SizedBox(height: 4),
                            _buildCompRow('Rata-rata Point', comp.averagePoint.toStringAsFixed(2)),
                            const SizedBox(height: 4),
                            _buildCompRow('Total Realisasi', comp.totalRealisasi.toStringAsFixed(2)),
                            const SizedBox(height: 4),
                            _buildCompRow('Persen Realisasi', '${comp.persenRealisasi.toStringAsFixed(2)}%'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildCompRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthDate = DateTime(item.tahun, item.bulan + 1, item.perTanggal);
    final monthStr = DateFormat('MMMM yyyy', 'id_ID').format(monthDate);

    return BlocProvider(
      create: (_) => sl<DetailHistoryPenilaianCubit>()
        ..fetchDetail(bulan: item.bulan, tahun: item.tahun),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Rincian Penilaian - $monthStr'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ctx.read<DetailHistoryPenilaianCubit>().fetchDetail(
                        bulan: item.bulan,
                        tahun: item.tahun,
                      );
                },
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.backgroundLight,
                ),
              ),
            ),
            BlocBuilder<DetailHistoryPenilaianCubit, DetailHistoryPenilaianState>(
              builder: (context, state) {
                final cubit = context.read<DetailHistoryPenilaianCubit>();

                if (state is DetailHistoryPenilaianLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DetailHistoryPenilaianError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => cubit.fetchDetail(
                              bulan: item.bulan,
                              tahun: item.tahun,
                            ),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is DetailHistoryPenilaianLoaded) {
                  return RefreshIndicator(
                    onRefresh: () => cubit.fetchDetail(
                      bulan: item.bulan,
                      tahun: item.tahun,
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.harianItems.length + 1,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return PenilaianHeaderCard(
                            grafik: state.grafik ?? _fallbackGrafik(item),
                            bulanFallback: item.bulan,
                          );
                        }

                        final harian = state.harianItems[index - 1];
                        return _buildHarianCard(context, harian);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  GrafikBulananModel _fallbackGrafik(NilaiBulananItemModel item) {
    return GrafikBulananModel(
      nilaiKinerja: item.nilaiKinerja,
      pointAbsensi: item.pointAbsensi,
      pointPerforma: item.pointPerforma,
      status: item.status,
      perTanggal: item.perTanggal,
      bulanString: '',
      tahun: item.tahun,
    );
  }

  Widget _buildHarianCard(BuildContext context, NilaiHarianItemModel harian) {
    String dateStr = '-';
    if (harian.createdAt != null) {
      try {
        final dt = DateTime.parse(harian.createdAt!).toLocal();
        dateStr = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dt);
      } catch (_) {
        dateStr = harian.createdAt!;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateStr,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          _buildRow('Nilai Harian', harian.nilaiHarian.toStringAsFixed(2)),
          const SizedBox(height: 4),
          _buildRow('Point Absen', harian.pointAbsensi.toStringAsFixed(2)),
          const SizedBox(height: 4),
          _buildRow('Point Performa', harian.pointPerforma.toStringAsFixed(2)),
          const SizedBox(height: 10),

          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 36),
            ),
            onPressed: () => _showComponentSheet(context, harian),
            child: const Text('Lihat Rincian Komponen'),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
