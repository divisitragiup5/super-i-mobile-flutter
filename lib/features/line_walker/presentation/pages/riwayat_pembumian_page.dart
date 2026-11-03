import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/pembumian_model.dart';
import '../cubit/pembumian_cubit.dart';

class RiwayatPembumianPage extends StatefulWidget {
  const RiwayatPembumianPage({super.key});

  @override
  State<RiwayatPembumianPage> createState() => _RiwayatPembumianPageState();
}

class _RiwayatPembumianPageState extends State<RiwayatPembumianPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<PembumianCubit>().loadHistory();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<PembumianCubit>().loadMoreHistory(search: _searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    context.read<PembumianCubit>().loadHistory(search: value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembumian'),
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
                hintText: 'Cari objek tower...',
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
            child: BlocBuilder<PembumianCubit, PembumianState>(
              builder: (context, state) {
                if (state is PembumianLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PembumianHistoryLoaded) {
                  final items = state.items;
                  if (items.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada riwayat pembumian ditemukan'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => context.read<PembumianCubit>().loadHistory(search: _searchController.text),
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

  Widget _buildItemCard(PembumianHistoryItemModel item) {
    final bool hasKendala = item.kendala != null && item.kendala != 'TIDAK';

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
                    color: hasKendala ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: hasKendala ? Colors.red.shade300 : Colors.green.shade300,
                    ),
                  ),
                  child: Text(
                    hasKendala ? item.kendala! : 'NORMAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: hasKendala ? Colors.red.shade700 : Colors.green.shade700,
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
            if (item.nilaiRataRata != null) ...[
              const SizedBox(height: 6),
              Text(
                'Nilai Rata-Rata: ${item.nilaiRataRata!.toStringAsFixed(2)} Ohm',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                context.push('/riwayat-pembumian-detail', extra: item);
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
  }
}
