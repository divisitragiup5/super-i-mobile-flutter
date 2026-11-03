import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/wo_pemeliharaan_cubit.dart';

class RiwayatPemeliharaanPage extends StatefulWidget {
  const RiwayatPemeliharaanPage({super.key});

  @override
  State<RiwayatPemeliharaanPage> createState() =>
      _RiwayatPemeliharaanPageState();
}

class _RiwayatPemeliharaanPageState extends State<RiwayatPemeliharaanPage> {
  @override
  void initState() {
    super.initState();
    context.read<WoPemeliharaanCubit>().fetchList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pemeliharaan SUTM'),
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
              await context.read<WoPemeliharaanCubit>().fetchList();
            },
            child: BlocBuilder<WoPemeliharaanCubit, WoPemeliharaanState>(
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

                final items = state is WoPemeliharaanLoaded
                    ? state.allWorkOrders
                    : [];

                if (items.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada riwayat pemeliharaan ditemukan',
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                            'Jumlah SUTM: ${item.totalSutm} • Status: ${item.status}'),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                        onTap: () {
                          context.push(
                            AppRoutes.detailWorkorderPemeliharaan,
                            extra: item.id.toString(),
                          );
                        },
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
