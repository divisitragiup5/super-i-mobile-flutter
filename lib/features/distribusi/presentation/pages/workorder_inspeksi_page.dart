import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/wo_inspeksi_cubit.dart';

class WorkorderInspeksiPage extends StatefulWidget {
  const WorkorderInspeksiPage({super.key});

  @override
  State<WorkorderInspeksiPage> createState() => _WorkorderInspeksiPageState();
}

class _WorkorderInspeksiPageState extends State<WorkorderInspeksiPage> {
  late String _today;

  @override
  void initState() {
    super.initState();
    _today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    context.read<WoInspeksiCubit>().fetchToday(_today);
  }

  Color _getStatusBgColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return Colors.blue.shade50;
      case 'ON_PROGRESS':
      case 'ON PROGRESS':
        return Colors.amber.shade50;
      case 'COMPLETED':
      case 'SELESAI':
        return Colors.green.shade50;
      case 'REJECTED':
        return Colors.red.shade50;
      case 'WAITING_APPROVAL':
        return Colors.purple.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return Colors.blue.shade700;
      case 'ON_PROGRESS':
      case 'ON PROGRESS':
        return Colors.amber.shade800;
      case 'COMPLETED':
      case 'SELESAI':
        return Colors.green.shade700;
      case 'REJECTED':
        return Colors.red.shade700;
      case 'WAITING_APPROVAL':
        return Colors.purple.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workorder Inspeksi'),
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
          RefreshIndicator(
            onRefresh: () async {
              await context.read<WoInspeksiCubit>().fetchToday(_today);
            },
            child: BlocBuilder<WoInspeksiCubit, WoInspeksiState>(
              builder: (context, state) {
                if (state is WoInspeksiLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is WoInspeksiError) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 48),
                          const SizedBox(height: 12),
                          Text(state.message, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context
                                .read<WoInspeksiCubit>()
                                .fetchToday(_today),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final items = state is WoInspeksiLoaded
                    ? state.todayWorkOrders
                    : [];

                if (items.isEmpty) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'Tidak ada penugasan hari ini',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            context.push(
                              AppRoutes.detailWorkorderToday,
                              extra: item,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'WORK ORDER ID',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          'WO-${item.id}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
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
                                        color: _getStatusBgColor(item.status),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: _getStatusTextColor(
                                                  item.status),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            item.status,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: _getStatusTextColor(
                                                  item.status),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Jumlah SUTM',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          '${item.totalSutm} Item',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Belum Diinspeksi',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          '${item.pendingCount} Item',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (item.startDate != null) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 13, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${item.startDate?.split('T').first ?? '-'} s/d ${item.endDate?.split('T').first ?? '-'}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
