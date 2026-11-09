import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../cubit/ketenagakerjaan_cubit.dart';
import '../widgets/history_detail_widgets.dart';

class SummaryKetenagakerjaanPage extends StatefulWidget {
  const SummaryKetenagakerjaanPage({super.key});

  @override
  State<SummaryKetenagakerjaanPage> createState() => _SummaryKetenagakerjaanPageState();
}

class _SummaryKetenagakerjaanPageState extends State<SummaryKetenagakerjaanPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    context.read<KetenagakerjaanCubit>().loadSummary();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<KetenagakerjaanCubit>().loadMoreSummary(search: _searchCtrl.text);
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
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
        title: const Text('Ketenagakerjaan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: AppBackground(
        child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) {
                _searchDebounce?.cancel();
                _searchDebounce = Timer(const Duration(milliseconds: 500), () {
                  context.read<KetenagakerjaanCubit>().loadSummary(search: val);
                });
                setState(() {});
              },
              onSubmitted: (val) => context.read<KetenagakerjaanCubit>().loadSummary(search: val),
              decoration: InputDecoration(
                hintText: 'Cari nama petugas...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchDebounce?.cancel();
                          _searchCtrl.clear();
                          context.read<KetenagakerjaanCubit>().loadSummary(search: '');
                          setState(() {});
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
            child: BlocBuilder<KetenagakerjaanCubit, KetenagakerjaanState>(
              builder: (context, state) {
                if (state is KetenagakerjaanLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is KetenagakerjaanSummaryLoaded) {
                  final items = state.items;
                  if (items.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => context.read<KetenagakerjaanCubit>().loadSummary(search: _searchCtrl.text),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        children: const [
                          HistoryEmptyCard(),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => context.read<KetenagakerjaanCubit>().loadSummary(search: _searchCtrl.text),
                    child: ListView.separated(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
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
                        final color = _getStatusColor(item.status);

                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              context.push(
                                '/ketenagakerjaan?id=${item.userId ?? item.id}&namaLengkap=${Uri.encodeComponent(item.namaPetugas ?? '')}',
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.namaPetugas ?? 'Petugas Line Walker',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.status,
                                          style: TextStyle(
                                            fontSize: 12,
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
                                  ),
                                  Text(
                                    item.score.toStringAsFixed(2),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF94A3B8)),
                                ],
                              ),
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
          ),
        ],
      ),
    ),
  );
}
}
