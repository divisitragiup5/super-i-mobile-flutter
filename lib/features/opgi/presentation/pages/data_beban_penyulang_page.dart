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

class DataBebanPenyulangPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const DataBebanPenyulangPage({
    super.key,
    required this.params,
  });

  @override
  State<DataBebanPenyulangPage> createState() => _DataBebanPenyulangPageState();
}

class _DataBebanPenyulangPageState extends State<DataBebanPenyulangPage> {
  late int _penyulangId;
  late String _penyulangNama;
  late double _iMax;
  late String _rel;
  late String _statusCB;
  late String _garduIndukNama;
  late int _garduIndukId;

  @override
  void initState() {
    super.initState();
    final p = widget.params;
    _penyulangId = p['id'] is int ? p['id'] as int : int.tryParse('${p['id']}') ?? 0;
    _penyulangNama = p['nama']?.toString() ?? '-';
    _iMax = (p['iMax'] as num?)?.toDouble() ?? 0.0;
    _rel = p['rel']?.toString() ?? '-';
    _statusCB = p['statusCB']?.toString() ?? 'ON';
    _garduIndukNama = p['garduInduk']?.toString() ?? '-';
    _garduIndukId = p['garduIndukId'] is int
        ? p['garduIndukId'] as int
        : int.tryParse('${p['garduIndukId']}') ?? 0;

    _fetch();
  }

  void _fetch({bool forceRefresh = false}) {
    context.read<OpgiRealisasiCubit>().loadBebanPenyulangToday(
          _penyulangId,
          _garduIndukId,
          forceRefresh: forceRefresh,
        );
  }

  void _confirmDelete(BebanPenyulangTodayItemModel item) {
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
              context.read<OpgiRealisasiCubit>().deleteBebanPenyulang(item.id);
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
                        Text('Gagal memuat gambar preview'),
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
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ON TIME':
        return const Color(0xFF22C55E); // Green-500
      case 'PERHATIAN':
        return const Color(0xFFEAB308); // Yellow-500
      case 'TERLAMBAT':
      default:
        return const Color(0xFFEF4444); // Red-500
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Beban - $_penyulangNama'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
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
            final items = state is BebanPenyulangTodayLoaded
                ? state.items
                : cubit.cachedBebanPenyulangTodayList;

            if (state is OpgiRealisasiLoading && items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async => _fetch(forceRefresh: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // Card Header: INFO
                  InputContainer(
                    label: 'INFO',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InputWithLabel(
                          label: 'Gardu Induk',
                          child: Text(_garduIndukNama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                        InputWithLabel(
                          label: 'Rel',
                          child: Text(_rel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                        InputWithLabel(
                          label: 'IMax',
                          child: Text('$_iMax', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                        InputWithLabel(
                          label: 'Status CB',
                          margin: EdgeInsets.zero,
                          child: Text(
                            _statusCB,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: _statusCB.toUpperCase() == 'ON' ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (items.isEmpty) ...[
                    const SizedBox(height: 32),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          const Text(
                            'Belum ada data beban hari ini untuk penyulang ini',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ...List.generate(items.length, (index) {
                      final item = items[index];
                      final beforeItem = index > 0 ? items[index - 1] : null;
                      final periodeStr = item.periode.toString().padLeft(2, '0');
                      final dateStr = item.createdAt != null
                          ? DateFormat('dd MMMM yyyy, HH:mm').format(item.createdAt!)
                          : '-';

                      final fotoData = item.foto;
                      final fotoUri = fotoData?['uri']?.toString();
                      final fullImageUrl = fotoUri != null ? AppUrlUtils.getFullImageUrl(fotoUri) : null;
                      final statusColor = _getStatusColor(item.status);

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
                            // Periode & Status Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Periode: $periodeStr',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      dateStr,
                                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: statusColor, width: 1.2),
                                  ),
                                  child: Text(
                                    item.status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Beban
                            Text(
                              'Beban: ${item.beban}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10),

                            // Foto Thumbnail
                            const Text(
                              'Foto:',
                              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 6),
                            if (fullImageUrl != null)
                              GestureDetector(
                                onTap: () => _showImagePreview(fullImageUrl),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    fullImageUrl,
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 100,
                                      color: Colors.grey.shade200,
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                height: 80,
                                color: Colors.grey.shade100,
                                alignment: Alignment.center,
                                child: const Text('Tidak ada foto', style: TextStyle(color: Colors.grey)),
                              ),

                            const SizedBox(height: 14),
                            // Action Buttons: Update & Delete
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(color: AppColors.primary, width: 1.2),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    onPressed: () async {
                                      await context.push(
                                        AppRoutes.updateBebanPenyulang,
                                        extra: {
                                          'id': _penyulangId,
                                          'nama': _penyulangNama,
                                          'iMax': _iMax,
                                          'rel': _rel,
                                          'garduInduk': _garduIndukNama,
                                          'periode': item.periode,
                                          'bebanId': item.id,
                                          'garduIndukId': _garduIndukId,
                                          'beforeItem': beforeItem?.toJson(),
                                        },
                                      );
                                      _fetch();
                                    },
                                    child: const Text('Update', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.danger,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(44, 40),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                  onPressed: () => _confirmDelete(item),
                                  child: const Icon(Icons.delete_outline, size: 20),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
