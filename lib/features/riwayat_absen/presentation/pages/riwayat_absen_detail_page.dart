import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_url_utils.dart';
import '../../data/models/riwayat_absen_model.dart';

class RiwayatAbsenDetailPage extends StatelessWidget {
  final RiwayatAbsenItemModel item;

  const RiwayatAbsenDetailPage({super.key, required this.item});

  String _formatShiftTime(int? jam, int? menit) {
    if (jam == null && menit == null) return '--:--';
    final h = (jam ?? 0).toString().padLeft(2, '0');
    final m = (menit ?? 0).toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(String? dateStr, String pattern) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat(pattern, 'id_ID').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  void _showEnlargedImage(BuildContext context, String url, String title) {
    final fullUrl = AppUrlUtils.getFullImageUrl(url);
    if (fullUrl.isEmpty) return;

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.black87,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.network(
                      fullUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          'Gagal memuat gambar',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(dialogCtx),
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
        title: const Text('Detail Absensi'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.backgroundLight,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'INFORMASI ABSENSI',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'Tanggal',
                        _formatDate(item.createdAt, 'dd MMMM yyyy'),
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        'Keterangan',
                        item.keterangan ?? '-',
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        'Shift',
                        '${_formatShiftTime(item.jamMasuk, item.menitMasuk)} - ${_formatShiftTime(item.jamKeluar, item.menitKeluar)}',
                      ),
                      if (item.premi == 'OFF') ...[
                        const Divider(height: 20),
                        const Text(
                          'Petugas Yang Menggantikan:',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (item.digantikan.isEmpty)
                          const Text(
                            '-',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else
                          ...item.digantikan.map(
                            (d) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• ${d.namaPetugas ?? 'Petugas'} (${_formatShiftTime(d.startHour, d.startMinute)} - ${_formatShiftTime(d.endHour, d.endMinute)})',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        if (item.izin != null && item.izin!.isNotEmpty) ...[
                          const Divider(height: 20),
                          _buildInfoRow('Izin', item.izin!),
                        ],
                        if (item.diagnosaSakit != null &&
                            item.diagnosaSakit!.isNotEmpty) ...[
                          const Divider(height: 20),
                          _buildInfoRow('Diagnosa Sakit', item.diagnosaSakit!),
                        ],
                        if (item.fotoBuktiPremi != null &&
                            item.fotoBuktiPremi!.isNotEmpty) ...[
                          const Divider(height: 20),
                          const Text(
                            'Dokumen Bukti:',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildImageThumbnail(
                            context,
                            item.fotoBuktiPremi!,
                            'Dokumen Bukti Sakit/Izin',
                          ),
                        ],
                      ] else ...[
                        const Divider(height: 20),
                        _buildInfoRow(
                          'Durasi Kerja',
                          item.durasiKerja != null
                              ? '${(item.durasiKerja! / 60).toStringAsFixed(1)} Jam'
                              : '-',
                        ),
                        if (item.namaPengganti != null) ...[
                          const Divider(height: 20),
                          _buildInfoRow('Menggantikan', item.namaPengganti!),
                        ],
                        const Divider(height: 20),
                        _buildInfoRow(
                          'Absen Masuk',
                          '${_formatDate(item.absenMasuk, 'dd MMM yyyy, HH:mm')} - ${item.statusIn == 'ON TIME' ? item.statusIn : '(${item.statusIn} ${item.durasiTelatIn ?? 0} MENIT)'}',
                        ),
                        if (item.pictureInUri != null &&
                            item.pictureInUri!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildImageThumbnail(
                            context,
                            item.pictureInUri!,
                            'Foto Absen Masuk',
                          ),
                        ],
                        const Divider(height: 20),
                        _buildInfoRow(
                          'Absen Keluar',
                          item.absenKeluar != null
                              ? '${_formatDate(item.absenKeluar, 'dd MMM yyyy, HH:mm')} - ${item.statusOut == 'ON TIME' ? item.statusOut : '(${item.statusOut} ${item.durasiTelatOut ?? 0} MENIT)'}'
                              : 'Belum Absen',
                        ),
                        if (item.pictureOutUri != null &&
                            item.pictureOutUri!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildImageThumbnail(
                            context,
                            item.pictureOutUri!,
                            'Foto Absen Keluar',
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumbnail(
    BuildContext context,
    String url,
    String title,
  ) {
    final fullUrl = AppUrlUtils.getFullImageUrl(url);
    if (fullUrl.isEmpty) {
      return Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: const Center(
          child: Text(
            'Tidak ada foto',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showEnlargedImage(context, fullUrl, title),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade100,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              fullUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.zoom_in, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Perbesar',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
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
