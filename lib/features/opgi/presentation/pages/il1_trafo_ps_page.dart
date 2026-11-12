import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_background.dart';
import '../../data/models/opgi_il1_model.dart';
import '../cubit/opgi_il1_cubit.dart';
import '../utils/il1_trafo_ps_utils.dart';

class Il1TrafoPsPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;
  final String? scanValue;

  const Il1TrafoPsPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
    this.scanValue,
  });

  @override
  State<Il1TrafoPsPage> createState() => _Il1TrafoPsPageState();
}

class _Il1TrafoPsPageState extends State<Il1TrafoPsPage> {
  bool _isSavingBatch = false;
  int _batchCompleted = 0;
  int _batchTotal = 0;
  bool _scanHandled = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch({bool force = false}) {
    context.read<OpgiIl1Cubit>().loadTrafoPs(widget.garduIndukId, forceRefresh: force);
  }

  void _checkScanValue(List<Il1TrafoPsItem> items) {
    if (_scanHandled || widget.scanValue == null || widget.scanValue!.trim().isEmpty) return;

    final query = widget.scanValue!.trim();
    final target = items.firstWhere(
      (it) =>
          '${it.nama}-${widget.garduIndukNama}' == query ||
          '${it.nama}-${it.garduIndukNama}' == query ||
          it.nama == query,
      orElse: () => const Il1TrafoPsItem(id: -1, nama: ''),
    );

    _scanHandled = true;

    if (target.id == -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code yang anda scan tidak cocok dengan data Trafo PS ini'),
            backgroundColor: Colors.red,
          ),
        );
      });
      return;
    }

    if (target.isDisabled || target.last != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code yang anda scan tidak valid atau sudah selesai'),
            backgroundColor: Colors.red,
          ),
        );
      });
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToInput(target);
    });
  }

  void _navigateToInput(Il1TrafoPsItem item) {
    context.push(
      AppRoutes.inputIl1TrafoPs,
      extra: {
        'id': item.id,
        'nama': item.nama,
        'garduInduk': widget.garduIndukNama,
        'garduIndukNama': widget.garduIndukNama,
        'garduIndukId': widget.garduIndukId,
        'last': item.lastData != null ? jsonEncode(item.lastData) : null,
        'merkTrafo': item.trafo?['merkTrafo'],
        'tahunPembuatanTrafo': item.trafo?['tahunPembuatanTrafo']?.toString(),
        'noSeriTrafo': item.trafo?['noSeriTrafo'],
        'kapasitasTrafo': item.trafo?['kapasitasTrafo']?.toString(),
        'tapTrafo': item.trafo?['tapTrafo']?.toString(),
        'jenisTrafo': item.trafo?['jenisTrafo'],
      },
    ).then((_) => _fetch(force: true));
  }

  void _navigateToDetail(Il1TrafoPsItem item) {
    context.push(
      AppRoutes.dataIl1TrafoPs,
      extra: {
        'id': item.id,
        'nama': item.nama,
        'garduInduk': widget.garduIndukNama,
        'garduIndukNama': widget.garduIndukNama,
        'garduIndukId': widget.garduIndukId,
        'status': item.last?['status']?.toString() ?? '',
      },
    ).then((_) => _fetch(force: true));
  }

  void _handleSaveDrafts(List<Map<String, dynamic>> parsedDrafts) {
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OpgiIl1Cubit>().batchSubmitTrafoPs(widget.garduIndukId, parsedDrafts);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAllDrafts() {
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<OpgiIl1Cubit>().deleteAllDrafts('il1-trafo-ps');
              _fetch(force: true);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey.shade400;
    final s = status.toUpperCase();
    if (s.contains('SESUAI') && !s.contains('TIDAK')) return const Color(0xFF16A34A);
    if (s.contains('ANOMALI')) return const Color(0xFFEA580C);
    if (s.contains('TIDAK SESUAI')) return const Color(0xFFDC2626);
    return Colors.grey.shade500;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OpgiIl1Cubit, OpgiIl1State>(
      listener: (context, state) {
        if (state is OpgiBatchProgress) {
          setState(() {
            _isSavingBatch = true;
            _batchCompleted = state.completed;
            _batchTotal = state.total;
          });
        } else if (state is OpgiIl1Success) {
          if (_isSavingBatch) {
            setState(() => _isSavingBatch = false);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
        } else if (state is OpgiIl1Error) {
          if (_isSavingBatch) {
            setState(() => _isSavingBatch = false);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<OpgiIl1Cubit>();
        final items = cubit.cachedTrafoPsList;
        final rawDrafts = cubit.cachedTrafoPsDrafts;

        final parseResult = Il1TrafoPsUtils.parseIl1TrafoPsDrafts(
          rawDrafts,
          widget.garduIndukId,
          items,
        );
        final validDrafts = parseResult.parsed;
        final validDraftCount = validDrafts.length;
        final allDraftCount = rawDrafts.length;

        if (items.isNotEmpty && !_scanHandled && widget.scanValue != null) {
          _checkScanValue(items);
        }

        return PopScope(
          canPop: !_isSavingBatch,
          child: Scaffold(
            appBar: AppBar(
              title: Text('IL1 Trafo PS - ${widget.garduIndukNama}'),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              actions: [
                if (validDraftCount > 0 && !_isSavingBatch)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.save_outlined, color: Color(0xFF22C55E), size: 26),
                        tooltip: 'Simpan Semua Draft',
                        onPressed: () => _handleSaveDrafts(validDrafts),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$validDraftCount',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (allDraftCount > 0 && !_isSavingBatch)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 26),
                        tooltip: 'Hapus Semua Draft',
                        onPressed: _handleDeleteAllDrafts,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$allDraftCount',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: () => _fetch(force: true),
                ),
              ],
            ),
            body: AppBackground(
              child: Stack(
                children: [
                  if (state is OpgiIl1Loading && items.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (widget.garduIndukId == 0)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
                            const SizedBox(height: 16),
                            const Text('Gardu Induk belum dipilih', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text('Silakan kembali dan pilih Gardu Induk terlebih dahulu.', textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                              onPressed: () => context.pop(),
                              child: const Text('Kembali'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (state is OpgiIl1Error && items.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Coba Lagi'),
                              onPressed: () => _fetch(force: true),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (items.isEmpty)
                    RefreshIndicator(
                      onRefresh: () async => _fetch(force: true),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.view_in_ar_outlined, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                const Text('Tidak ada data Trafo PS'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    RefreshIndicator(
                      onRefresh: () async => _fetch(force: true),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final hasLast = item.last != null;
                          final statusStr = item.last?['status']?.toString();
                          final dotColor = _getStatusColor(statusStr);
                          final isDrafted = rawDrafts.any(
                            (d) => d['nama'] == '${item.nama}-${widget.garduIndukNama}',
                          );

                          Color cardBg = Colors.white;
                          if (item.isDisabled) {
                            cardBg = Colors.grey.shade300;
                          } else if (hasLast) {
                            cardBg = const Color(0xFFDCFCE7);
                          }

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 4, right: 12),
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: dotColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.nama,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            widget.garduIndukNama,
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (hasLast && statusStr != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: dotColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: dotColor.withValues(alpha: 0.4)),
                                        ),
                                        child: Text(
                                          statusStr,
                                          style: TextStyle(
                                            color: dotColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    else if (isDrafted)
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Colors.orange,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'Drafted',
                                            style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                if (!item.isDisabled) ...[
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.primary,
                                            side: const BorderSide(color: AppColors.primary),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                          ),
                                          onPressed: () => _navigateToDetail(item),
                                          child: const Text('Lihat', style: TextStyle(fontWeight: FontWeight.w600)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                          ),
                                          onPressed: hasLast ? null : () => _navigateToInput(item),
                                          child: const Text('Input', style: TextStyle(fontWeight: FontWeight.w600)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  if (_isSavingBatch)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(color: AppColors.primary),
                              const SizedBox(height: 16),
                              Text(
                                'Mengirim $_batchCompleted/$_batchTotal',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _batchTotal > 0 ? '${((_batchCompleted / _batchTotal) * 100).toInt()}%' : '0%',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
