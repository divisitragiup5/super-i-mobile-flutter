import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_time_utils.dart';
import '../../../../core/utils/app_url_utils.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_video_player.dart';
import '../../../../core/widgets/input_container.dart';
import '../../data/models/opgi_anomali_model.dart';
import '../cubit/opgi_anomali_cubit.dart';

class DataAnomaliGiPage extends StatefulWidget {
  final int anomaliId;
  final String garduIndukNama;
  final int garduIndukId;
  final AnomaliReportModel anomaliData;
  final String initialProgress;

  const DataAnomaliGiPage({
    super.key,
    required this.anomaliId,
    required this.garduIndukNama,
    required this.garduIndukId,
    required this.anomaliData,
    this.initialProgress = 'TIDAK ADA',
  });

  @override
  State<DataAnomaliGiPage> createState() => _DataAnomaliGiPageState();
}

class _DataAnomaliGiPageState extends State<DataAnomaliGiPage> {
  late String _currentProgress;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.initialProgress;
    _fetch();
  }

  String get _draftKey =>
      '${widget.anomaliData.assetNama}-${widget.garduIndukNama}';

  void _fetch() {
    context.read<OpgiAnomaliCubit>().loadKondisiHistory(
          widget.anomaliId,
          draftKey: _draftKey,
        );
  }

  bool get _isDone => _currentProgress.toUpperCase() == 'SELESAI';

  void _showImageDialog(String fullUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  fullUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(24),
                    color: Colors.white,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Gagal memuat foto'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteKondisi(AnomaliKondisiModel kondisi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Peringatan'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus data kondisi anomali ini?',
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
              context.read<OpgiAnomaliCubit>().deleteAnomaliKondisi(
                    kondisi.id,
                    widget.anomaliId,
                    draftKey: _draftKey,
                  );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.anomaliData;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Anomali - ${info.assetNama}'),
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

            final conditions = state is OpgiAnomaliKondisiLoaded
                ? state.conditions
                : <AnomaliKondisiModel>[];
            final drafts = state is OpgiAnomaliKondisiLoaded
                ? state.localDrafts
                : <Map<String, dynamic>>[];
            final hasDraft = drafts.isNotEmpty;

            // Update current progress from latest condition if available
            if (conditions.isNotEmpty) {
              _currentProgress = conditions.first.tindakan;
            }

            return RefreshIndicator(
              onRefresh: () async => _fetch(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. Info Card
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
                            ),
                          ),
                        ),
                        InputWithLabel(
                          label: 'Jenis Asset',
                          child: Text(info.jenisAsset),
                        ),
                        InputWithLabel(
                          label: 'Asset',
                          child: Text(info.assetNama),
                        ),
                        InputWithLabel(
                          label: 'Entitas',
                          child: Text(info.entitas),
                        ),
                        InputWithLabel(
                          label: 'Operator',
                          child: Text(info.namaPetugas ?? '-'),
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(
                                    color: _isDone
                                        ? Colors.grey
                                        : AppTheme.primary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _isDone
                                    ? null
                                    : () async {
                                        await context.push(
                                          AppRoutes.inputKondisiAnomaliGi,
                                          extra: {
                                            'anomaliId': widget.anomaliId,
                                            'garduInduk': widget.garduIndukNama,
                                            'garduIndukId': widget.garduIndukId,
                                            'data': info,
                                            'assetNama': info.assetNama,
                                          },
                                        );
                                        _fetch();
                                      },
                                child: Text(
                                  'Tambah Kondisi Anomali',
                                  style: TextStyle(
                                    color: _isDone
                                        ? Colors.grey
                                        : AppTheme.primary,
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

                  // 2. Daftar Riwayat Kondisi
                  if (conditions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: const Text(
                        'Belum ada data riwayat kondisi anomali',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    ...conditions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isLast = index == 0;
                      final formattedDate = AppTimeUtils.formatDateTime(
                        item.createdAt,
                        pattern: 'EEEE, d MMMM yyyy HH:mm',
                      );

                      final fullPhotoUrl =
                          AppUrlUtils.resolveMediaUrl(item.fotoBuktiUrl);
                      final fullVideoUrl =
                          AppUrlUtils.resolveMediaUrl(item.videoBuktiUrl);

                      return InputContainer(
                        label: formattedDate,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InputWithLabel(
                              label: 'Urgensi',
                              child: Text(
                                item.urgensi,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InputWithLabel(
                              label: 'Tindakan',
                              child: Text(
                                item.tindakan,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            InputWithLabel(
                              label: 'Keterangan',
                              child: Text(item.keterangan),
                            ),
                            InputWithLabel(
                              label: 'Foto Bukti',
                              child: fullPhotoUrl != null &&
                                      fullPhotoUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: InkWell(
                                        onTap: () =>
                                            _showImageDialog(fullPhotoUrl),
                                        child: Image.network(
                                          fullPhotoUrl,
                                          height: 180,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) =>
                                              Container(
                                            height: 100,
                                            alignment: Alignment.center,
                                            color: Colors.grey.shade100,
                                            child: const Text(
                                                'Foto tidak dapat dimuat'),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'Foto tidak tersedia',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                            ),
                            InputWithLabel(
                              label: 'Vidio Bukti',
                              child: fullVideoUrl != null &&
                                      fullVideoUrl.isNotEmpty
                                  ? AppVideoPlayer(
                                      videoUrl: fullVideoUrl,
                                      height: 220,
                                      autoPlay: false,
                                      looping: true,
                                      startMuted: true,
                                    )
                                  : const Text(
                                      'Vidio tidak ditemukan',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      side: BorderSide(
                                        color: _isDone
                                            ? Colors.grey
                                            : AppTheme.primary,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: _isDone
                                        ? null
                                        : () async {
                                            await context.push(
                                              AppRoutes.updateKondisiAnomaliGi,
                                              extra: {
                                                'anomali': info,
                                                'kondisi': item.copyWith(
                                                    isLast: isLast),
                                                'garduInduk':
                                                    widget.garduIndukNama,
                                                'garduIndukId':
                                                    widget.garduIndukId,
                                                'isLast': isLast,
                                              },
                                            );
                                            _fetch();
                                          },
                                    child: Text(
                                      'Update',
                                      style: TextStyle(
                                        color: _isDone
                                            ? Colors.grey
                                            : AppTheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  style: IconButton.styleFrom(
                                    backgroundColor: _isDone
                                        ? Colors.grey.shade200
                                        : AppColors.danger
                                            .withValues(alpha: 0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.delete,
                                    color: _isDone
                                        ? Colors.grey
                                        : AppColors.danger,
                                    size: 20,
                                  ),
                                  onPressed: _isDone
                                      ? null
                                      : () => _confirmDeleteKondisi(item),
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
