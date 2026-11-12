import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/file_viewer_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/models/kegiatan_sosial_model.dart';
import '../cubit/kegiatan_sosial_cubit.dart';
import '../widgets/history_detail_widgets.dart';

class RiwayatKegiatanSosialListPage extends StatefulWidget {
  final String identifier;
  final String? namaAktivitas;
  final String? pelakuAktivitasSosial;

  const RiwayatKegiatanSosialListPage({
    super.key,
    required this.identifier,
    this.namaAktivitas,
    this.pelakuAktivitasSosial,
  });

  @override
  State<RiwayatKegiatanSosialListPage> createState() => _RiwayatKegiatanSosialListPageState();
}

class _RiwayatKegiatanSosialListPageState extends State<RiwayatKegiatanSosialListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<KegiatanSosialCubit>().loadHistoryByIdentifier(widget.identifier);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<KegiatanSosialCubit>().loadMoreHistoryByIdentifier(widget.identifier);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String? status) {
    final upper = (status ?? '').toUpperCase();
    if (upper == 'KRITIS') return const Color(0xFFEF4444);
    if (upper == 'WASPADA') return const Color(0xFFF97316);
    if (upper == 'BAHAYA') return const Color(0xFFEAB308);
    return const Color(0xFF22C55E);
  }

  bool _isEditable(KegiatanSosialHistoryItemModel item, List<String> roles) {
    final raw = item.rawJson;
    final ttdTLGI = item.ttdTLGI ?? raw['ttdTLGI'];
    final namaTTDTLGI = item.namaTTDTLGI ?? raw['namaTTDTLGI'];
    final ttdLW = item.ttdLineWalker ?? raw['ttdLineWalker'];
    final namaLW = item.namaTTDLineWalker ?? raw['namaTTDLineWalker'];

    final hasTLGI = ttdTLGI != null && ttdTLGI.toString().isNotEmpty &&
        namaTTDTLGI != null && namaTTDTLGI.toString().isNotEmpty;

    if (roles.contains('Team Leader GI')) {
      return !hasTLGI;
    }

    final hasLW = ttdLW != null && ttdLW.toString().isNotEmpty &&
        namaLW != null && namaLW.toString().isNotEmpty;

    return !hasTLGI || !hasLW;
  }

  void _showActionBottomSheet(BuildContext context, KegiatanSosialHistoryItemModel item) {
    final authState = context.read<AuthBloc>().state;
    final roles = authState is AuthAuthenticated ? authState.user.roles : <String>[];
    final isCanEdit = _isEditable(item, roles);

    const viewerRoles = [
      'Viewer PLN UIT',
      'Viewer PLN UPT',
      'Viewer PLN ULTG',
    ];
    final isViewer = viewerRoles.any((r) => roles.contains(r));
    final canSign = isCanEdit && !isViewer;

    final cubit = context.read<KegiatanSosialCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        bool isDownloading = false;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Aksi',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: isDownloading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download_rounded, color: AppColors.primary),
                      title: const Text('Download Berita Acara'),
                      onTap: isDownloading
                          ? null
                          : () async {
                              setModalState(() => isDownloading = true);
                              try {
                                final filePath = await cubit.downloadBA(item);
                                if (bottomSheetContext.mounted) {
                                  Navigator.pop(bottomSheetContext);
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Berita Acara berhasil diunduh: $filePath'),
                                      backgroundColor: Colors.green,
                                      action: SnackBarAction(
                                        label: 'Buka',
                                        textColor: Colors.white,
                                        onPressed: () => FileViewerHelper.openFile(
                                          filePath,
                                          context: context,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isDownloading = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Terdapat kesalahan saat mengunduh file!')),
                                  );
                                }
                              }
                            },
                    ),
                    if (canSign)
                      ListTile(
                        leading: const Icon(Icons.edit_document, color: AppColors.primary),
                        title: const Text('Lengkapi Tanda Tangan'),
                        onTap: () async {
                          Navigator.pop(bottomSheetContext);
                          final res = await context.push(
                            '/update-kegiatan-sosial',
                            extra: item.rawJson.isNotEmpty
                                ? item.rawJson
                                : {
                                    'id': item.id,
                                    'tower': {'id': item.towerId, 'nama': item.namaTower},
                                    'jenisAktivitas': item.jenisAktivitas,
                                    'statusAktivitas': item.statusAktivitas,
                                    'pelakuAktivitasSosial': item.pelakuAktivitasSosial,
                                  },
                          );
                          if (res == true && context.mounted) {
                            context.read<KegiatanSosialCubit>().loadHistoryByIdentifier(widget.identifier);
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

  Widget _buildItemCard(BuildContext context, KegiatanSosialHistoryItemModel item) {
    final hasTtdTLGI = item.ttdTLGI != null && item.ttdTLGI!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                color: hasTtdTLGI ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                child: Text(
                  'TTD TL GI',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: hasTtdTLGI ? const Color(0xFF166534) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    item.namaTower ?? 'Tower',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.pelakuAktivitasSosial ?? widget.pelakuAktivitasSosial ?? '-'} - ${item.namaAktivitas ?? widget.namaAktivitas ?? '-'}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, size: 12, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            formatHistoryDate(item.createdAt),
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        height: 12,
                        width: 1,
                        color: const Color(0xFFCBD5E1),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getStatusColor(item.kategoriAktivitas),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.kategoriAktivitas,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF334155)),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        height: 12,
                        width: 1,
                        color: const Color(0xFFCBD5E1),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.notifications_none, size: 12, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                item.statusObjek ?? '-',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF334155)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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
                            context.push(
                              '/riwayat-kegiatan-sosial-detail',
                              extra: item.rawJson.isNotEmpty ? item.rawJson : item,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text(
                            'Lihat',
                            style: TextStyle(fontSize: 13, color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => _showActionBottomSheet(context, item),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        ),
                        child: const Icon(Icons.more_vert, size: 20, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pelakuAktivitasSosial != null && widget.namaAktivitas != null
              ? '${widget.pelakuAktivitasSosial} - ${widget.namaAktivitas}'
              : (widget.namaAktivitas ?? 'Daftar Pembaruan Kegiatan Sosial'),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<KegiatanSosialCubit>().loadHistoryByIdentifier(widget.identifier);
            },
          ),
        ],
      ),
      body: AppBackground(
        child: BlocBuilder<KegiatanSosialCubit, KegiatanSosialState>(
          builder: (context, state) {
            if (state is KegiatanSosialLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is KegiatanSosialHistoryLoaded) {
              final items = state.items;
              if (items.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => context.read<KegiatanSosialCubit>().loadHistoryByIdentifier(widget.identifier),
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
                onRefresh: () => context.read<KegiatanSosialCubit>().loadHistoryByIdentifier(widget.identifier),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
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
                    return _buildItemCard(context, item);
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
