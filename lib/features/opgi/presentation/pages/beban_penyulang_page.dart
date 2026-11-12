import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/storage/local_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/opgi_realisasi_model.dart';
import '../cubit/opgi_realisasi_cubit.dart';
import '../utils/beban_penyulang_utils.dart';
import '../widgets/penyulang_item_card.dart';

class BebanPenyulangPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;
  final String? scanValue;

  const BebanPenyulangPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
    this.scanValue,
  });

  @override
  State<BebanPenyulangPage> createState() => _BebanPenyulangPageState();
}

class _BebanPenyulangPageState extends State<BebanPenyulangPage> {
  bool _hasHandledQr = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch({bool forceRefresh = false}) {
    context.read<OpgiRealisasiCubit>().loadBebanPenyulang(
          widget.garduIndukId,
          null,
          'Asia/Jakarta',
          forceRefresh,
        );
  }

  void _handleQrScanIfNeeded(List<PenyulangModel> items, List<Map<String, dynamic>> drafts) {
    if (_hasHandledQr || widget.scanValue == null || widget.scanValue!.trim().isEmpty) return;

    final target = widget.scanValue!.trim();
    PenyulangModel? matched;
    for (final p in items) {
      if ('${p.nama}-${p.garduIndukNama}' == target || p.nama == target) {
        matched = p;
        break;
      }
    }

    _hasHandledQr = true;

    if (matched == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR Code yang Anda scan tidak valid untuk Gardu Induk ini'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final mapped = mapPenyulangPeriods(item: matched, localDrafts: drafts);
    final isDone = mapped.isNotEmpty && mapped.every((p) => p.isDone);
    if (isDone || matched.statusCB.toUpperCase() == 'OFF') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Penyulang ini sudah selesai diisi atau status CB OFF'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _navigateToInput(matched, mapped, null);
  }

  void _navigateToInput(
    PenyulangModel item,
    List<PenyulangMappedPeriod> mappedPeriods,
    PenyulangMappedPeriod? targetPeriod,
  ) async {
    final periodToUse = targetPeriod ??
        mappedPeriods.firstWhere(
          (p) => !p.isDone,
          orElse: () => mappedPeriods.first,
        );

    // Hitung beban sebelum periode yang dipilih
    PenyulangBebanItemModel? lastBeban;
    for (final b in item.beban) {
      if (b.periode < periodToUse.periode) {
        if (lastBeban == null || b.periode > lastBeban.periode) {
          lastBeban = b;
        }
      }
    }
    lastBeban ??= item.beban.isNotEmpty ? item.beban.last : null;

    await context.push(
      AppRoutes.inputBebanPenyulang,
      extra: {
        'id': item.id,
        'nama': item.nama,
        'iMax': item.iMax,
        'rel': item.rel,
        'garduInduk': item.garduIndukNama,
        'garduIndukId': item.garduIndukId,
        'last': lastBeban?.toJson(),
        'lastPeriode': {
          'periode': periodToUse.periode,
          'tanggal': periodToUse.tanggal,
          'bulan': periodToUse.bulan,
          'tahun': periodToUse.tahun,
        },
        'scanValue': widget.scanValue,
      },
    );

    _fetch();
  }

  void _navigateToView(PenyulangModel item) async {
    await context.push(
      AppRoutes.dataBebanPenyulang,
      extra: {
        'id': item.id,
        'nama': item.nama,
        'iMax': item.iMax,
        'rel': item.rel,
        'statusCB': item.statusCB,
        'garduInduk': item.garduIndukNama,
        'garduIndukId': item.garduIndukId,
      },
    );

    _fetch();
  }

  void _showBatchUploadConfirmation(List<Map<String, dynamic>> parsedDrafts) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Peringatan'),
        content: const Text('Apakah anda yakin ingin menyimpan semua data draft yang sudah lengkap?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OpgiRealisasiCubit>().batchSubmitBebanPenyulang(widget.garduIndukId, parsedDrafts);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDraftsConfirmation(List<int> allDraftIds) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Peringatan'),
        content: const Text('Apakah anda yakin ingin menghapus semua data draft yang ada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OpgiRealisasiCubit>().deleteAllDrafts(widget.garduIndukId, allDraftIds);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OpgiRealisasiCubit, OpgiRealisasiState>(
      listener: (context, state) {
        if (state is OpgiRealisasiSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is OpgiRealisasiError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isSaving = state is OpgiBatchProgress;

        return PopScope(
          canPop: !isSaving,
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.garduIndukNama),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              actions: [
                if (!isSaving && state is BebanPenyulangLoaded) ...[
                  () {
                    final parsedResult = parseBebanPenyulangDrafts(
                      localDrafts: state.localDrafts,
                      garduIndukId: widget.garduIndukId,
                      penyulangList: state.items,
                    );

                    final validDrafts = parsedResult.parsed;
                    final allDrafts = state.localDrafts;

                    final allDraftIds = allDrafts
                        .map((d) => d['id'] is int ? d['id'] as int : int.tryParse('${d['id']}'))
                        .whereType<int>()
                        .toList();

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (validDrafts.isNotEmpty)
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.save_outlined, color: Colors.greenAccent),
                                tooltip: 'Kirim Semua Draft',
                                onPressed: () => _showBatchUploadConfirmation(validDrafts),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                  child: Text(
                                    '${validDrafts.length}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (allDrafts.isNotEmpty)
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                tooltip: 'Hapus Semua Draft',
                                onPressed: () => _showDeleteAllDraftsConfirmation(allDraftIds),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                  child: Text(
                                    '${allDrafts.length}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    );
                  }(),
                ],
                IconButton(
                  icon: const Icon(Icons.format_list_bulleted),
                  tooltip: 'Urutan Penyulang',
                  onPressed: isSaving
                      ? null
                      : () async {
                          await context.push(
                            AppRoutes.updateUrutanPenyulang,
                            extra: {
                              'garduIndukId': widget.garduIndukId,
                              'garduIndukNama': widget.garduIndukNama,
                            },
                          );
                          _fetch(forceRefresh: true);
                        },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: isSaving ? null : () => _fetch(forceRefresh: true),
                ),
              ],
            ),
            body: AppBackground(
              child: isSaving
                  ? LoadingIndicator(
                      text: 'Mengirim ${state.completed}/${state.total}',
                      progress: state.total > 0
                          ? '${((state.completed / state.total) * 100).toStringAsFixed(0)}%'
                          : '0%',
                    )
                  : (state is OpgiRealisasiLoading
                      ? const Center(child: CircularProgressIndicator())
                      : (state is BebanPenyulangLoaded
                          ? () {
                              final items = state.items;
                              final drafts = state.localDrafts;

                              // Hapus duplikasi draft yang sudah ada di server secara otomatis
                              final parsedResult = parseBebanPenyulangDrafts(
                                localDrafts: drafts,
                                garduIndukId: widget.garduIndukId,
                                penyulangList: items,
                              );
                              if (parsedResult.duplicates.isNotEmpty) {
                                for (final dupId in parsedResult.duplicates) {
                                  LocalDatabase.instance.deleteUnfinishedItemGI(dupId);
                                }
                              }

                              // Handle scan QR jika scanValue dikirim
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _handleQrScanIfNeeded(items, drafts);
                              });

                              if (items.isEmpty) {
                                return RefreshIndicator(
                                  onRefresh: () async => _fetch(forceRefresh: true),
                                  child: ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(32),
                                    children: [
                                      const SizedBox(height: 80),
                                      Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.account_tree_outlined, size: 64, color: Colors.grey.shade400),
                                            const SizedBox(height: 12),
                                            const Text(
                                              'Belum ada data Penyulang untuk Gardu Induk ini',
                                              style: TextStyle(color: Colors.grey, fontSize: 14),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return RefreshIndicator(
                                onRefresh: () async => _fetch(forceRefresh: true),
                                child: ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(16),
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    final mappedPeriods = mapPenyulangPeriods(item: item, localDrafts: drafts);

                                    return PenyulangItemCard(
                                      key: ValueKey(item.id),
                                      item: item,
                                      mappedPeriods: mappedPeriods,
                                      onView: () => _navigateToView(item),
                                      onInput: () => _navigateToInput(item, mappedPeriods, null),
                                      onPeriodTap: (period) => _navigateToInput(item, mappedPeriods, period),
                                      onPeriodLongPress: (period) => _navigateToInput(item, mappedPeriods, period),
                                    );
                                  },
                                ),
                              );
                            }()
                          : const SizedBox.shrink())),
            ),
          ),
        );
      },
    );
  }
}
