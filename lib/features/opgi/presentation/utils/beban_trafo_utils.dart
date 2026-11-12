import 'package:flutter/material.dart';
import '../../data/models/opgi_realisasi_model.dart';

/// Item periode yang telah dimapping untuk rendering chip pada kartu trafo
class TrafoMappedPeriod {
  final int periode;
  final int tanggal;
  final int bulan;
  final int tahun;
  final bool draft;
  final bool isDone;
  final Color color;

  const TrafoMappedPeriod({
    required this.periode,
    required this.tanggal,
    required this.bulan,
    required this.tahun,
    required this.draft,
    required this.isDone,
    required this.color,
  });
}

/// Menghasilkan mapped periods untuk tiap trafo dengan warna chip sesuai super-i-mobile
List<TrafoMappedPeriod> mapTrafoPeriods({
  required BebanTrafoModel item,
  required List<Map<String, dynamic>> localDrafts,
}) {
  final draftKeyPrefix = '${item.nama}-${item.garduIndukNama}';
  final drafted = localDrafts.where((d) => (d['nama'] as String?) == draftKeyPrefix).toList();

  return item.periods.map((period) {
    TrafoBebanItemModel? beban;
    for (final b in item.beban) {
      if (b.periode == period.periode &&
          b.tanggal == period.tanggal &&
          b.bulan == period.bulan &&
          b.tahun == period.tahun) {
        beban = b;
        break;
      }
    }

    bool isDraft = false;
    if (drafted.isNotEmpty) {
      isDraft = drafted.any((d) {
        final data = d['data'] is Map<String, dynamic>
            ? d['data'] as Map<String, dynamic>
            : <String, dynamic>{};
        final p = data['periode'] is int
            ? data['periode'] as int
            : int.tryParse('${data['periode']}');
        final t = data['tanggal'] is int
            ? data['tanggal'] as int
            : int.tryParse('${data['tanggal']}');
        final m = data['bulan'] is int
            ? data['bulan'] as int
            : int.tryParse('${data['bulan']}');
        final y = data['tahun'] is int
            ? data['tahun'] as int
            : int.tryParse('${data['tahun']}');

        return p == period.periode &&
            t == period.tanggal &&
            m == period.bulan &&
            y == period.tahun;
      });
    }

    final isDone = beban != null;
    Color chipColor;
    if (isDone) {
      if (beban.status == 'ON TIME') {
        chipColor = const Color(0xFF22C55E); // green-500
      } else if (beban.status == 'PERHATIAN') {
        chipColor = const Color(0xFFEAB308); // yellow-500
      } else {
        chipColor = const Color(0xFFEF4444); // red-500
      }
    } else if (isDraft) {
      chipColor = Colors.white;
    } else {
      chipColor = const Color(0xFF6B7280); // gray-500
    }

    return TrafoMappedPeriod(
      periode: period.periode,
      tanggal: period.tanggal,
      bulan: period.bulan,
      tahun: period.tahun,
      draft: isDraft,
      isDone: isDone,
      color: chipColor,
    );
  }).toList();
}

class ParsedBebanTrafoDraftResult {
  final List<Map<String, dynamic>> parsed;
  final List<int> duplicates;

  const ParsedBebanTrafoDraftResult({
    required this.parsed,
    required this.duplicates,
  });
}

/// Parsing draft beban trafo dengan memfilter data duplikat dan memformat DTO bersih
ParsedBebanTrafoDraftResult parseBebanTrafoDrafts({
  required List<Map<String, dynamic>> localDrafts,
  required int garduIndukId,
  required List<BebanTrafoModel> mappedData,
}) {
  final existingKeySet = <String>{};
  for (final trafo in mappedData) {
    for (final b in trafo.beban) {
      existingKeySet.add(
        '${trafo.nama}-${trafo.garduIndukNama}-${b.periode}-${b.tanggal}-${b.bulan}-${b.tahun}',
      );
    }
  }

  final parsed = <Map<String, dynamic>>[];
  final duplicates = <int>[];

  for (final draft in localDrafts) {
    final draftRowId = draft['id'] is int ? draft['id'] as int : int.tryParse('${draft['id']}');
    final namaDraft = draft['nama']?.toString() ?? '';
    final rawData = draft['data'];
    final data = rawData is Map<String, dynamic>
        ? rawData
        : (rawData is Map ? Map<String, dynamic>.from(rawData) : <String, dynamic>{});

    final rawId = data['id'];
    final rawBeban = data['beban'];
    final rawFoto = data['foto'];
    final rawDurasi = data['durasi'];
    final rawGiId = data['garduIndukId'];

    if (rawId == null ||
        rawBeban == null ||
        rawFoto == null ||
        rawDurasi == null ||
        (int.tryParse('$rawGiId') ?? 0) != garduIndukId) {
      continue;
    }

    final periode = int.tryParse('${data['periode']}') ?? 0;
    final tanggal = int.tryParse('${data['tanggal']}') ?? 0;
    final bulan = int.tryParse('${data['bulan']}') ?? 0;
    final tahun = int.tryParse('${data['tahun']}') ?? 0;

    final key = '$namaDraft-$periode-$tanggal-$bulan-$tahun';

    if (existingKeySet.contains(key)) {
      if (draftRowId != null) duplicates.add(draftRowId);
      continue;
    }

    String? fotoUri;
    Map<String, dynamic> fotoMeta = {};
    if (rawFoto is Map) {
      fotoUri = rawFoto['uri']?.toString();
      fotoMeta = Map<String, dynamic>.from(rawFoto)..remove('uri');
    } else if (rawFoto is String) {
      fotoUri = rawFoto;
    }

    if (fotoUri == null || fotoUri.isEmpty) continue;

    final trafoId = int.tryParse('$rawId') ?? 0;
    final bebanNum = (num.tryParse('$rawBeban') ?? 0).round();
    final durasiNum = (num.tryParse('$rawDurasi') ?? 0.0).toDouble();

    final dtoData = <String, dynamic>{
      'trafoId': trafoId,
      'beban': bebanNum,
      'periode': periode,
      'tanggal': tanggal,
      'bulan': bulan,
      'tahun': tahun,
      'durasi': durasiNum,
      'timezone': 'Asia/Jakarta',
      'garduIndukId': garduIndukId,
      if (fotoMeta.isNotEmpty)
        'foto': {
          ...fotoMeta,
          if (fotoMeta['date'] != null)
            'date': DateTime.tryParse(fotoMeta['date'].toString())?.toIso8601String() ??
                fotoMeta['date'].toString(),
        },
    };

    parsed.add({
      'draftId': draftRowId,
      'file': fotoUri,
      'data': dtoData,
    });
  }

  return ParsedBebanTrafoDraftResult(
    parsed: parsed,
    duplicates: duplicates,
  );
}

bool isValidDecimal(dynamic value) {
  if (value == null) return true;
  final str = value.toString().trim();
  if (str.isEmpty) return true;
  if (str.contains(',')) return false;
  return double.tryParse(str) != null;
}
