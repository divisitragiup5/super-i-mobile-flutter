import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/wo_pemeliharaan_cubit.dart';

class WorkorderPemeliharaanPage extends StatefulWidget {
  const WorkorderPemeliharaanPage({super.key});

  @override
  State<WorkorderPemeliharaanPage> createState() =>
      _WorkorderPemeliharaanPageState();
}

class _WorkorderPemeliharaanPageState extends State<WorkorderPemeliharaanPage> {
  late String _today;

  @override
  void initState() {
    super.initState();
    _today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    context.read<WoPemeliharaanCubit>().fetchToday(_today);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workorder Pemeliharaan'),
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
              await context.read<WoPemeliharaanCubit>().fetchToday(_today);
            },
            child: BlocBuilder<WoPemeliharaanCubit, WoPemeliharaanState>(
              builder: (context, state) {
                if (state is WoPemeliharaanLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is WoPemeliharaanError) {
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
                                .read<WoPemeliharaanCubit>()
                                .fetchToday(_today),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final items = state is WoPemeliharaanLoaded
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
                            'Tidak ada penugasan pemeliharaan hari ini',
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
                              AppRoutes.detailWorkorderPemeliharaanToday,
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
                                        color: Colors.blue.shade50,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        item.status,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade700,
                                        ),
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
                                          'Belum Dikerjakan',
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
