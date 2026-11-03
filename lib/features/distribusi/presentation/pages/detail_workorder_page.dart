import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/wo_inspeksi_cubit.dart';

class DetailWorkorderPage extends StatefulWidget {
  final String workOrderId;
  final String? title;

  const DetailWorkorderPage({
    super.key,
    required this.workOrderId,
    this.title,
  });

  @override
  State<DetailWorkorderPage> createState() => _DetailWorkorderPageState();
}

class _DetailWorkorderPageState extends State<DetailWorkorderPage> {
  @override
  void initState() {
    super.initState();
    context.read<WoInspeksiCubit>().fetchDetail(widget.workOrderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Detail Work Order'),
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
          BlocBuilder<WoInspeksiCubit, WoInspeksiState>(
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
                              .fetchDetail(widget.workOrderId),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final wo = state is WoInspeksiLoaded
                  ? state.detailWorkOrder
                  : null;

              if (wo == null) {
                return const Center(
                  child: Text('Data work order tidak ditemukan'),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Work Order #${wo.id}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${wo.status}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total SUTM: ${wo.items.length}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Daftar Tiang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...wo.items.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(item.nama,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item.idAsset} • ${item.feeder?.nama ?? "-"}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                        onTap: () {
                          context.push(
                            AppRoutes.detailSutm,
                            extra: {
                              'workOrderSutmItemId': item.id.toString(),
                              'sutmId': item.sutmId.toString(),
                              'idAsset': item.idAsset,
                              'nama': item.nama,
                              'feederName': item.feeder?.nama ?? '-',
                              'latitude': item.latitude?.toString() ?? '',
                              'longitude': item.longitude?.toString() ?? '',
                              'workOrderId': wo.id.toString(),
                              'status': item.status,
                            },
                          );
                        },
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
