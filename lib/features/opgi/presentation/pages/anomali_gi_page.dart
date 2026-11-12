import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_time_utils.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/input_container.dart';
import '../../data/models/opgi_anomali_model.dart';
import '../cubit/opgi_anomali_cubit.dart';

class AnomaliGiPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;

  const AnomaliGiPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
  });

  @override
  State<AnomaliGiPage> createState() => _AnomaliGiPageState();
}

class _AnomaliGiPageState extends State<AnomaliGiPage> {
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    context.read<OpgiAnomaliCubit>().loadHistory(widget.garduIndukId);
  }

  void _confirmDelete(AnomaliReportModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Peringatan'),
        content: Text(
          'Apakah Anda yakin ingin menghapus data anomali ${item.assetNama}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<OpgiAnomaliCubit>()
                  .deleteAnomali(item.id, widget.garduIndukId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getUrgensiColor(String urgensi) {
    switch (urgensi.toUpperCase()) {
      case 'BAHAYA':
        return AppColors.danger;
      case 'INVESTIGASI LANJUTAN':
        return AppColors.warning;
      case 'AMAN':
        return AppColors.success;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anomali - ${widget.garduIndukNama}'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetch,
          ),
        ],
      ),
      body: AppBackground(
        child: BlocConsumer<OpgiAnomaliCubit, OpgiAnomaliState>(
          listener: (context, state) {
            if (state is OpgiAnomaliSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              _fetch();
            } else if (state is OpgiAnomaliError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.danger,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is OpgiAnomaliLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = state is OpgiAnomaliLoaded ? state.items : <AnomaliReportModel>[];
            final drafts = state is OpgiAnomaliLoaded ? state.localDrafts : <Map<String, dynamic>>[];
            final hasDraft = drafts.isNotEmpty;

            return RefreshIndicator(
              onRefresh: () async => _fetch(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // Info Container Gardu Induk & Tambah Anomali
                  InputContainer(
                    label: 'INFO',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InputWithLabel(
                          label: 'Gardu Induk',
                          child: Text(
                            widget.garduIndukNama,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(color: AppTheme.primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  await context.push(
                                    AppRoutes.inputAnomaliGi,
                                    extra: {
                                      'garduIndukId': widget.garduIndukId,
                                      'garduIndukNama': widget.garduIndukNama,
                                    },
                                  );
                                  _fetch();
                                },
                                child: Text(
                                  'Tambah Anomali',
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (hasDraft)
                              const Positioned(
                                right: 12,
                                child: Icon(
                                  Icons.drafts,
                                  color: AppColors.danger,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Daftar Anomali
                  if (items.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.green.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tidak ada laporan anomali di GI ini',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  else
                    ...items.map((item) {
                      final urgensiColor = _getUrgensiColor(item.latestUrgensi);
                      final isSelesai = item.isSelesai;
                      final inspectionDate = AppTimeUtils.formatDateTime(
                        item.latestCreatedAt,
                        pattern: 'EEEE, d MMMM yyyy HH:mm',
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Nama Aset & Urgensi Badge
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.assetNama} (${item.entitas})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: urgensiColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.latestUrgensi,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: urgensiColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Inspeksi Terakhir Info
                            const Text(
                              'Inspeksi Terakhir :',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8, top: 2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    inspectionDate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tindakan : ${item.latestTindakan}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Tombol Aksi: Lihat & Delete
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      side: BorderSide(color: AppTheme.primary),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () async {
                                      await context.push(
                                        AppRoutes.dataAnomaliGi,
                                        extra: {
                                          'nama': item.assetNama,
                                          'id': item.id,
                                          'garduInduk': widget.garduIndukNama,
                                          'garduIndukId': widget.garduIndukId,
                                          'data': item,
                                          'progress': item.latestTindakan,
                                        },
                                      );
                                      _fetch();
                                    },
                                    child: Text(
                                      'Lihat',
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  style: IconButton.styleFrom(
                                    backgroundColor: isSelesai
                                        ? Colors.grey.shade200
                                        : AppColors.danger.withValues(alpha: 0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.delete,
                                    color: isSelesai ? Colors.grey : AppColors.danger,
                                    size: 20,
                                  ),
                                  onPressed: isSelesai ? null : () => _confirmDelete(item),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
