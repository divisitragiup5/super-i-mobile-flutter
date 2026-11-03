import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/kegiatan_sosial_model.dart';
import '../cubit/kegiatan_sosial_cubit.dart';

class RiwayatKegiatanSosialPage extends StatefulWidget {
  const RiwayatKegiatanSosialPage({super.key});

  @override
  State<RiwayatKegiatanSosialPage> createState() => _RiwayatKegiatanSosialPageState();
}

class _RiwayatKegiatanSosialPageState extends State<RiwayatKegiatanSosialPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<KegiatanSosialCubit>().loadHistory();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<KegiatanSosialCubit>().loadMoreHistory(search: _searchCtrl.text);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    context.read<KegiatanSosialCubit>().loadHistory(search: value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Kegiatan Sosial'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: _onSearch,
              decoration: InputDecoration(
                hintText: 'Cari objek, aktivitas, pelaku...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<KegiatanSosialCubit, KegiatanSosialState>(
              builder: (context, state) {
                if (state is KegiatanSosialLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is KegiatanSosialHistoryLoaded) {
                  final items = state.items;
                  if (items.isEmpty) {
                    return const Center(child: Text('Tidak ada riwayat kegiatan sosial ditemukan'));
                  }

                  return RefreshIndicator(
                    onRefresh: () => context.read<KegiatanSosialCubit>().loadHistory(search: _searchCtrl.text),
                    child: ListView.separated(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == items.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        final item = items[index];
                        return _buildItemCard(item);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(KegiatanSosialHistoryItemModel item) {
    final bool hasTtdTLGI = item.ttdTLGI != null && item.ttdTLGI!.isNotEmpty;

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
                Expanded(
                  child: Text(
                    item.namaTower ?? 'Tower',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasTtdTLGI ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: hasTtdTLGI ? Colors.green.shade300 : Colors.orange.shade300,
                    ),
                  ),
                  child: Text(
                    hasTtdTLGI ? 'TTD TL GI' : 'BELUM TTD',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: hasTtdTLGI ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${item.jenisAktivitas ?? '-'} - ${item.pelakuAktivitasSosial ?? '-'}',
              style: const TextStyle(fontSize: 14),
            ),
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
                    child: const Text('Lihat Detail'),
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
  }
}
