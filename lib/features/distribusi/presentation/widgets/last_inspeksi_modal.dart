import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/color_parser.dart';
import '../../data/models/sutm_workorder_model.dart';
import '../../data/models/yantek_asset_model.dart';

class LastInspeksiModal extends StatefulWidget {
  final YantekAssetModel asset;

  const LastInspeksiModal({super.key, required this.asset});

  static void show(BuildContext context, YantekAssetModel asset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LastInspeksiModal(asset: asset),
    );
  }

  @override
  State<LastInspeksiModal> createState() => _LastInspeksiModalState();
}

class _LastInspeksiModalState extends State<LastInspeksiModal> {
  int _activeStep = 0;

  List<String> _extractSubs() {
    final lastInspeksi = widget.asset.lastInspeksi;
    if (lastInspeksi == null) return [];
    final set = <String>{};
    if (lastInspeksi.komponen != null) {
      for (final k in lastInspeksi.komponen!) {
        if (k is Map && k['sub'] != null) {
          set.add(k['sub'].toString());
        }
      }
    }
    if (lastInspeksi.row != null && lastInspeksi.row!.isNotEmpty) {
      set.add('ROW');
    }
    if (lastInspeksi.kendala != null && lastInspeksi.kendala!.isNotEmpty) {
      set.add('KENDALA');
    }
    return set.toList();
  }

  void _openLightbox(String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: Colors.black.withValues(alpha: 0.95),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                maxScale: 4.0,
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final lastInspeksi = asset.lastInspeksi;
    final subs = _extractSubs();
    final currentSub = subs.isNotEmpty && _activeStep < subs.length
        ? subs[_activeStep]
        : '';

    final healthColor = ColorParser.parse(
      lastInspeksi?.healthIndex?.color,
      fallback: const Color(0xFFF59E0B),
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              asset.idAsset,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          if (lastInspeksi?.healthIndex != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: healthColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                lastInspeksi!.healthIndex!.name ?? 'HI',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                          if (lastInspeksi?.status != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(6),
                                border:
                                    Border.all(color: const Color(0xFFA7F3D0)),
                              ),
                              child: Text(
                                lastInspeksi!.status!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF047857),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        asset.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (lastInspeksi?.tanggal != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Inspeksi: ${_formatDate(lastInspeksi!.tanggal)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Stepper Chips for Sub Activities
          if (subs.isNotEmpty)
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: subs.length,
                itemBuilder: (context, idx) {
                  final sub = subs[idx];
                  final isSelected = idx == _activeStep;
                  return GestureDetector(
                    onTap: () => setState(() => _activeStep = idx),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        sub,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Content of Current Sub Activity
          Expanded(
            child: lastInspeksi == null
                ? const Center(
                    child: Text(
                      'Belum ada data inspeksi terakhir untuk aset ini.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  )
                : _buildSubContent(lastInspeksi, currentSub),
          ),

          // Bottom Bar: Mulai Inspeksi Yantek
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.assignment_add, size: 20),
                label: const Text(
                  'Mulai Inspeksi Yantek',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  context.push(
                    AppRoutes.inspeksiYantekInspeksiForm,
                    extra: {
                      'sutmId': asset.id.toString(),
                      'idAsset': asset.idAsset,
                      'nama': asset.nama,
                      'latitude': asset.latitude.toString(),
                      'longitude': asset.longitude.toString(),
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubContent(LastInspeksiModel lastInspeksi, String currentSub) {
    if (currentSub == 'KENDALA') {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catatan Kendala:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lastInspeksi.kendala ?? 'Tidak ada catatan kendala.',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (currentSub == 'ROW') {
      final rows = lastInspeksi.row ?? [];
      if (rows.isEmpty) {
        return const Center(child: Text('Tidak ada data ROW'));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rows.length,
        itemBuilder: (context, idx) {
          final r = rows[idx];
          final String deskripsi = r is Map
              ? (r['deskripsi'] ?? r['jarak'] ?? '').toString()
              : r.toString();
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(deskripsi.toString(), style: const TextStyle(fontSize: 13)),
          );
        },
      );
    }

    // Komponen
    final rawList = lastInspeksi.komponen ?? [];
    final matching = rawList.where((k) {
      if (k is Map) return k['sub'] == currentSub;
      return false;
    }).toList();

    if (matching.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada data komponen pada sub-aktivitas ini.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matching.length,
      itemBuilder: (context, idx) {
        final item = matching[idx] as Map<String, dynamic>;
        final komponenName = item['komponen']?.toString() ?? 'Komponen';
        final nilai = item['nilai']?.toString() ?? item['kondisi']?.toString() ?? '-';
        final fasa = item['fasa']?.toString();
        final fotoUrl = item['foto']?.toString() ?? item['attachment']?.toString();

        final isBaik = nilai.toLowerCase() == 'baik' ||
            nilai.toLowerCase() == 'ada' ||
            nilai.toLowerCase() == 'aman';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            komponenName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (fasa != null && fasa.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Fasa $fasa',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isBaik
                          ? const Color(0xFFECFDF5)
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isBaik
                            ? const Color(0xFFA7F3D0)
                            : Colors.red.shade200,
                      ),
                    ),
                    child: Text(
                      nilai,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isBaik
                            ? const Color(0xFF047857)
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              if (fotoUrl != null && fotoUrl.isNotEmpty) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _openLightbox(fotoUrl, komponenName),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      fotoUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
