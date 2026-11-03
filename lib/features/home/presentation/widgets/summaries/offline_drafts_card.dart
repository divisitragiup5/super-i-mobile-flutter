import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/router/route_constants.dart';
import '../../../../../core/storage/local_database.dart';
import '../../../../../core/theme/app_colors.dart';

class OfflineDraftsCard extends StatefulWidget {
  const OfflineDraftsCard({super.key});

  @override
  State<OfflineDraftsCard> createState() => _OfflineDraftsCardState();
}

class _OfflineDraftsCardState extends State<OfflineDraftsCard> {
  List<Map<String, dynamic>> _drafts = [];

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  void _loadDrafts() async {
    try {
      final items = await LocalDatabase.instance.getUnfinishItems();
      if (mounted) setState(() => _drafts = items);
    } catch (_) {}
  }

  void _handleOpenDraft(Map<String, dynamic> draft) {
    final type = draft['type']?.toString();
    final dataStr = draft['data']?.toString();
    final draftId = draft['id'] is int ? draft['id'] : int.tryParse('${draft['id']}');

    Map<String, dynamic>? parsedData;
    if (dataStr != null) {
      try {
        parsedData = jsonDecode(dataStr) as Map<String, dynamic>?;
      } catch (_) {}
    }

    if (type == 'waterpass') {
      context.push(AppRoutes.waterpass, extra: {'draft': parsedData, 'draftId': draftId}).then((_) => _loadDrafts());
    } else if (type == 'pembumian') {
      context.push(AppRoutes.pembumian, extra: {'draft': parsedData, 'draftId': draftId}).then((_) => _loadDrafts());
    } else if (type == 'ppl') {
      context.push(AppRoutes.ppl, extra: {'draft': parsedData, 'draftId': draftId}).then((_) => _loadDrafts());
    } else if (type == 'kegiatan-sosial') {
      context.push(AppRoutes.kegiatanSosial, extra: {'draft': parsedData, 'draftId': draftId}).then((_) => _loadDrafts());
    }
  }

  void _handleDeleteDraft(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Draft'),
        content: const Text('Apakah Anda yakin ingin menghapus draft offline ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await LocalDatabase.instance.deleteUnfinishItem(id);
              _loadDrafts();
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_drafts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Draft Belum Tersimpan (${_drafts.length})',
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
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _drafts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final draft = _drafts[index];
              final id = draft['id'] is int ? draft['id'] as int : int.tryParse('${draft['id']}') ?? 0;

              return InkWell(
                onTap: () => _handleOpenDraft(draft),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 210,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
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
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              (draft['type'] as String? ?? 'DRAFT').toUpperCase(),
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
                            onPressed: () => _handleDeleteDraft(id),
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
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.touch_app, size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          const Text(
                            'Lanjutkan draft',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
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
  }
}
