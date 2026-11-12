import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/opgi_realisasi_model.dart';
import '../cubit/opgi_realisasi_cubit.dart';
import '../utils/tegangan_trafo_utils.dart';
import '../widgets/tegangan_trafo_item_card.dart';

class TeganganTrafoPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;
  final String? scanValue;

  const TeganganTrafoPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
    this.scanValue,
  });

  @override
  State<TeganganTrafoPage> createState() => _TeganganTrafoPageState();
}

class _TeganganTrafoPageState extends State<TeganganTrafoPage> {
  bool _hasHandledQr = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch({bool forceRefresh = false}) {
    context.read<OpgiRealisasiCubit>().loadTeganganTrafo(
          widget.garduIndukId,
          null,
          'Asia/Jakarta',
          forceRefresh,
        );
  }

  void _handleQrScanIfNeeded(List<TeganganTrafoModel> items, List<Map<String, dynamic>> drafts) {
    if (_hasHandledQr || widget.scanValue == null || widget.scanValue!.trim().isEmpty) return;

    final target = widget.scanValue!.trim();
    TeganganTrafoModel? matched;
    for (final t in items) {
      if ('${t.nama}-${t.garduIndukNama}' == target || t.nama == target) {
        matched = t;
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

    final mapped = mapTeganganTrafoPeriods(item: matched, localDrafts: drafts);
    final isDone = mapped.isNotEmpty && mapped.every((p) => p.isDone);
    if (isDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tegangan trafo ini sudah selesai diisi untuk semua periode'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _navigateToInput(matched, mapped, null);
  }

  void _navigateToInput(
    TeganganTrafoModel item,
    List<TeganganTrafoMappedPeriod> mappedPeriods,
    TeganganTrafoMappedPeriod? targetPeriod,
  ) async {
    final periodToUse = targetPeriod ??
        mappedPeriods.firstWhere(
          (p) => !p.isDone,
          orElse: () => mappedPeriods.first,
        );

    TrafoTeganganItemModel? lastTegangan;
    for (final t in item.tegangan) {
      if (t.periode < periodToUse.periode) {
        if (lastTegangan == null || t.periode > lastTegangan.periode) {
          lastTegangan = t;
        }
      }
    }
    lastTegangan ??= item.tegangan.isNotEmpty ? item.tegangan.last : null;

    await context.push(
      AppRoutes.inputTeganganTrafo,
      extra: {
        'id': item.id,
        'nama': item.nama,
        'garduInduk': item.garduIndukNama,
        'garduIndukId': item.garduIndukId,
        'last': lastTegangan?.toJson(),
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

  void _navigateToView(TeganganTrafoModel item) async {
    await context.push(
      AppRoutes.dataTeganganTrafo,
      extra: {
        'id': item.id,
        'nama': item.nama,
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
              context.read<OpgiRealisasiCubit>().batchSubmitTeganganTrafo(widget.garduIndukId, parsedDrafts);
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
              context.read<OpgiRealisasiCubit>().deleteAllTeganganTrafoDrafts(widget.garduIndukId, allDraftIds);
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
        final cubit = context.read<OpgiRealisasiCubit>();
        final items = cubit.cachedTeganganTrafoList;
        final drafts = cubit.cachedTeganganTrafoDrafts;

        if (state is TeganganTrafoLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleQrScanIfNeeded(state.items, state.localDrafts);
          });
        }

        return PopScope(
          canPop: !isSaving,
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.garduIndukNama),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              actions: [
                if (!isSaving && state is TeganganTrafoLoaded) ...[
                  () {
                    final parsedResult = parseTeganganTrafoDrafts(
                      localDrafts: state.localDrafts,
                      garduIndukId: widget.garduIndukId,
                      mappedData: state.items,
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
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Segarkan',
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
                  : (items.isEmpty && state is OpgiRealisasiLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: () async => _fetch(forceRefresh: true),
                          child: items.isEmpty
                              ? ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: const [
                                    SizedBox(height: 120),
                                    Center(
                                      child: Text(
                                        'Tidak ada data Tegangan Trafo',
                                        style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(16),
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    final mappedPeriods = mapTeganganTrafoPeriods(
                                      item: item,
                                      localDrafts: drafts,
                                    );

                                    return TeganganTrafoItemCard(
                                      item: item,
                                      mappedPeriods: mappedPeriods,
                                      onView: () => _navigateToView(item),
                                      onInput: () => _navigateToInput(item, mappedPeriods, null),
                                      onPeriodTap: (period) => _navigateToInput(item, mappedPeriods, period),
                                      onPeriodLongPress: (period) => _navigateToInput(item, mappedPeriods, period),
                                    );
                                  },
                                ),
                        )),
            ),
          ),
        );
      },
    );
  }
}
