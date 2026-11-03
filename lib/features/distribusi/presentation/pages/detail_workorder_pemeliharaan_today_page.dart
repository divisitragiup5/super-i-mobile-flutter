import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    _currentWO = widget.workOrder;
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
            const Text('Masukkan alasan penolakan pemeliharaan SUTM ini:'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pemeliharaan #${_currentWO.id}'),
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
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
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
                    const SizedBox(height: 8),
                    Text(
                      'Total SUTM: ${_currentWO.items.length} Item',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Daftar Tiang Target Pemeliharaan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              ..._currentWO.items.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
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
                                          style:
                                              TextStyle(color: AppColors.error)),
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
        ],
      ),
    );
  }
}
