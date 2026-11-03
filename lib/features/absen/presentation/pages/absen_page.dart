import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../cubit/absen_info_cubit.dart';
import '../cubit/absen_info_state.dart';
import '../widgets/absen_map_widget.dart';

class AbsenPage extends StatelessWidget {
  const AbsenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AbsenInfoCubit>()..fetchAbsenInfo(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Presensi Lapangan'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<AbsenInfoCubit, AbsenInfoState>(
          builder: (context, state) {
            if (state is AbsenInfoLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AbsenInfoError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.danger,
                      ),
                      const SizedBox(height: 12),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      AppButton(
                        text: 'Coba Lagi',
                        onPressed: () {
                          context.read<AbsenInfoCubit>().fetchAbsenInfo();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is AbsenInfoLoaded) {
              final info = state.info;
              final isInside = state.isInsideRadius;

              // Format Jam Shift
              String jamShift = '-';
              if (info.shift != null && info.shift!['ketentuan'] != null) {
                final k = info.shift!['ketentuan'];
                final start =
                    '${k['startHour'].toString().padLeft(2, '0')}:${k['startMinute'].toString().padLeft(2, '0')}';
                final end =
                    '${k['endHour'].toString().padLeft(2, '0')}:${k['endMinute'].toString().padLeft(2, '0')}';
                jamShift = '$start - $end WIB';
              }

              final todayFormatted = DateFormat(
                'EEEE, d MMMM yyyy',
                'id_ID',
              ).format(DateTime.now());

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<AbsenInfoCubit>().fetchAbsenInfo();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Peta Geofence OpenStreetMap
                      AbsenMapWidget(
                        userPosition: state.userPosition,
                        absenLocation: info.absenLocation,
                        isInsideRadius: isInside,
                      ),
                      const SizedBox(height: 12),

                      // Status Geofence Indicator Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isInside
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isInside ? Icons.check_circle : Icons.cancel,
                              size: 16,
                              color: isInside
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isInside
                                  ? 'Anda berada di dalam radius presensi'
                                  : 'Anda berada di luar radius presensi',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isInside
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. Card Informasi Shift
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'INFORMASI SHIFT',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Divider(height: 16),
                              _buildInfoRow('Tanggal', todayFormatted),
                              const SizedBox(height: 8),
                              _buildInfoRow('Jam Kerja', jamShift),
                              const SizedBox(height: 8),
                              _buildInfoRow('Keterangan', info.keterangan),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. Tombol Aksi (Clock In & Clock Out)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed:
                                  (info.hasInAbsen ||
                                      !info.hasShift ||
                                      info.isPremiOff)
                                  ? null
                                  : () async {
                                      final res = await context.push<bool>(
                                        AppRoutes.absenProcessing,
                                        extra: {
                                          'type': 'MASUK',
                                          'dataShift': info.shift != null
                                              ? {'shift': info.shift}
                                              : null,
                                          'absenLocation': info.absenLocation,
                                        },
                                      );
                                      if (res == true && context.mounted) {
                                        context
                                            .read<AbsenInfoCubit>()
                                            .fetchAbsenInfo();
                                      }
                                    },
                              child: const Text(
                                'CLOCK IN',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0284C7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed:
                                  ((!info.hasShift && !info.hasInAbsen) ||
                                      info.isPremiOff)
                                  ? null
                                  : () async {
                                      final res = await context.push<bool>(
                                        AppRoutes.absenProcessing,
                                        extra: {
                                          'type': 'KELUAR',
                                          'dataShift': info.shift != null
                                              ? {'shift': info.shift}
                                              : null,
                                          'absenLocation': info.absenLocation,
                                        },
                                      );
                                      if (res == true && context.mounted) {
                                        context
                                            .read<AbsenInfoCubit>()
                                            .fetchAbsenInfo();
                                      }
                                    },
                              child: const Text(
                                'CLOCK OUT',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Tombol Premi
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: (info.hasInAbsen || info.isPremiOff)
                            ? null
                            : () {
                                context.push('/absen-premi');
                              },
                        child: const Text(
                          'PREMI',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
