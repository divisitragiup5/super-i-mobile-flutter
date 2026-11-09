import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../data/models/kegiatan_sosial_model.dart';
import '../widgets/history_detail_widgets.dart';

class RiwayatKegiatanSosialDetailPage extends StatelessWidget {
  final dynamic data;

  const RiwayatKegiatanSosialDetailPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> item = {};
    if (data is Map<String, dynamic>) {
      item = data;
    } else if (data is KegiatanSosialHistoryItemModel) {
      final model = data as KegiatanSosialHistoryItemModel;
      item = model.rawJson.isNotEmpty
          ? model.rawJson
          : {
              'id': model.id,
              'tower': {'nama': model.namaTower},
              'jenisAktivitas': model.jenisAktivitas,
              'statusAktivitas': model.statusAktivitas,
              'pelakuAktivitasSosial': model.pelakuAktivitasSosial,
              'createdAt': model.createdAt,
            };
    }

    final towerName = item['tower'] is Map ? item['tower']['nama']?.toString() : 'Tower';
    final petugas = item['petugasLineWalker'] is Map && item['petugasLineWalker']['petugas'] is Map && item['petugasLineWalker']['petugas']['user'] is Map
        ? item['petugasLineWalker']['petugas']['user']['namaLengkap']?.toString()
        : (item['petugasLineWalker'] is Map ? item['petugasLineWalker']['namaLengkap']?.toString() : null);
    final createdAt = item['createdAt'];

    final jenisAktivitas = item['jenisAktivitas']?.toString() ?? '-';
    final statusAktivitas = item['statusAktivitas']?.toString() ?? '-';
    final progresPenanganan = item['progresPenanganan']?.toString() ?? '-';
    final kategoriAktivitas = item['kategoriAktivitas']?.toString() ?? '-';
    final tindakan = item['tindakan']?.toString() ?? '-';
    final statusObjek = item['statusObjek']?.toString() ?? '-';
    final keterangan = item['keterangan']?.toString() ?? '-';

    final temuan = item['temuan']?.toString() ?? '-';
    final jumlahTemuan = item['jumlahTemuan']?.toString() ?? '0';

    final pelakuAktivitasSosial = item['pelakuAktivitasSosial']?.toString() ?? '-';
    final tanggapan = item['tanggapan']?.toString() ?? '-';
    final suratSosialisasi = item['suratSosialisasi'];

    final pictAktivitas = item['dokumentasiAktivitasSosial'] is Map
        ? item['dokumentasiAktivitasSosial']['uri']?.toString()
        : item['dokumentasiAktivitasSosial']?.toString();

    final pictSosialisasi = item['dokumentasiSosialisasi'] is Map
        ? item['dokumentasiSosialisasi']['uri']?.toString()
        : item['dokumentasiSosialisasi']?.toString();

    final ttdLW = item['ttdLineWalker']?.toString();
    final namaLW = item['namaTTDLineWalker']?.toString();

    final ttdTLGI = item['ttdTLGI']?.toString();
    final namaTLGI = item['namaTTDTLGI']?.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rincian Kegiatan Sosial'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HistoryInputContainer(
                label: 'INFORMASI',
                children: [
                  HistoryInputWithLabel(
                    label: 'Nama',
                    isFirst: true,
                    child: Text(
                      towerName ?? '-',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ),
                  if (petugas != null && petugas.isNotEmpty)
                    HistoryInputWithLabel(
                      label: 'Petugas',
                      child: Text(
                        petugas,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                      ),
                    ),
                  HistoryInputWithLabel(
                    label: 'Tanggal',
                    child: Text(
                      formatHistoryDate(createdAt),
                      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                  ),
                ],
              ),

              HistoryInputContainer(
                label: 'AKTIVITAS',
                children: [
                  HistoryInputWithLabel(
                    label: 'Jenis Aktivitas',
                    isFirst: true,
                    child: Text(jenisAktivitas, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                  HistoryInputWithLabel(
                    label: 'Status Aktivitas',
                    child: Text(statusAktivitas, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                  HistoryInputWithLabel(
                    label: 'Progres Penanganan',
                    child: Text(progresPenanganan, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                  HistoryInputWithLabel(
                    label: 'Kategori Aktivitas',
                    child: Text(kategoriAktivitas, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                  HistoryInputWithLabel(
                    label: 'Tindakan',
                    child: Text(tindakan, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                  HistoryInputWithLabel(
                    label: 'Status Objek',
                    child: Text(statusObjek, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                  HistoryInputWithLabel(
                    label: 'Keterangan Aktivitas',
                    child: Text(keterangan, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                ],
              ),

              HistoryInputContainer(
                label: 'Temuan',
                children: [
                  HistoryInputWithLabel(
                    label: 'Temuan',
                    isFirst: true,
                    child: Text(temuan, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                  HistoryInputWithLabel(
                    label: 'Jumlah Temuan',
                    child: Text(jumlahTemuan, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                ],
              ),

              HistoryInputContainer(
                label: 'PENDUKUNG',
                children: [
                  HistoryInputWithLabel(
                    label: 'Pelaku Aktivitas Sosial',
                    isFirst: true,
                    child: Text(pelakuAktivitasSosial, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                  HistoryInputWithLabel(
                    label: 'Tanggapan',
                    child: Text(tanggapan, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                  HistoryInputWithLabel(
                    label: 'Surat Sosialisasi',
                    child: Text(
                      formatHistoryDate(suratSosialisasi, 'dd MMMM yyyy'),
                      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                  ),
                ],
              ),

              HistoryInputContainer(
                label: 'DOKUMENTASI',
                children: [
                  HistoryInputWithLabel(
                    label: 'Dokumentasi Kegiatan Aktivitas Sosial',
                    isFirst: true,
                    child: HistoryImageDisplay(url: pictAktivitas),
                  ),
                  HistoryInputWithLabel(
                    label: 'Dokumentasi Sosialisasi Aktivitas Sosial',
                    child: HistoryImageDisplay(url: pictSosialisasi),
                  ),
                ],
              ),

              HistoryInputContainer(
                label: 'TANDA TANGAN',
                children: [
                  HistoryInputWithLabel(
                    label: 'Line Walker',
                    isFirst: true,
                    child: HistorySignatureDisplay(url: ttdLW, label: namaLW),
                  ),
                  HistoryInputWithLabel(
                    label: 'Team Leader GI',
                    child: HistorySignatureDisplay(url: ttdTLGI, label: namaTLGI),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
