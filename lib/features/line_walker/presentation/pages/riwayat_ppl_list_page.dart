import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/ppl_cubit.dart';

class RiwayatPPLListPage extends StatefulWidget {
  final String identifier;
  final String? namaPekerjaan;
  final String? pihakPelaksana;

  const RiwayatPPLListPage({
    super.key,
    required this.identifier,
    this.namaPekerjaan,
    this.pihakPelaksana,
  });

  @override
  State<RiwayatPPLListPage> createState() => _RiwayatPPLListPageState();
}

class _RiwayatPPLListPageState extends State<RiwayatPPLListPage> {
  @override
  void initState() {
    super.initState();
    context.read<PplCubit>().loadHistoryByIdentifier(widget.identifier);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.namaPekerjaan ?? 'Daftar Pembaruan PPL'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<PplCubit, PplState>(
        builder: (context, state) {
          if (state is PplLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PplHistoryLoaded) {
            final items = state.items;
            if (items.isEmpty) {
              return const Center(child: Text('Tidak ada riwayat pembaruan'));
            }

            return RefreshIndicator(
              onRefresh: () => context.read<PplCubit>().loadHistoryByIdentifier(widget.identifier),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
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
                              Text(
                                item.namaTower ?? 'Tower',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              if (item.statusPekerjaan != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.statusPekerjaan!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E40AF),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.createdAt ?? '-',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    context.push('/riwayat-ppl-detail', extra: item);
                                  },
                                  child: const Text('Lihat Rincian'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit_note, color: AppColors.primary),
                                tooltip: 'TTD TL GI',
                                onPressed: () {
                                  context.push('/update-ppl', extra: {
                                    'id': item.id,
                                    'tower': {'nama': item.namaTower},
                                    'namaPekerjaan': item.namaPekerjaan,
                                    'statusPekerjaan': item.statusPekerjaan,
                                  });
                                },
                              ),
                            ],
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
