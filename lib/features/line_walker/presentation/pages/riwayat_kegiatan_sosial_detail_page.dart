import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/kegiatan_sosial_model.dart';

class RiwayatKegiatanSosialDetailPage extends StatelessWidget {
  final dynamic data;

  const RiwayatKegiatanSosialDetailPage({
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

  Widget _buildSignatureTile(BuildContext context, String label, String? name, String? url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(name ?? '-', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        if (url != null && url.isNotEmpty)
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.white,
            ),
            child: Image.network(url, fit: BoxFit.contain),
          )
        else
          const Text('Belum ditandatangani', style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> itemMap = {};
    if (data is Map<String, dynamic>) {
      itemMap = data;
    } else if (data is KegiatanSosialHistoryItemModel) {
      itemMap = {
        'id': data.id,
        'tower': {'nama': data.namaTower},
        'jenisAktivitas': data.jenisAktivitas,
        'statusAktivitas': data.statusAktivitas,
        'pelakuAktivitasSosial': data.pelakuAktivitasSosial,
        'createdAt': data.createdAt,
      };
    }

    final towerName = itemMap['tower'] is Map ? itemMap['tower']['nama']?.toString() : 'Tower';
    final jenisAktivitas = itemMap['jenisAktivitas']?.toString() ?? '-';
    final statusAktivitas = itemMap['statusAktivitas']?.toString() ?? '-';
    final progresPenanganan = itemMap['progresPenanganan']?.toString() ?? '-';
    final tindakan = itemMap['tindakan']?.toString() ?? '-';
    final keterangan = itemMap['keterangan']?.toString() ?? '-';
    final statusObjek = itemMap['statusObjek']?.toString() ?? '-';
    final pelaku = itemMap['pelakuAktivitasSosial']?.toString() ?? '-';
    final tanggapan = itemMap['tanggapan']?.toString() ?? '-';
    final temuan = itemMap['temuan']?.toString() ?? 'TIDAK ADA TEMUAN';
    final jumlahTemuan = itemMap['jumlahTemuan']?.toString();
    final lokasi = itemMap['lokasi']?.toString() ?? '-';
    final createdAt = itemMap['createdAt']?.toString() ?? '-';

    final pictSosialisasi = itemMap['dokumentasiSosialisasi'] is Map ? itemMap['dokumentasiSosialisasi']['uri']?.toString() : null;
    final pictAktivitas = itemMap['dokumentasiAktivitasSosial'] is Map ? itemMap['dokumentasiAktivitasSosial']['uri']?.toString() : null;

    final ttdLWUrl = itemMap['ttdLineWalker']?.toString();
    final namaLW = itemMap['namaTTDLineWalker']?.toString();
    final ttdTLGIUrl = itemMap['ttdTLGI']?.toString();
    final namaTLGI = itemMap['namaTTDTLGI']?.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rincian Kegiatan Sosial'),
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
                      'INFORMASI KEGIATAN SOSIAL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Objek: $towerName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Jenis Aktivitas: $jenisAktivitas', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text('Tanggal: $createdAt'),
                    const Divider(height: 24),
                    Text('Status Aktivitas: $statusAktivitas'),
                    const SizedBox(height: 4),
                    Text('Progres Penanganan: $progresPenanganan'),
                    const SizedBox(height: 4),
                    Text('Tindakan: $tindakan'),
                    const SizedBox(height: 4),
                    Text('Keterangan: $keterangan'),
                    const SizedBox(height: 4),
                    Text('Status Objek: $statusObjek'),
                    const SizedBox(height: 4),
                    Text('Pelaku: $pelaku'),
                    const SizedBox(height: 4),
                    Text('Tanggapan: $tanggapan'),
                    const SizedBox(height: 4),
                    Text('Temuan: $temuan ${jumlahTemuan != null ? '($jumlahTemuan temuan)' : ''}'),
                    const SizedBox(height: 4),
                    Text('Lokasi: $lokasi'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dokumentasi Foto
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DOKUMENTASI FOTO',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildImageTile(context, 'Dokumentasi Sosialisasi', pictSosialisasi),
                    _buildImageTile(context, 'Dokumentasi Aktivitas Sosial', pictAktivitas),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tanda Tangan
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TANDA TANGAN DIGITAL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSignatureTile(context, 'Line Walker', namaLW, ttdLWUrl),
                    _buildSignatureTile(context, 'Team Leader GI', namaTLGI, ttdTLGIUrl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
