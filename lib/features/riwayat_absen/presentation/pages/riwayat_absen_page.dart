import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/riwayat_absen_model.dart';
import '../cubit/riwayat_absen_cubit.dart';
import '../cubit/riwayat_absen_state.dart';

class RiwayatAbsenPage extends StatelessWidget {
  const RiwayatAbsenPage({super.key});

  String _formatShiftTime(int? jam, int? menit) {
    if (jam == null && menit == null) return '--:--';
    final h = (jam ?? 0).toString().padLeft(2, '0');
    final m = (menit ?? 0).toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(String? dateStr, String pattern) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat(pattern, 'id_ID').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RiwayatAbsenCubit>()..fetchHistory(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Absensi'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
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
            BlocBuilder<RiwayatAbsenCubit, RiwayatAbsenState>(
              builder: (context, state) {
                final cubit = context.read<RiwayatAbsenCubit>();

                if (state is RiwayatAbsenLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is RiwayatAbsenError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.danger,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => cubit.fetchHistory(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is RiwayatAbsenLoaded) {
                  if (state.items.isEmpty) {
                    return Center(
                      child: RefreshIndicator(
                        onRefresh: () => cubit.fetchHistory(),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            Center(
                              child: Text(
                                'Belum ada riwayat absensi.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => cubit.fetchHistory(),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 200 &&
                            !state.isLoadingMore &&
                            state.nextCursor != null) {
                          cubit.loadMore();
                        }
                        return false;
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: state.items.length +
                            (state.isLoadingMore ? 1 : 0),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == state.items.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final item = state.items[index];
                          return _buildItemCard(context, item, cubit);
                        },
                      ),
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

  Widget _buildItemCard(
    BuildContext context,
    RiwayatAbsenItemModel item,
    RiwayatAbsenCubit cubit,
  ) {
    Color badgeColor;
    String badgeText;

    if (item.premi != null && item.premi!.isNotEmpty) {
      badgeText = 'PREMI ${item.premi}';
      badgeColor = item.premi == 'ON' ? Colors.blue : Colors.amber.shade700;
    } else {
      badgeText = item.statusIn ?? '-';
      badgeColor = item.statusIn == 'ON TIME'
          ? AppColors.success
          : AppColors.danger;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.keterangan ?? '-'} (${_formatShiftTime(item.jamMasuk, item.menitMasuk)} - ${_formatShiftTime(item.jamKeluar, item.menitKeluar)})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(item.createdAt, 'dd MMMM yyyy'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (item.absenMasuk != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Masuk ${_formatDate(item.absenMasuk, 'HH:mm')} - Keluar ${item.absenKeluar != null ? _formatDate(item.absenKeluar, 'HH:mm') : 'Belum Absen'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    context.push(
                      AppRoutes.riwayatAbsenDetail,
                      extra: item,
                    );
                  },
                  child: const Text('Lihat'),
                ),
              ),
              if (item.isEditable) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () async {
                      final result = await context.push(
                        AppRoutes.riwayatAbsenUpdate,
                        extra: item,
                      );
                      if (result == true) {
                        cubit.fetchHistory();
                      }
                    },
                    child: const Text('Edit'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
