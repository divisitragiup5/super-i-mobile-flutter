import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/ppl_model.dart';
import '../cubit/ppl_cubit.dart';

class RiwayatPPLPage extends StatefulWidget {
  final String? type;

  const RiwayatPPLPage({super.key, this.type});

  @override
  State<RiwayatPPLPage> createState() => _RiwayatPPLPageState();
}

class _RiwayatPPLPageState extends State<RiwayatPPLPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<PplCubit>().loadHistory(type: widget.type);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<PplCubit>().loadMoreHistory(search: _searchController.text, type: widget.type);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    context.read<PplCubit>().loadHistory(search: value, type: widget.type);
  }

  @override
  Widget build(BuildContext context) {
    String pageTitle = 'Riwayat PPL';
    if (widget.type == 'belum-ttd-tl-gi') pageTitle = 'PPL Belum TTD TL GI';
    if (widget.type == 'sudah-ttd-tl-gi') pageTitle = 'PPL Sudah TTD TL GI';

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearch,
              decoration: InputDecoration(
                hintText: 'Cari objek, pelaksana, pekerjaan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
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
            child: BlocBuilder<PplCubit, PplState>(
              builder: (context, state) {
                if (state is PplLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PplHistoryLoaded) {
                  final items = state.items;
                  if (items.isEmpty) {
                    return const Center(child: Text('Tidak ada riwayat PPL ditemukan'));
                  }

                  return RefreshIndicator(
                    onRefresh: () => context.read<PplCubit>().loadHistory(
                          search: _searchController.text,
                          type: widget.type,
                        ),
                    child: ListView.separated(
                      controller: _scrollController,
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

  Widget _buildItemCard(PPLHistoryItemModel item) {
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
            Text(
              item.namaPekerjaan ?? '-',
              style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  item.createdAt ?? '-',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(width: 12),
                if (item.statusPekerjaan != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.statusPekerjaan!,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.push('/riwayat-ppl-detail', extra: item);
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Lihat Detail'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_note, color: AppColors.primary),
                  tooltip: 'Update PPL',
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
  }
}
