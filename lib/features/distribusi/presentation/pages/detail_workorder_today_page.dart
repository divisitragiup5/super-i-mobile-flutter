import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/storage/local_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/google_sutm_map_card.dart';
import '../../data/models/sutm_workorder_model.dart';
import '../cubit/wo_inspeksi_cubit.dart';

class DetailWorkorderTodayPage extends StatefulWidget {
  final SutmWorkOrderItem workOrder;

  const DetailWorkorderTodayPage({
    super.key,
    required this.workOrder,
  });

  @override
  State<DetailWorkorderTodayPage> createState() =>
      _DetailWorkorderTodayPageState();
}

class _DetailWorkorderTodayPageState extends State<DetailWorkorderTodayPage> {
  late SutmWorkOrderItem _currentWO;
  Set<String> _draftKeys = {};

  @override
  void initState() {
    super.initState();
    _currentWO = widget.workOrder;
    _checkDrafts();
  }

  Future<void> _checkDrafts() async {
    final drafts = await LocalDatabase.instance.getAllSutmDrafts();
    if (mounted) {
      setState(() {
        _draftKeys = drafts
            .map((d) => d['work_order_sutm_item_id'].toString())
            .toSet();
      });
    }
  }

  void _showRejectDialog(SutmItemModel item) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reject ${item.nama}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan alasan penolakan SUTM ini:',
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
              final success = await context.read<WoInspeksiCubit>().rejectSutm(
                    workOrderId: _currentWO.id.toString(),
                    itemIds: [item.id],
                    reason: reason.isNotEmpty ? reason : null,
                  );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('SUTM berhasil ditolak')),
                );
                setState(() {
                  _currentWO = SutmWorkOrderItem(
                    id: _currentWO.id,
                    status: _currentWO.status,
                    startDate: _currentWO.startDate,
                    endDate: _currentWO.endDate,
                    totalSutm: _currentWO.totalSutm,
                    pendingCount: _currentWO.pendingCount > 0
                        ? _currentWO.pendingCount - 1
                        : 0,
                    items: _currentWO.items
                        .where((i) => i.id != item.id)
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

  @override
  Widget build(BuildContext context) {
    final sutmItems = _currentWO.items
        .where((i) => i.latitude != null && i.longitude != null)
        .map((i) => SutmMapItem(
              idAsset: i.idAsset,
              name: i.nama,
              latitude: i.latitude,
              longitude: i.longitude,
              color: i.status == 'COMPLETED'
                  ? AppColors.success
                  : AppColors.primary,
              rawData: i,
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail WO #${_currentWO.id}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'WORK ORDER ID',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                'WO-${_currentWO.id}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
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
                          Text(
                            'Total SUTM: ${_currentWO.items.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          if (_draftKeys.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_draftKeys.length} Draft Tersimpan',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Map View Card
                if (sutmItems.isNotEmpty) ...[
                  GoogleSutmMapCard(
                    items: sutmItems,
                    height: 250,
                  ),
                  const SizedBox(height: 16),
                ],

                // SUTM List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Tiang SUTM',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_currentWO.items.length} Item',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // SUTM Cards
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _currentWO.items.length,
                  itemBuilder: (context, index) {
                    final item = _currentWO.items[index];
                    final hasDraft = _draftKeys.contains(item.id.toString());
                    final displayStatus = hasDraft ? 'Draft' : item.status;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            await context.push(
                              AppRoutes.detailSutm,
                              extra: {
                                'workOrderSutmItemId': item.id.toString(),
                                'sutmId': item.sutmId.toString(),
                                'idAsset': item.idAsset,
                                'nama': item.nama,
                                'feederName': item.feeder?.nama ?? '-',
                                'latitude': item.latitude?.toString() ?? '',
                                'longitude': item.longitude?.toString() ?? '',
                                'workOrderId': _currentWO.id.toString(),
                                'status': item.status,
                              },
                            );
                            _checkDrafts();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.idAsset,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.nama,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      if (item.feeder != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          item.feeder!.nama,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
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
                                    color: hasDraft
                                        ? Colors.amber.shade50
                                        : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    displayStatus,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: hasDraft
                                          ? Colors.amber.shade800
                                          : Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert,
                                      color: Colors.grey),
                                  onSelected: (val) {
                                    if (val == 'reject') {
                                      _showRejectDialog(item);
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
                                          Text('Reject SUTM',
                                              style: TextStyle(
                                                  color: AppColors.error)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
