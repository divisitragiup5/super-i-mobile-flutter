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

class DataBebanTrafoPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const DataBebanTrafoPage({
    super.key,
    required this.params,
  });

  @override
  State<DataBebanTrafoPage> createState() => _DataBebanTrafoPageState();
}

class _DataBebanTrafoPageState extends State<DataBebanTrafoPage> {
  late int _trafoId;
  late String _trafoNama;
  late double _iMax;
  late String _garduIndukNama;
  late int _garduIndukId;

  @override
  void initState() {
    super.initState();
    final p = widget.params;
    _trafoId = p['id'] is int ? p['id'] as int : int.tryParse('${p['id']}') ?? 0;
    _trafoNama = p['nama']?.toString() ?? '-';
    _iMax = (p['iMax'] as num?)?.toDouble() ?? 0.0;
    _garduIndukNama = p['garduInduk']?.toString() ?? '-';
    _garduIndukId = p['garduIndukId'] is int
        ? p['garduIndukId'] as int
        : int.tryParse('${p['garduIndukId']}') ?? 0;

    _fetch();
  }

  void _fetch({bool forceRefresh = false}) {
    context.read<OpgiRealisasiCubit>().loadBebanTrafoToday(
          _trafoId,
          _garduIndukId,
          forceRefresh: forceRefresh,
        );
  }

  void _confirmDelete(BebanTrafoTodayItemModel item) {
    final periodeStr = item.periode.toString().padLeft(2, '0');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Peringatan'),
        content: Text('Apakah Anda yakin ingin menghapus data periode: $periodeStr?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              minimumSize: const Size(64, 36),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OpgiRealisasiCubit>().deleteBebanTrafo(item.id);
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
        title: Text('Data Beban - $_trafoNama'),
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
            final todayList = state is BebanTrafoTodayLoaded
                ? state.items
                : cubit.cachedBebanTrafoTodayList;

            return RefreshIndicator(
              onRefresh: () async => _fetch(forceRefresh: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // Info Card
                  InputContainer(
                    label: 'INFO',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Gardu Induk', _garduIndukNama),
                        const SizedBox(height: 8),
                        _buildInfoRow('Trafo', _trafoNama),
                        const SizedBox(height: 8),
                        _buildInfoRow('iMax', '${_iMax.toStringAsFixed(_iMax.truncateToDouble() == _iMax ? 0 : 1)} A'),
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
                      final beforeItem = index > 0 ? todayList[index - 1] : null;
                      final periodeFormatted = item.periode.toString().padLeft(2, '0');
                      final dateFormatted = item.createdAt != null
                          ? DateFormat('dd MMMM yyyy, HH:mm').format(item.createdAt!)
                          : '-';
                      final fullPhotoUrl = AppUrlUtils.getFullImageUrl(item.foto?['uri']?.toString());

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
                            // Periode & Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Periode: $periodeFormatted',
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

                            // Nilai Beban
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
                                children: [
                                  const TextSpan(text: 'Beban: '),
                                  TextSpan(
                                    text: '${item.beban} A',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Foto Preview
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
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image, color: Colors.grey, size: 36),
                                          SizedBox(height: 4),
                                          Text('Foto tidak dapat dimuat', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
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

                            // Action buttons
                            Row(
                              children: [
                                Expanded(
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
                                        AppRoutes.updateBebanTrafo,
                                        extra: {
                                          'id': _trafoId,
                                          'nama': _trafoNama,
                                          'iMax': _iMax,
                                          'garduInduk': _garduIndukNama,
                                          'garduIndukId': _garduIndukId,
                                          'periode': item.periode,
                                          'bebanId': item.id,
                                          'beforeItem': beforeItem?.toJson(),
                                        },
                                      );
                                      _fetch();
                                    },
                                    child: const Text('Update'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 40,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.danger,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () => _confirmDelete(item),
                                    child: const Icon(Icons.delete_outline, size: 20),
                                  ),
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
