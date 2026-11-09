import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/router/route_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../cubit/drafts_cubit.dart';

class OfflineDraftsCard extends StatelessWidget {
  const OfflineDraftsCard({super.key});

  void _handleOpenDraft(BuildContext context, Map<String, dynamic> draft) {
    final type = draft['type']?.toString().toLowerCase();
    final draftId = draft['id'] is int
        ? draft['id'] as int
        : int.tryParse('${draft['id']}');

    Map<String, dynamic>? parsedData;
    final rawData = draft['data'];
    if (rawData is Map<String, dynamic>) {
      parsedData = rawData;
    } else if (rawData is Map) {
      parsedData = Map<String, dynamic>.from(rawData);
    } else if (rawData is String && rawData.isNotEmpty) {
      try {
        parsedData = jsonDecode(rawData) as Map<String, dynamic>?;
      } catch (_) {}
    }

    final draftsCubit = context.read<DraftsCubit>();

    if (type == 'waterpass') {
      context
          .push(AppRoutes.waterpass, extra: {
            'draft': parsedData,
            'draftId': draftId,
          })
          .then((_) => draftsCubit.loadDrafts());
    } else if (type == 'pembumian') {
      context
          .push(AppRoutes.pembumian, extra: {
            'draft': parsedData,
            'draftId': draftId,
          })
          .then((_) => draftsCubit.loadDrafts());
    } else if (type == 'ppl') {
      context
          .push(AppRoutes.ppl, extra: {
            'draft': parsedData,
            'draftId': draftId,
          })
          .then((_) => draftsCubit.loadDrafts());
    } else if (type == 'kegiatan-sosial') {
      context
          .push(AppRoutes.kegiatanSosial, extra: {
            'draft': parsedData,
            'draftId': draftId,
          })
          .then((_) => draftsCubit.loadDrafts());
    } else if (type == 'beban-trafo') {
      context
          .push(AppRoutes.inputBebanTrafo, extra: parsedData)
          .then((_) => draftsCubit.loadDrafts());
    } else if (type == 'beban-penyulang') {
      context
          .push(AppRoutes.inputBebanPenyulang, extra: parsedData)
          .then((_) => draftsCubit.loadDrafts());
    } else if (type == 'tegangan-trafo') {
      context
          .push(AppRoutes.inputTeganganTrafo, extra: parsedData)
          .then((_) => draftsCubit.loadDrafts());
    } else if (type == 'kwh-harian') {
      context
          .push(AppRoutes.inputKwhHarian, extra: parsedData)
          .then((_) => draftsCubit.loadDrafts());
    } else if (type == 'il1-sipil') {
      context
          .push(AppRoutes.inputIl1Sipil, extra: parsedData)
          .then((_) => draftsCubit.loadDrafts());
    } else if (type == 'il1-kubikel') {
      context
          .push(AppRoutes.inputIl1Kubikel, extra: parsedData)
          .then((_) => draftsCubit.loadDrafts());
    } else if (type == 'il1-trafo-ps') {
      context
          .push(AppRoutes.inputIl1TrafoPs, extra: parsedData)
          .then((_) => draftsCubit.loadDrafts());
    } else if (type == 'anomali-gi') {
      context
          .push(AppRoutes.inputAnomaliGi, extra: parsedData)
          .then((_) => draftsCubit.loadDrafts());
    }
  }

  void _handleDeleteDraft(BuildContext context, int id, {bool isGi = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Draft'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus draft offline ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<DraftsCubit>().deleteDraft(id, isGi: isGi);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDraftDate(dynamic dateVal) {
    if (dateVal == null) return '';
    try {
      final dt = DateTime.parse(dateVal.toString());
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) {
        return 'Baru saja';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes} mnt lalu';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} jam lalu';
      } else {
        return DateFormat('dd MMM, HH:mm').format(dt);
      }
    } catch (_) {
      return dateVal.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DraftsCubit, DraftsState>(
      builder: (context, state) {
        if (state is! DraftsLoaded || state.drafts.isEmpty) {
          return const SizedBox.shrink();
        }

        final drafts = state.drafts;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Draft Belum Tersimpan (${drafts.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 128,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: drafts.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final draft = drafts[index];
                  final id = draft['id'] is int
                      ? draft['id'] as int
                      : int.tryParse('${draft['id']}') ?? 0;
                  final isGi = draft['isGi'] == true;
                  final rawType = (draft['type'] as String? ?? 'DRAFT').toUpperCase();
                  final dateText = _formatDraftDate(draft['date']);

                  return InkWell(
                    onTap: () => _handleOpenDraft(context, draft),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 230,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  rawType,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: AppColors.danger,
                                ),
                                onPressed: () => _handleDeleteDraft(
                                  context,
                                  id,
                                  isGi: isGi,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            draft['nama'] as String? ?? 'Data Pekerjaan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.touch_app,
                                    size: 13,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Lanjutkan draft',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              if (dateText.isNotEmpty)
                                Text(
                                  dateText,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textDisabled,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
