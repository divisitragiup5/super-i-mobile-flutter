import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../data/models/pembumian_model.dart';
import '../widgets/history_detail_widgets.dart';

class RiwayatPembumianDetailPage extends StatelessWidget {
  final dynamic data;

  const RiwayatPembumianDetailPage({
    super.key,
    required this.data,
  });

  static const Map<String, String> _keyMap = {
    'legA': 'LEG A',
    'legB': 'LEG B',
    'legC': 'LEG C',
    'legD': 'LEG D',
    'IGSW': 'IGSW',
    'bersama': 'BERSAMA',
    'groundingLangsung': 'GROUNDING LANGSUNG',
    'MDG': 'MDG',
  };

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> item = {};
    if (data is Map<String, dynamic>) {
      item = data;
    } else if (data is PembumianHistoryItemModel) {
      final model = data as PembumianHistoryItemModel;
      item = model.rawJson.isNotEmpty
          ? model.rawJson
          : {
              'tower': {'nama': model.namaTower},
              'createdAt': model.createdAt,
              'kendala': model.kendala,
            };
    }

    final towerName = item['tower'] is Map ? item['tower']['nama']?.toString() : 'Tower';
    final petugas = item['petugasLineWalker'] is Map && item['petugasLineWalker']['petugas'] is Map && item['petugasLineWalker']['petugas']['user'] is Map
        ? item['petugasLineWalker']['petugas']['user']['namaLengkap']?.toString()
        : (item['petugasLineWalker'] is Map ? item['petugasLineWalker']['namaLengkap']?.toString() : null);
    final createdAt = item['createdAt'];

    final fotoSebelum = item['fotoTowerSebelumInspeksi'] is Map ? item['fotoTowerSebelumInspeksi']['uri']?.toString() : null;
    final fotoSetelah = item['fotoTowerSetelahInspeksi'] is Map ? item['fotoTowerSetelahInspeksi']['uri']?.toString() : null;
    final anomali = item['anomali'] as Map<String, dynamic>?;

    final availableLegs = <String, Map<String, dynamic>>{};
    for (final key in _keyMap.keys) {
      if (item[key] != null && item[key] is Map<String, dynamic>) {
        availableLegs[key] = item[key] as Map<String, dynamic>;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rincian Pembumian'),
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

              if (fotoSebelum != null)
                HistoryInputContainer(
                  label: 'FOTO SEBELUM INSPEKSI',
                  children: [
                    HistoryImageDisplay(url: fotoSebelum),
                  ],
                ),

              ...availableLegs.entries.map((entry) {
                final legData = entry.value;
                final legLabel = _keyMap[entry.key] ?? entry.key;
                final pictUrl = legData['pict'] is Map ? legData['pict']['uri']?.toString() : null;
                final hasil = legData['hasil']?.toString() ?? '-';
                final statusPictUrl = legData['statusPict'] is Map ? legData['statusPict']['uri']?.toString() : null;
                final status = legData['status']?.toString() ?? '-';

                return HistoryInputContainer(
                  label: legLabel,
                  children: [
                    if (pictUrl != null)
                      HistoryInputWithLabel(
                        label: 'Foto Hasil',
                        isFirst: true,
                        child: HistoryImageDisplay(url: pictUrl),
                      ),
                    HistoryInputWithLabel(
                      label: 'Hasil',
                      isFirst: pictUrl == null,
                      child: Text(
                        hasil,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                      ),
                    ),
                    if (statusPictUrl != null)
                      HistoryInputWithLabel(
                        label: 'Foto Status',
                        child: HistoryImageDisplay(url: statusPictUrl),
                      ),
                    HistoryInputWithLabel(
                      label: 'Status',
                      child: Text(
                        status,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                      ),
                    ),
                  ],
                );
              }),

              if (anomali != null)
                HistoryInputContainer(
                  label: 'ANOMALI',
                  children: [
                    if (anomali['pict'] is Map && anomali['pict']['uri'] != null)
                      HistoryInputWithLabel(
                        label: 'Foto',
                        isFirst: true,
                        child: HistoryImageDisplay(url: anomali['pict']['uri']?.toString()),
                      ),
                    HistoryInputWithLabel(
                      label: 'Catatan',
                      isFirst: anomali['pict'] == null,
                      child: Text(
                        anomali['catatan']?.toString() ?? '-',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                      ),
                    ),
                  ],
                ),

              if (fotoSetelah != null)
                HistoryInputContainer(
                  label: 'FOTO SETELAH INSPEKSI',
                  children: [
                    HistoryImageDisplay(url: fotoSetelah),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
