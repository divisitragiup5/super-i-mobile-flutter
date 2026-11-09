import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../data/models/waterpass_model.dart';
import '../widgets/history_detail_widgets.dart';

class RiwayatWaterpassDetailPage extends StatelessWidget {
  final dynamic data;
  final WaterpassDetailModel? item;

  const RiwayatWaterpassDetailPage({
    super.key,
    this.data,
    this.item,
  });

  static const Map<String, String> _keyMap = {
    'waterpassX': 'WATERPASS X',
    'waterpassY': 'WATERPASS Y',
    'waterpassZ': 'WATERPASS Z',
  };

  @override
  Widget build(BuildContext context) {
    final effectiveData = data ?? item;
    Map<String, dynamic> itemMap = {};

    if (effectiveData is Map<String, dynamic>) {
      itemMap = effectiveData;
    } else if (effectiveData is WaterpassDetailModel) {
      itemMap = effectiveData.rawJson.isNotEmpty
          ? effectiveData.rawJson
          : {
              'tower': {'nama': effectiveData.namaTower},
              'createdAt': effectiveData.createdAt,
              if (effectiveData.fotoSebelumUrl != null)
                'fotoTowerSebelumInspeksi': {'uri': effectiveData.fotoSebelumUrl},
              if (effectiveData.fotoSetelahUrl != null)
                'fotoTowerSetelahInspeksi': {'uri': effectiveData.fotoSetelahUrl},
              if (effectiveData.hasilX != null || effectiveData.fotoXUrl != null)
                'waterpassX': {
                  'hasil': effectiveData.hasilX,
                  'pict': {'uri': effectiveData.fotoXUrl},
                },
              if (effectiveData.hasilY != null || effectiveData.fotoYUrl != null)
                'waterpassY': {
                  'hasil': effectiveData.hasilY,
                  'pict': {'uri': effectiveData.fotoYUrl},
                },
              if (effectiveData.hasilZ != null || effectiveData.fotoZUrl != null)
                'waterpassZ': {
                  'hasil': effectiveData.hasilZ,
                  'pict': {'uri': effectiveData.fotoZUrl},
                },
            };
    }

    final towerName = itemMap['tower'] is Map
        ? itemMap['tower']['nama']?.toString()
        : (itemMap['tower']?.toString() ?? 'Tower');
    final createdAt = itemMap['createdAt'];

    final fotoSebelum = itemMap['fotoTowerSebelumInspeksi'] is Map
        ? itemMap['fotoTowerSebelumInspeksi']['uri']?.toString()
        : itemMap['fotoTowerSebelumInspeksi']?.toString();

    final fotoSetelah = itemMap['fotoTowerSetelahInspeksi'] is Map
        ? itemMap['fotoTowerSetelahInspeksi']['uri']?.toString()
        : itemMap['fotoTowerSetelahInspeksi']?.toString();

    final availableAxes = <String, Map<String, dynamic>>{};
    for (final key in _keyMap.keys) {
      if (itemMap[key] != null && itemMap[key] is Map<String, dynamic>) {
        availableAxes[key] = itemMap[key] as Map<String, dynamic>;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rincian Waterpass'),
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
                  HistoryInputWithLabel(
                    label: 'Tanggal',
                    child: Text(
                      formatHistoryDate(createdAt),
                      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                  ),
                ],
              ),

              if (fotoSebelum != null && fotoSebelum.isNotEmpty)
                HistoryInputContainer(
                  label: 'FOTO SEBELUM INSPEKSI',
                  children: [
                    HistoryImageDisplay(url: fotoSebelum),
                  ],
                ),

              ...availableAxes.entries.map((entry) {
                final axisData = entry.value;
                final axisLabel = _keyMap[entry.key] ?? entry.key;
                final pictUrl = axisData['pict'] is Map
                    ? axisData['pict']['uri']?.toString()
                    : axisData['pict']?.toString();
                final hasil = axisData['hasil']?.toString() ?? '-';

                return HistoryInputContainer(
                  label: axisLabel,
                  children: [
                    if (pictUrl != null && pictUrl.isNotEmpty)
                      HistoryInputWithLabel(
                        label: 'Foto Hasil',
                        isFirst: true,
                        child: HistoryImageDisplay(url: pictUrl),
                      ),
                    HistoryInputWithLabel(
                      label: 'Hasil',
                      isFirst: pictUrl == null || pictUrl.isEmpty,
                      child: Text(
                        hasil,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                      ),
                    ),
                  ],
                );
              }),

              if (fotoSetelah != null && fotoSetelah.isNotEmpty)
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
