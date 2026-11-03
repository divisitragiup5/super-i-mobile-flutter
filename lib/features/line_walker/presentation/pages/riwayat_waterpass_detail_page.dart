import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/waterpass_model.dart';

class RiwayatWaterpassDetailPage extends StatelessWidget {
  final WaterpassDetailModel item;

  const RiwayatWaterpassDetailPage({
    super.key,
    required this.item,
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

  Widget _buildAxisCard(BuildContext context, String axisName, double? hasil, String? photoUrl) {
    if (hasil == null && (photoUrl == null || photoUrl.isEmpty)) return const SizedBox.shrink();

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
              axisName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            if (hasil != null) ...[
              const Text(
                'Nilai Hasil',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 4),
              Text(
                hasil.toString(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
            ],
            if (photoUrl != null) _buildImageTile(context, 'Foto Bukti $axisName', photoUrl),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rincian Waterpass'),
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
                      item.namaTower ?? '-',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text('Tanggal Inspeksi', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    Text(
                      item.createdAt ?? '-',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Foto Sebelum
            if (item.fotoSebelumUrl != null)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildImageTile(context, 'FOTO SEBELUM INSPEKSI', item.fotoSebelumUrl),
                ),
              ),
            const SizedBox(height: 16),

            // Sumbu X, Y, Z
            _buildAxisCard(context, 'WATERPASS X', item.hasilX, item.fotoXUrl),
            _buildAxisCard(context, 'WATERPASS Y', item.hasilY, item.fotoYUrl),
            _buildAxisCard(context, 'WATERPASS Z', item.hasilZ, item.fotoZUrl),

            // Foto Setelah
            if (item.fotoSetelahUrl != null)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildImageTile(context, 'FOTO SETELAH INSPEKSI', item.fotoSetelahUrl),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
