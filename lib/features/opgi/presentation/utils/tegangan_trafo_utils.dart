import 'package:flutter/material.dart';
import '../../data/models/opgi_realisasi_model.dart';

/// Item periode yang telah dimapping untuk rendering chip pada kartu tegangan trafo
class TeganganTrafoMappedPeriod {
  final int periode;
  final int tanggal;
  final int bulan;
  final int tahun;
  final bool draft;
  final bool isDone;
  final Color color;

  const TeganganTrafoMappedPeriod({
    required this.periode,
    required this.tanggal,
    required this.bulan,
    required this.tahun,
    required this.draft,
    required this.isDone,
    required this.color,
  });
}

/// Menghasilkan mapped periods untuk tiap tegangan trafo dengan warna chip sesuai super-i-mobile
List<TeganganTrafoMappedPeriod> mapTeganganTrafoPeriods({
  required TeganganTrafoModel item,
  required List<Map<String, dynamic>> localDrafts,
}) {
  final draftKeyPrefix = '${item.nama}-${item.garduIndukNama}';
  final drafted = localDrafts.where((d) => (d['nama'] as String?) == draftKeyPrefix).toList();

  return item.periods.map((period) {
    TrafoTeganganItemModel? tegangan;
    for (final t in item.tegangan) {
      if (t.periode == period.periode &&
          t.tanggal == period.tanggal &&
          t.bulan == period.bulan &&
          t.tahun == period.tahun) {
        tegangan = t;
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
        final tg = data['tanggal'] is int
            ? data['tanggal'] as int
            : int.tryParse('${data['tanggal']}');
        final m = data['bulan'] is int
            ? data['bulan'] as int
            : int.tryParse('${data['bulan']}');
        final y = data['tahun'] is int
            ? data['tahun'] as int
            : int.tryParse('${data['tahun']}');

        return p == period.periode &&
            tg == period.tanggal &&
            m == period.bulan &&
            y == period.tahun;
      });
    }

    final isDone = tegangan != null;
    Color chipColor;
    if (isDone) {
      if (tegangan.status == 'ON TIME') {
        chipColor = const Color(0xFF22C55E); // green-500
      } else if (tegangan.status == 'PERHATIAN') {
        chipColor = const Color(0xFFEAB308); // yellow-500
      } else {
        chipColor = const Color(0xFFEF4444); // red-500
      }
    } else if (isDraft) {
      chipColor = Colors.white;
    } else {
      chipColor = const Color(0xFF6B7280); // gray-500
    }

    return TeganganTrafoMappedPeriod(
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

class ParsedTeganganTrafoDraftResult {
  final List<Map<String, dynamic>> parsed;
  final List<int> duplicates;

  const ParsedTeganganTrafoDraftResult({
    required this.parsed,
    required this.duplicates,
  });
}

/// Parsing draft tegangan trafo dengan memfilter data duplikat dan memformat DTO bersih
ParsedTeganganTrafoDraftResult parseTeganganTrafoDrafts({
  required List<Map<String, dynamic>> localDrafts,
  required int garduIndukId,
  required List<TeganganTrafoModel> mappedData,
}) {
  final existingKeySet = <String>{};
  for (final item in mappedData) {
    for (final t in item.tegangan) {
      existingKeySet.add(
        '${item.nama}-${item.garduIndukNama}-${t.periode}-${t.tanggal}-${t.bulan}-${t.tahun}',
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
    final rawFotoMV = data['fotoMV'];
    final rawMv = data['mv'];
    final rawFotoHV = data['fotoHV'];
    final rawHv = data['hv'];
    final rawDurasi = data['durasi'];
    final rawGiId = data['garduIndukId'];

    if (rawId == null ||
        rawFotoMV == null ||
        rawMv == null ||
        rawFotoHV == null ||
        rawHv == null ||
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

    String? fotoMvUri;
    Map<String, dynamic> fotoMvMeta = {};
    if (rawFotoMV is Map) {
      fotoMvUri = rawFotoMV['uri']?.toString();
      fotoMvMeta = Map<String, dynamic>.from(rawFotoMV)..remove('uri');
    } else if (rawFotoMV is String) {
      fotoMvUri = rawFotoMV;
    }

    String? fotoHvUri;
    Map<String, dynamic> fotoHvMeta = {};
    if (rawFotoHV is Map) {
      fotoHvUri = rawFotoHV['uri']?.toString();
      fotoHvMeta = Map<String, dynamic>.from(rawFotoHV)..remove('uri');
    } else if (rawFotoHV is String) {
      fotoHvUri = rawFotoHV;
    }

    if (fotoMvUri == null || fotoMvUri.isEmpty || fotoHvUri == null || fotoHvUri.isEmpty) {
      continue;
    }

    final trafoId = int.tryParse('$rawId') ?? 0;
    final mvNum = double.tryParse('$rawMv') ?? 0.0;
    final hvNum = double.tryParse('$rawHv') ?? 0.0;
    final durasiNum = (num.tryParse('$rawDurasi') ?? 0.0).toDouble();

    final dtoData = <String, dynamic>{
      'trafoId': trafoId,
      'mv': mvNum,
      'hv': hvNum,
      'periode': periode,
      'tanggal': tanggal,
      'bulan': bulan,
      'tahun': tahun,
      'durasi': durasiNum,
      'timezone': 'Asia/Jakarta',
      'garduIndukId': garduIndukId,
      if (fotoMvMeta.isNotEmpty)
        'fotoMV': {
          ...fotoMvMeta,
          if (fotoMvMeta['date'] != null)
            'date': DateTime.tryParse(fotoMvMeta['date'].toString())?.toIso8601String() ??
                fotoMvMeta['date'].toString(),
        },
      if (fotoHvMeta.isNotEmpty)
        'fotoHV': {
          ...fotoHvMeta,
          if (fotoHvMeta['date'] != null)
            'date': DateTime.tryParse(fotoHvMeta['date'].toString())?.toIso8601String() ??
                fotoHvMeta['date'].toString(),
        },
    };

    parsed.add({
      'draftId': draftRowId,
      'fotoMV': fotoMvUri,
      'fotoHV': fotoHvUri,
      'data': dtoData,
    });
  }

  return ParsedTeganganTrafoDraftResult(
    parsed: parsed,
    duplicates: duplicates,
  );
}

/// Memeriksa ambang batas tegangan trafo untuk memunculkan peringatan
List<String> checkTeganganThresholds({
  required bool isPS,
  required double mv,
  required double hv,
}) {
  final warnings = <String>[];

  if (isPS) {
    if (mv < 342) {
      warnings.add('Tegangan MV kurang dari ambang batas normal.');
    } else if (mv >= 399) {
      warnings.add('Tegangan MV lebih dari/sama dengan ambang batas normal.');
    }
    if (hv < 20.24) {
      warnings.add('Tegangan HV kurang dari ambang batas normal.');
    } else if (hv >= 20.76) {
      warnings.add('Tegangan HV lebih dari/sama dengan ambang batas normal.');
    }
  } else {
    if (mv < 20.24) {
      warnings.add('Tegangan MV kurang dari ambang batas normal.');
    } else if (mv >= 20.76) {
      warnings.add('Tegangan MV lebih dari/sama dengan ambang batas normal.');
    }
    if (hv < 142.5) {
      warnings.add('Tegangan HV kurang dari ambang batas normal.');
    } else if (hv >= 157.5) {
      warnings.add('Tegangan HV lebih dari/sama dengan ambang batas normal.');
    }
  }

  return warnings;
}
