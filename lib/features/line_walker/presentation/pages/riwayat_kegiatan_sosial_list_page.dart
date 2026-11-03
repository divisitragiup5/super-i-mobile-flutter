import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/kegiatan_sosial_cubit.dart';

class RiwayatKegiatanSosialListPage extends StatefulWidget {
  final String identifier;

  const RiwayatKegiatanSosialListPage({
    super.key,
    required this.identifier,
  });

  @override
  State<RiwayatKegiatanSosialListPage> createState() => _RiwayatKegiatanSosialListPageState();
}

class _RiwayatKegiatanSosialListPageState extends State<RiwayatKegiatanSosialListPage> {
  @override
  void initState() {
    super.initState();
    context.read<KegiatanSosialCubit>().loadHistoryByIdentifier(widget.identifier);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pembaruan Kegiatan Sosial'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<KegiatanSosialCubit, KegiatanSosialState>(
        builder: (context, state) {
          if (state is KegiatanSosialLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is KegiatanSosialHistoryLoaded) {
            final items = state.items;
            if (items.isEmpty) {
              return const Center(child: Text('Tidak ada riwayat pembaruan'));
            }

            return RefreshIndicator(
              onRefresh: () => context.read<KegiatanSosialCubit>().loadHistoryByIdentifier(widget.identifier),
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
                          Text(
                            item.namaTower ?? 'Tower',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('${item.jenisAktivitas ?? '-'} - ${item.pelakuAktivitasSosial ?? '-'}'),
                          const SizedBox(height: 4),
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
                                    context.push('/riwayat-kegiatan-sosial-detail', extra: item);
                                  },
                                  child: const Text('Lihat Rincian'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit_note, color: AppColors.primary),
                                tooltip: 'Update Kegiatan Sosial',
                                onPressed: () {
                                  context.push('/update-kegiatan-sosial', extra: {
                                    'id': item.id,
                                    'tower': {'nama': item.namaTower},
                                    'jenisAktivitas': item.jenisAktivitas,
                                    'statusAktivitas': item.statusAktivitas,
                                    'pelakuAktivitasSosial': item.pelakuAktivitasSosial,
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
