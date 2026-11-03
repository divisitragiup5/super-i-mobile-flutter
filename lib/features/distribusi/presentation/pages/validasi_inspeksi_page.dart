import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/validasi_inspeksi_cubit.dart';

class ValidasiInspeksiPage extends StatefulWidget {
  const ValidasiInspeksiPage({super.key});

  @override
  State<ValidasiInspeksiPage> createState() => _ValidasiInspeksiPageState();
}

class _ValidasiInspeksiPageState extends State<ValidasiInspeksiPage> {
  @override
  void initState() {
    super.initState();
    context.read<ValidasiInspeksiCubit>().loadValidasiData();
  }

  void _showRejectDialog({
    required BuildContext context,
    required bool isBulk,
    int? singleId,
  }) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isBulk ? 'Reject Massal Inspeksi' : 'Reject Inspeksi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan alasan penolakan hasil inspeksi:',
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
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alasan penolakan wajib diisi')),
                );
                return;
              }
              Navigator.pop(ctx);
              if (isBulk) {
                await context.read<ValidasiInspeksiCubit>().rejectBulk(
                      role: 'koordinator',
                      reason: reason,
                    );
              } else if (singleId != null) {
                await context.read<ValidasiInspeksiCubit>().rejectSingle(
                      role: 'koordinator',
                      id: singleId,
                      reason: reason,
                    );
              }
            },
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validasi Inspeksi'),
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
          BlocConsumer<ValidasiInspeksiCubit, ValidasiInspeksiState>(
            listener: (context, state) {
              if (state is ValidasiInspeksiError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is ValidasiInspeksiLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final loaded = state is ValidasiInspeksiLoaded ? state : null;
              final activeTab = loaded?.activeTab ?? 'workorder';
              final workOrders = loaded?.workOrders ?? [];
              final sutmItems = loaded?.sutmItems ?? [];
              final selectedIds = loaded?.selectedSutmIds ?? [];

              return Column(
                children: [
                  // Tab Switcher
                  Container(
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => context
                                .read<ValidasiInspeksiCubit>()
                                .switchTab('workorder'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: activeTab == 'workorder'
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Work Order (${workOrders.length})',
                                  style: TextStyle(
                                    fontWeight: activeTab == 'workorder'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: activeTab == 'workorder'
                                        ? AppColors.primary
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => context
                                .read<ValidasiInspeksiCubit>()
                                .switchTab('sutm'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: activeTab == 'sutm'
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'SUTM (${sutmItems.length})',
                                  style: TextStyle(
                                    fontWeight: activeTab == 'sutm'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: activeTab == 'sutm'
                                        ? AppColors.primary
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bulk Action Bar if items selected
                  if (activeTab == 'sutm' && selectedIds.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      color: Colors.amber.shade100,
                      child: Row(
                        children: [
                          Text(
                            '${selectedIds.length} SUTM Dipilih',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context
                                .read<ValidasiInspeksiCubit>()
                                .approveBulk(role: 'koordinator'),
                            child: const Text('Approve Semua',
                                style: TextStyle(color: AppColors.success)),
                          ),
                          TextButton(
                            onPressed: () => _showRejectDialog(
                              context: context,
                              isBulk: true,
                            ),
                            child: const Text('Reject Semua',
                                style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    ),

                  // Content List
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await context
                            .read<ValidasiInspeksiCubit>()
                            .loadValidasiData();
                      },
                      child: activeTab == 'workorder'
                          ? _buildWorkOrderList(workOrders)
                          : _buildSutmList(sutmItems, selectedIds),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkOrderList(List<dynamic> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Tidak ada Work Order yang memerlukan validasi',
            style: TextStyle(color: Colors.white)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              'WO #${item.id}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Jumlah SUTM: ${item.totalSutm} Item'),
                Text('Status: ${item.status}'),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
            onTap: () {
              context.push(
                AppRoutes.validasiDetailWorkorder,
                extra: item,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSutmList(List<dynamic> items, List<int> selectedIds) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Tidak ada item SUTM yang memerlukan validasi',
            style: TextStyle(color: Colors.white)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final inspId = int.tryParse(item.inspectionId ?? '0') ?? 0;
        final isSelected = selectedIds.contains(inspId);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                if (item.canValidasi && inspId > 0)
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) {
                      context
                          .read<ValidasiInspeksiCubit>()
                          .toggleSelectSutm(inspId);
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
                      const SizedBox(height: 2),
                      Text(
                        item.nama,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${item.status}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.canValidasi && inspId > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle,
                            color: AppColors.success),
                        onPressed: () => context
                            .read<ValidasiInspeksiCubit>()
                            .approveSingle(role: 'koordinator', id: inspId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: AppColors.error),
                        onPressed: () => _showRejectDialog(
                          context: context,
                          isBulk: false,
                          singleId: inspId,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
