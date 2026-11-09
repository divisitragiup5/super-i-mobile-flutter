import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../data/models/ketenagakerjaan_model.dart';

class KetenagakerjaanDetailPage extends StatelessWidget {
  final KetenagakerjaanItemModel item;

  const KetenagakerjaanDetailPage({
    super.key,
    required this.item,
  });

  Color _getHighlight(String type, String? kategori) {
    if (kategori == null) return const Color(0xFF0F172A);
    final k = kategori.toLowerCase();
    if (type == 'status') {
      if (k.contains('peringatan')) return const Color(0xFFEF4444);
      if (k.contains('teguran')) return const Color(0xFFEAB308);
      return const Color(0xFF22C55E);
    } else if (type == 'kategoriCOC') {
      if (k == 'tidak-hadir') return const Color(0xFFEF4444);
      if (k == 'kendala') return const Color(0xFFEAB308);
      return const Color(0xFF22C55E);
    } else if (type == 'kategoriDurasiInspeksi') {
      if (k == 'tidak-sesuai') return const Color(0xFFEF4444);
      if (k == 'perhatian') return const Color(0xFFEAB308);
      return const Color(0xFF22C55E);
    } else if (type == 'kategoriKehadiran') {
      if (k == 'tidak-masuk') return const Color(0xFFEF4444);
      if (k == 'telat') return const Color(0xFFEAB308);
      return const Color(0xFF22C55E);
    } else if (type == 'kategoriKepatuhan') {
      if (k == 'belum') return const Color(0xFFEF4444);
      return const Color(0xFF22C55E);
    }
    return const Color(0xFF0F172A);
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  Widget _buildRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getHighlight('status', item.status);
    final totalPenambah = item.kegiatanSosial.fold(0.0, (acc, curr) => acc + curr.poin);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rincian Ketenagakerjaan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card 1: Informasi
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
                      _buildRow('Nama', item.namaPetugas ?? '-', isBold: true),
                      _buildRow('Tanggal', 'Minggu ke ${item.minggu} ${_capitalize(item.bulan)} ${item.tahun}'),
                      _buildRow('Score', item.score.toStringAsFixed(2), isBold: true),
                      _buildRow('Status', item.status, valueColor: statusColor, isBold: true),
                      if (totalPenambah > 0)
                        _buildRow('Penambah', '+${totalPenambah.toStringAsFixed(2)} Poin', valueColor: Colors.green, isBold: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Card 2: Pengurang
              if (item.pengurang.isNotEmpty) ...[
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PENGURANG',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.danger,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...item.pengurang.map(
                          (p) => _buildRow(p.type, '-${p.poin.toStringAsFixed(2)} Poin', valueColor: Colors.red, isBold: true),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Card 3: Nilai
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'KOMPONEN PENILAIAN',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildRow('Kepatuhan', item.kepatuhan),
                      _buildRow(
                        'Point Kepatuhan',
                        item.pointKepatuhan.toStringAsFixed(2),
                        valueColor: _getHighlight('kategoriKepatuhan', item.kategoriKepatuhan),
                        isBold: true,
                      ),
                      const Divider(height: 16),
                      _buildRow('Durasi', item.durasi),
                      _buildRow('Ketentuan', item.ketentuan.toStringAsFixed(2)),
                      _buildRow('Kinerja', '${(item.kinerja * 100).toStringAsFixed(1)}%'),
                      _buildRow(
                        'Point Durasi',
                        item.pointDurasi.toStringAsFixed(2),
                        valueColor: _getHighlight('kategoriDurasiInspeksi', item.kategoriDurasiInspeksi),
                        isBold: true,
                      ),
                      const Divider(height: 16),
                      _buildRow('Absensi', item.absensi),
                      if (item.bantuanAbsensi != null)
                        _buildRow('Bantuan Absensi', item.bantuanAbsensi!),
                      _buildRow(
                        'Point Absensi',
                        item.pointAbsensi.toStringAsFixed(2),
                        valueColor: _getHighlight('kategoriKehadiran', item.kategoriKehadiran),
                        isBold: true,
                      ),
                      const Divider(height: 16),
                      _buildRow('COC', item.coc),
                      if (item.bantuanCOC != null)
                        _buildRow('Bantuan COC', item.bantuanCOC!),
                      _buildRow(
                        'Point COC',
                        item.pointCOC.toStringAsFixed(2),
                        valueColor: _getHighlight('kategoriCOC', item.kategoriCOC),
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
