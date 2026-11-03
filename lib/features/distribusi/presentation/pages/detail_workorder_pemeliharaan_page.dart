import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/wo_pemeliharaan_cubit.dart';

class DetailWorkorderPemeliharaanPage extends StatefulWidget {
  final String workOrderId;

  const DetailWorkorderPemeliharaanPage({
    super.key,
    required this.workOrderId,
  });

  @override
  State<DetailWorkorderPemeliharaanPage> createState() =>
      _DetailWorkorderPemeliharaanPageState();
}

class _DetailWorkorderPemeliharaanPageState
    extends State<DetailWorkorderPemeliharaanPage> {
  @override
  void initState() {
    super.initState();
    context.read<WoPemeliharaanCubit>().fetchDetail(widget.workOrderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail WO #${widget.workOrderId}'),
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
          BlocBuilder<WoPemeliharaanCubit, WoPemeliharaanState>(
            builder: (context, state) {
              if (state is WoPemeliharaanLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is WoPemeliharaanError) {
                return Center(
                  child: Text(state.message,
                      style: const TextStyle(color: Colors.white)),
                );
              }

              final wo = state is WoPemeliharaanLoaded
                  ? state.detailWorkOrder
                  : null;

              if (wo == null) {
                return const Center(
                  child: Text('Data tidak ditemukan',
                      style: TextStyle(color: Colors.white)),
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
                          'Work Order Pemeliharaan #${wo.id}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${wo.status}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total SUTM: ${wo.items.length}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Daftar Tiang Pemeliharaan',
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
                        subtitle: Text('${item.idAsset} • ${item.status}'),
                        onTap: () {
                          context.push(
                            AppRoutes.inspeksiPemeliharaanForm,
                            extra: {
                              'workOrderId': wo.id.toString(),
                              'workOrderSutmItemId': item.id.toString(),
                              'sutmId': item.sutmId.toString(),
                              'idAsset': item.idAsset,
                              'nama': item.nama,
                              'rencana': item.rencana,
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
