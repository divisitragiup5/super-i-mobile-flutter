import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../data/models/ppl_model.dart';
import '../widgets/history_detail_widgets.dart';

class RiwayatPPLDetailPage extends StatelessWidget {
  final dynamic data;

  const RiwayatPPLDetailPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> item = {};
    if (data is Map<String, dynamic>) {
      item = data;
    } else if (data is PPLHistoryItemModel) {
      final model = data as PPLHistoryItemModel;
      item = model.rawJson.isNotEmpty
          ? model.rawJson
          : {
              'id': model.id,
              'tower': {'nama': model.namaTower},
              'namaPekerjaan': model.namaPekerjaan,
              'statusPekerjaan': model.statusPekerjaan,
              'progressPekerjaan': model.progressPekerjaan,
              'createdAt': model.createdAt,
            };
    }

    final towerName = item['tower'] is Map ? item['tower']['nama']?.toString() : 'Tower';
    final petugas = item['petugasLineWalker'] is Map && item['petugasLineWalker']['petugas'] is Map && item['petugasLineWalker']['petugas']['user'] is Map
        ? item['petugasLineWalker']['petugas']['user']['namaLengkap']?.toString()
        : (item['petugasLineWalker'] is Map ? item['petugasLineWalker']['namaLengkap']?.toString() : null);
    final createdAt = item['createdAt'];

    final namaPekerjaan = item['namaPekerjaan']?.toString() ?? '-';
    final statusPekerjaan = item['statusPekerjaan']?.toString() ?? '-';
    final progressPekerjaan = item['progressPekerjaan']?.toString() ?? '-';

    final jenisObjek = item['jenisObjek']?.toString() ?? '-';
    final keteranganJenisObjek = item['keteranganJenisObjek']?.toString() ?? '-';
    final kategoriObjek = item['kategoriObjek']?.toString() ?? '-';
    final keteranganKategoriObjek = item['keteranganKategoriObjek']?.toString() ?? '-';
    final statusObjek = item['statusObjek']?.toString() ?? '-';

    final pihakPelaksana = item['pihakPelaksana']?.toString() ?? '-';
    final pjPekerjaan = item['pjPekerjaan']?.toString() ?? '-';
    final noTelp = item['noTeleponPJPekerjaan']?.toString() ?? '-';
    final tanggapan = item['tanggapan']?.toString() ?? '-';
    final namaValidator = item['namaValidator']?.toString() ?? '-';
    final suratSosialisasi = item['suratSosialisasi'];

    final pictPerwakilan = item['dokumentasiPerwakilan'] is Map
        ? item['dokumentasiPerwakilan']['uri']?.toString()
        : item['dokumentasiPerwakilan']?.toString();

    final pictObjek = item['dokumentasiObjek'] is Map
        ? item['dokumentasiObjek']['uri']?.toString()
        : item['dokumentasiObjek']?.toString();

    final pictSekitar = item['dokumentasiSekitar'] is Map
        ? item['dokumentasiSekitar']['uri']?.toString()
        : item['dokumentasiSekitar']?.toString();

    final ttdLW = item['ttdLineWalker']?.toString();
    final namaLW = item['namaTTDLineWalker']?.toString();

    final ttdPJ = item['ttdPJPekerjaan']?.toString();
    final namaPJ = item['namaTTDPJPekerjaan']?.toString();

    final ttdTLGI = item['ttdTLGI']?.toString();
    final namaTLGI = item['namaTTDTLGI']?.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rincian PPL'),
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
                label: 'PEKERJAAN',
                children: [
                  HistoryInputWithLabel(
                    label: 'Nama Pekerjaan',
                    isFirst: true,
                    child: Text(namaPekerjaan, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                  HistoryInputWithLabel(
                    label: 'Status Pekerjaan',
                    child: Text(statusPekerjaan, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                  HistoryInputWithLabel(
                    label: 'Progress Pekerjaan',
                    child: Text(progressPekerjaan, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                ],
              ),

              HistoryInputContainer(
                label: 'OBJEK',
                children: [
                  HistoryInputWithLabel(
                    label: 'Jenis Objek',
                    isFirst: true,
                    child: Text(jenisObjek, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                  HistoryInputWithLabel(
                    label: 'Keterangan Jenis Objek',
                    child: Text(keteranganJenisObjek, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                  HistoryInputWithLabel(
                    label: 'Kategori Objek',
                    child: Text(kategoriObjek, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                  HistoryInputWithLabel(
                    label: 'Keterangan Kategori Objek',
                    child: Text(keteranganKategoriObjek, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                  HistoryInputWithLabel(
                    label: 'Status Objek',
                    child: Text(statusObjek, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                ],
              ),

              HistoryInputContainer(
                label: 'PENDUKUNG',
                children: [
                  HistoryInputWithLabel(
                    label: 'Pihak Pelaksana',
                    isFirst: true,
                    child: Text(pihakPelaksana, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                  HistoryInputWithLabel(
                    label: 'Penanggung Jawab Pekerjaan',
                    child: Text(pjPekerjaan, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                  HistoryInputWithLabel(
                    label: 'No HP Penanggung Jawab Pekerjaan',
                    child: Text(noTelp, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                  HistoryInputWithLabel(
                    label: 'Tanggapan',
                    child: Text(tanggapan, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                  ),
                  HistoryInputWithLabel(
                    label: 'Nama Validator',
                    child: Text(namaValidator, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
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
                    label: 'Dokumentasi Dengan PJ/Perwakilan',
                    isFirst: true,
                    child: HistoryImageDisplay(url: pictPerwakilan),
                  ),
                  HistoryInputWithLabel(
                    label: 'Dokumentasi Objek PPL',
                    child: HistoryImageDisplay(url: pictObjek),
                  ),
                  HistoryInputWithLabel(
                    label: 'Dokumentasi Sekitar PPL',
                    child: HistoryImageDisplay(url: pictSekitar),
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
                    label: 'Penanggung Jawab Pekerjaan',
                    child: HistorySignatureDisplay(url: ttdPJ, label: namaPJ),
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
