import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_url_utils.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/input_container.dart';
import '../../data/models/opgi_realisasi_model.dart';
import '../cubit/opgi_realisasi_cubit.dart';

class DataKwhHarianPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const DataKwhHarianPage({
    super.key,
    required this.params,
  });

  @override
  State<DataKwhHarianPage> createState() => _DataKwhHarianPageState();
}

class _DataKwhHarianPageState extends State<DataKwhHarianPage> {
  late int _objectId;
  late String _nama;
  late String _type;
  late String _kelompok;
  late String _garduIndukNama;
  late int _garduIndukId;

  @override
  void initState() {
    super.initState();
    final p = widget.params;
    _objectId = p['id'] is int ? p['id'] as int : int.tryParse('${p['id']}') ?? 0;
    _nama = p['nama']?.toString() ?? '-';
    _type = p['type']?.toString() ?? 'PENYULANG';
    _kelompok = p['kelompok']?.toString() ?? 'FEEDER';
    _garduIndukNama = p['garduInduk']?.toString() ?? '-';
    _garduIndukId = p['garduIndukId'] is int
        ? p['garduIndukId'] as int
        : int.tryParse('${p['garduIndukId']}') ?? 0;

    _fetch();
  }

  void _fetch({bool forceRefresh = false}) {
    context.read<OpgiRealisasiCubit>().loadKwhHarianToday(
          _objectId,
          type: _type,
          kelompok: _kelompok,
          forceRefresh: forceRefresh,
        );
  }

  void _confirmDeleteAll(List<KwhHarianTodayItemModel> items) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Peringatan'),
        content: Text('Apakah Anda yakin ingin menghapus data Kwh Harian $_nama?'),
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
              final ids = items.map((i) => i.id).toList();
              context.read<OpgiRealisasiCubit>().deleteKwhHarianToday(
                    ids: ids,
                    objectId: _objectId,
                    type: _type,
                    kelompok: _kelompok,
                  );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(String imageUrl) {
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
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(24),
                    color: Colors.white,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Gagal memuat gambar', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    switch (status.toUpperCase()) {
      case 'ON TIME':
        bg = const Color(0xFFDCFCE7); // green-100
        fg = const Color(0xFF15803D); // green-700
        break;
      case 'PERHATIAN':
        bg = const Color(0xFFFEF9C3); // yellow-100
        fg = const Color(0xFFA16207); // yellow-700
        break;
      case 'TERLAMBAT':
      default:
        bg = const Color(0xFFFEE2E2); // red-100
        fg = const Color(0xFFB91C1C); // red-700
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data kWh - $_nama'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: () => _fetch(forceRefresh: true),
          ),
        ],
      ),
      body: AppBackground(
        child: BlocConsumer<OpgiRealisasiCubit, OpgiRealisasiState>(
          listener: (context, state) {
            if (state is OpgiRealisasiSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              final cubit = context.read<OpgiRealisasiCubit>();
              if (cubit.cachedKwhHarianTodayList.isEmpty && mounted) {
                Navigator.of(context).pop();
              }
            } else if (state is OpgiRealisasiError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.danger,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<OpgiRealisasiCubit>();
            final todayList = state is KwhHarianTodayLoaded
                ? state.items
                : cubit.cachedKwhHarianTodayList;

            return RefreshIndicator(
              onRefresh: () async => _fetch(forceRefresh: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // Info Card with Delete All button
                  InputContainer(
                    label: 'INFO',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Gardu Induk', _garduIndukNama),
                        const SizedBox(height: 8),
                        _buildInfoRow('Kelompok', _kelompok),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFFFCA5A5),
                              disabledForegroundColor: Colors.white70,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            onPressed: todayList.isEmpty ? null : () => _confirmDeleteAll(todayList),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete_outline, size: 20),
                                SizedBox(width: 6),
                                Text('Hapus Semua Data Hari Ini', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (state is OpgiRealisasiLoading && todayList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (todayList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'Belum ada data realisasi hari ini',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                        ),
                      ),
                    )
                  else
                    ...List.generate(todayList.length, (index) {
                      final item = todayList[index];
                      final dateFormatted = item.createdAt != null
                          ? DateFormat('dd MMMM yyyy, HH:mm').format(item.createdAt!)
                          : '-';
                      final fullPhotoUrl = AppUrlUtils.getFullImageUrl(item.fotoStand?['uri']?.toString());

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Jenis & Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Jenis: ${item.jenis}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      dateFormatted,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                                _buildStatusBadge(item.status),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Stand
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
                                children: [
                                  const TextSpan(text: 'Stand: '),
                                  TextSpan(
                                    text: '${item.stand}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            if (item.keterangan != null && item.keterangan!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Keterangan: ${item.keterangan}',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                              ),
                            ],
                            const SizedBox(height: 12),

                            // Foto
                            const Text(
                              'Foto:',
                              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 6),
                            if (fullPhotoUrl.isNotEmpty)
                              GestureDetector(
                                onTap: () => _showImagePreview(fullPhotoUrl),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    fullPhotoUrl,
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 120,
                                      color: const Color(0xFFF1F5F9),
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.broken_image, color: Colors.grey, size: 36),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: const Text('Tidak ada foto', style: TextStyle(color: Colors.grey)),
                              ),

                            const SizedBox(height: 14),

                            // Update button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  await context.push(
                                    AppRoutes.updateKwhHarian,
                                    extra: {
                                      'id': item.id,
                                      'nama': _nama,
                                      'type': _type,
                                      'kelompok': _kelompok,
                                      'garduInduk': _garduIndukNama,
                                      'garduIndukId': _garduIndukId,
                                      'item': item.toJson(),
                                    },
                                  );
                                  _fetch();
                                },
                                child: const Text('Update'),
                              ),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(color: Color(0xFF64748B))),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}
