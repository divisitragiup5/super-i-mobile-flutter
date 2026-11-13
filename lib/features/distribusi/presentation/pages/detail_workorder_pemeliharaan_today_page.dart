import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/google_sutm_map_card.dart';
import '../../data/models/sutm_workorder_model.dart';
import '../cubit/wo_pemeliharaan_cubit.dart';

class DetailWorkorderPemeliharaanTodayPage extends StatefulWidget {
  final SutmWorkOrderItem workOrder;

  const DetailWorkorderPemeliharaanTodayPage({
    super.key,
    required this.workOrder,
  });

  @override
  State<DetailWorkorderPemeliharaanTodayPage> createState() =>
      _DetailWorkorderPemeliharaanTodayPageState();
}

class _DetailWorkorderPemeliharaanTodayPageState
    extends State<DetailWorkorderPemeliharaanTodayPage> {
  late SutmWorkOrderItem _currentWO;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _currentWO = widget.workOrder;
  }

  void _showRejectDialog({required List<int> itemIds, String? title}) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title ?? 'Tolak ${itemIds.length} SUTM'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan alasan penolakan pemeliharaan SUTM ini:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Alasan penolakan...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final reason = reasonController.text.trim();
              Navigator.pop(ctx);
              final success =
                  await context.read<WoPemeliharaanCubit>().rejectSutm(
                        workOrderId: _currentWO.id,
                        itemIds: itemIds,
                        reason: reason.isNotEmpty ? reason : null,
                      );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${itemIds.length} SUTM berhasil ditolak'),
                    backgroundColor: AppColors.success,
                  ),
                );
                setState(() {
                  final idSet = itemIds.toSet();
                  _selectedIds.removeAll(idSet);
                  _currentWO = SutmWorkOrderItem(
                    id: _currentWO.id,
                    status: _currentWO.status,
                    startDate: _currentWO.startDate,
                    endDate: _currentWO.endDate,
                    totalSutm: _currentWO.totalSutm,
                    pendingCount: _currentWO.pendingCount > itemIds.length
                        ? _currentWO.pendingCount - itemIds.length
                        : 0,
                    items: _currentWO.items
                        .where((i) => !idSet.contains(i.id))
                        .toList(),
                  );
                });
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    final parsed = DateTime.tryParse(dateStr);
    if (parsed == null) return dateStr;
    return DateFormat('d MMM yyyy', 'id_ID').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final mapItems = _currentWO.items
        .where((i) => i.latitude != null && i.longitude != null)
        .map((i) => SutmMapItem(
              idAsset: i.idAsset,
              name: i.nama,
              latitude: i.latitude,
              longitude: i.longitude,
              color: const Color(0xFFEF4444),
              rawData: i,
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail WO #${_currentWO.id}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_currentWO.items.isNotEmpty)
            IconButton(
              icon: Icon(
                _selectedIds.length == _currentWO.items.length
                    ? Icons.select_all
                    : Icons.check_box_outline_blank,
              ),
              tooltip: 'Pilih Semua',
              onPressed: () {
                setState(() {
                  if (_selectedIds.length == _currentWO.items.length) {
                    _selectedIds.clear();
                  } else {
                    _selectedIds.addAll(_currentWO.items.map((i) => i.id));
                  }
                });
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: AppColors.backgroundLight),
            ),
          ),
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'WO-${_currentWO.id}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _currentWO.status,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total SUTM',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '${_currentWO.items.length} Item',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Periode',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '${_formatDate(_currentWO.startDate)} - ${_formatDate(_currentWO.endDate)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Map Section (Google Maps)
              if (mapItems.isNotEmpty) ...[
                GoogleSutmMapCard(
                  items: mapItems,
                  height: 200,
                ),
                const SizedBox(height: 16),
              ],

              // Header Daftar SUTM
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Tiang Target Pemeliharaan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${_currentWO.items.length} Item',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Daftar SUTM Cards
              ..._currentWO.items.map((item) {
                final isSelected = _selectedIds.contains(item.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(color: AppColors.error, width: 2)
                        : null,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedIds.add(item.id);
                                  } else {
                                    _selectedIds.remove(item.id);
                                  }
                                });
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.idAsset,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    item.nama,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.grey),
                              onSelected: (val) {
                                if (val == 'reject') {
                                  _showRejectDialog(
                                    itemIds: [item.id],
                                    title: 'Reject ${item.nama}',
                                  );
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(
                                  value: 'reject',
                                  child: Row(
                                    children: [
                                      Icon(Icons.cancel_outlined,
                                          color: AppColors.error, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Reject SUTM',
                                        style: TextStyle(color: AppColors.error),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Rencana Target Badges
                        if (item.rencana.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'KOMPONEN TARGET:',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...item.rencana.map(
                                  (r) => Text(
                                    '• ${r.sub} - ${r.komponen} ${r.fasa != null ? "(Fasa ${r.fasa})" : ""}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.build, size: 16),
                            label: const Text('Kerjakan Pemeliharaan'),
                            onPressed: () {
                              context.push(
                                AppRoutes.inspeksiPemeliharaanForm,
                                extra: {
                                  'workOrderId': _currentWO.id.toString(),
                                  'workOrderSutmItemId': item.id.toString(),
                                  'sutmId': item.sutmId.toString(),
                                  'idAsset': item.idAsset,
                                  'nama': item.nama,
                                  'rencana': item.rencana,
                                  'inspeksiTerakhir': item.lastInspeksi?.toJson(),
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),

          // Bottom Bar for Batch Rejection
          if (_selectedIds.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedIds.length} SUTM Dipilih',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Reject Terpilih'),
                      onPressed: () {
                        _showRejectDialog(
                          itemIds: _selectedIds.toList(),
                          title: 'Reject ${_selectedIds.length} SUTM Terpilih',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
