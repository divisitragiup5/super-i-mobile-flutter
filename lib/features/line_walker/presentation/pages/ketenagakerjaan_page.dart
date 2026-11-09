import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/models/ketenagakerjaan_model.dart';
import '../cubit/ketenagakerjaan_cubit.dart';
import '../widgets/history_detail_widgets.dart';

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
  final ScrollController _scrollCtrl = ScrollController();

  int get _effectiveId {
    if (widget.id > 0) return widget.id;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.id;
    }
    return 0;
  }

  String? get _effectiveNama {
    if (widget.namaLengkap != null && widget.namaLengkap!.isNotEmpty) {
      return widget.namaLengkap;
    }
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.namaLengkap;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KetenagakerjaanCubit>().loadDetail(_effectiveId);
    });
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<KetenagakerjaanCubit>().loadMoreDetail(_effectiveId);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    final s = status.toUpperCase();
    if (s == 'AMAN') return Colors.green;
    if (s.contains('TEGURAN')) return Colors.orange;
    return Colors.red;
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  void _showBottomSheetAction(BuildContext parentContext, KetenagakerjaanItemModel item) {
    showModalBottomSheet(
      context: parentContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (bottomSheetContext) {
        bool isDownloading = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text(
                      'Aksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: isDownloading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download, color: AppColors.primary),
                      title: Text(
                        'Download ${_capitalize(item.status)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      onTap: isDownloading
                          ? null
                          : () async {
                              setModalState(() => isDownloading = true);
                              try {
                                final cubit = parentContext.read<KetenagakerjaanCubit>();
                                await cubit.downloadSurat(item);
                                if (bottomSheetContext.mounted) {
                                  Navigator.pop(bottomSheetContext);
                                }
                                if (parentContext.mounted) {
                                  ScaffoldMessenger.of(parentContext).showSnackBar(
                                    SnackBar(
                                      content: Text('Surat ${_capitalize(item.status)} berhasil diunduh'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isDownloading = false);
                                if (parentContext.mounted) {
                                  ScaffoldMessenger.of(parentContext).showSnackBar(
                                    const SnackBar(
                                      content: Text('Terdapat kesalahan saat mengunduh file!'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_effectiveNama ?? 'Kinerja Ketenagakerjaan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: AppBackground(
        child: BlocBuilder<KetenagakerjaanCubit, KetenagakerjaanState>(
          builder: (context, state) {
            if (state is KetenagakerjaanLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is KetenagakerjaanError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<KetenagakerjaanCubit>().loadDetail(_effectiveId),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is KetenagakerjaanDetailLoaded) {
              final items = state.items;
              if (items.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => context.read<KetenagakerjaanCubit>().loadDetail(_effectiveId),
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
                onRefresh: () => context.read<KetenagakerjaanCubit>().loadDetail(_effectiveId),
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
                                      'Minggu ke ${item.minggu} ${_capitalize(item.bulan)} ${item.tahun}',
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
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      context.push('/ketenagakerjaan-detail', extra: item);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(40),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Lihat Rincian'),
                                  ),
                                ),
                                if (item.status.toUpperCase() != 'AMAN') ...[
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () => _showBottomSheetAction(context, item),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(40, 40),
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Icon(Icons.more_vert, size: 20),
                                  ),
                                ],
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
      ),
    );
  }
}
