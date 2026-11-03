import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/pembumian_model.dart';

class RiwayatPembumianDetailPage extends StatelessWidget {
  final dynamic data;

  const RiwayatPembumianDetailPage({
    super.key,
    required this.data,
  });

  void _showImageZoom(BuildContext context, String? url) {
    if (url == null || url.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile(BuildContext context, String label, String? url) {
    if (url == null || url.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _showImageZoom(context, url),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildLegTile(BuildContext context, String title, Map<String, dynamic>? leg) {
    if (leg == null) return const SizedBox.shrink();
    final hasil = leg['hasil']?.toString();
    final status = leg['status']?.toString();
    final pictUrl = leg['pict'] is Map ? leg['pict']['uri']?.toString() : null;
    final statusPictUrl = leg['statusPict'] is Map ? leg['statusPict']['uri']?.toString() : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            if (hasil != null) Text('Hasil: $hasil Ohm', style: const TextStyle(fontWeight: FontWeight.w600)),
            if (status != null) Text('Status: $status', style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            if (pictUrl != null) _buildImageTile(context, 'Foto Hasil $title', pictUrl),
            if (statusPictUrl != null) _buildImageTile(context, 'Foto Status $title', statusPictUrl),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> itemMap = {};
    if (data is Map<String, dynamic>) {
      itemMap = data;
    } else if (data is PembumianHistoryItemModel) {
      itemMap = {
        'tower': {'nama': data.namaTower},
        'createdAt': data.createdAt,
        'kendala': data.kendala,
      };
    }

    final towerName = itemMap['tower'] is Map ? itemMap['tower']['nama']?.toString() : 'Tower';
    final createdAt = itemMap['createdAt']?.toString() ?? '-';
    final fotoSebelum = itemMap['fotoTowerSebelumInspeksi'] is Map ? itemMap['fotoTowerSebelumInspeksi']['uri']?.toString() : null;
    final fotoSetelah = itemMap['fotoTowerSetelahInspeksi'] is Map ? itemMap['fotoTowerSetelahInspeksi']['uri']?.toString() : null;
    final anomali = itemMap['anomali'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rincian Pembumian'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Header
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'INFORMASI',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Nama Objek', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    Text(
                      towerName ?? '-',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text('Tanggal Inspeksi', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    Text(
                      createdAt,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (fotoSebelum != null)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildImageTile(context, 'FOTO SEBELUM INSPEKSI', fotoSebelum),
                ),
              ),

            // Legs
            _buildLegTile(context, 'LEG A', itemMap['legA'] as Map<String, dynamic>?),
            _buildLegTile(context, 'LEG B', itemMap['legB'] as Map<String, dynamic>?),
            _buildLegTile(context, 'LEG C', itemMap['legC'] as Map<String, dynamic>?),
            _buildLegTile(context, 'LEG D', itemMap['legD'] as Map<String, dynamic>?),
            _buildLegTile(context, 'IGSW', itemMap['IGSW'] as Map<String, dynamic>?),
            _buildLegTile(context, 'GROUNDING LANGSUNG', itemMap['groundingLangsung'] as Map<String, dynamic>?),
            _buildLegTile(context, 'BERSAMA', itemMap['bersama'] as Map<String, dynamic>?),
            _buildLegTile(context, 'MDG', itemMap['MDG'] as Map<String, dynamic>?),

            if (anomali != null) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ANOMALI',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Catatan: ${anomali['catatan'] ?? '-'}'),
                      const SizedBox(height: 12),
                      if (anomali['pict'] is Map)
                        _buildImageTile(context, 'Foto Anomali', anomali['pict']['uri']?.toString()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (fotoSetelah != null)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildImageTile(context, 'FOTO SETELAH INSPEKSI', fotoSetelah),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
