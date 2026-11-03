import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/ketenagakerjaan_cubit.dart';

class KetenagakerjaanPage extends StatefulWidget {
  final int id;
  final String? namaLengkap;

  const KetenagakerjaanPage({
    super.key,
    required this.id,
    this.namaLengkap,
  });

  @override
  State<KetenagakerjaanPage> createState() => _KetenagakerjaanPageState();
}

class _KetenagakerjaanPageState extends State<KetenagakerjaanPage> {
  @override
  void initState() {
    super.initState();
    context.read<KetenagakerjaanCubit>().loadDetail(widget.id);
  }

  Color _getStatusColor(String status) {
    if (status.toUpperCase() == 'AMAN') return Colors.green;
    if (status.toUpperCase().contains('TEGURAN')) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.namaLengkap ?? 'Kinerja Ketenagakerjaan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<KetenagakerjaanCubit, KetenagakerjaanState>(
        builder: (context, state) {
          if (state is KetenagakerjaanLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is KetenagakerjaanDetailLoaded) {
            final items = state.items;
            if (items.isEmpty) {
              return const Center(child: Text('Tidak ada riwayat kinerja ditemukan'));
            }

            return RefreshIndicator(
              onRefresh: () => context.read<KetenagakerjaanCubit>().loadDetail(widget.id),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final color = _getStatusColor(item.status);

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.status,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Minggu ke-${item.minggu} ${item.bulan} ${item.tahun}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                              Text(
                                item.score.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              context.push('/ketenagakerjaan-detail', extra: item);
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Lihat Rincian'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
