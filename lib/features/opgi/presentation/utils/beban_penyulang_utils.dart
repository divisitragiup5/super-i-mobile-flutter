import 'dart:convert';
import 'package:flutter/material.dart';
import '../../data/models/opgi_realisasi_model.dart';

const List<String> kManuverStart = [
  'OPEN',
  'RACK OUT',
  'RACK IN',
  'MASUK',
  'KELUAR',
  'MANUVER',
];

const List<String> kManuverEnd = ['CLOSE'];

/// Menghitung indeks waktu numerik berurutan untuk sorting dan range check
int toTimeIndex(int tahun, int bulan, int tanggal, int periode) {
  return tahun * 10000000 + bulan * 100000 + tanggal * 1000 + periode;
}

/// Menghitung status periode berdasarkan event manuver (OPEN tanpa CLOSE = rentang manuver aktif)
List<Map<String, dynamic>> calculateManuvers(
  List<PenyulangPeriodModel> periods,
  List<PenyulangManuverItemModel> manuver,
) {
  final now = DateTime.now();
  final nowIndex = toTimeIndex(now.year, now.month, now.day, now.hour);

  final sortedPeriods = [...periods]..sort((a, b) =>
      toTimeIndex(a.tahun, a.bulan, a.tanggal, a.periode)
          .compareTo(toTimeIndex(b.tahun, b.bulan, b.tanggal, b.periode)));

  final sortedManuver = [...manuver]..sort((a, b) =>
      toTimeIndex(a.tahun, a.bulan, a.tanggal, a.periode)
          .compareTo(toTimeIndex(b.tahun, b.bulan, b.tanggal, b.periode)));

  final ranges = <Map<String, int>>[];
  int? currentStart;

  for (final m in sortedManuver) {
    final idx = toTimeIndex(m.tahun, m.bulan, m.tanggal, m.periode);

    if (kManuverStart.contains(m.status)) {
      currentStart ??= idx;
    }

    if (kManuverEnd.contains(m.status)) {
      if (currentStart != null) {
        ranges.add({'start': currentStart, 'end': idx});
        currentStart = null;
      }
    }
  }

  // Jika manuver masih terbuka tanpa close
  if (currentStart != null) {
    ranges.add({'start': currentStart, 'end': nowIndex});
  }

  return sortedPeriods.map((p) {
    final periodIndex = toTimeIndex(p.tahun, p.bulan, p.tanggal, p.periode);
    final inManuver = ranges.any(
      (r) => periodIndex >= r['start']! && periodIndex < r['end']!,
    );

    return {
      'periode': p.periode,
      'tanggal': p.tanggal,
      'bulan': p.bulan,
      'tahun': p.tahun,
      'status': inManuver ? 'MANUVER' : null,
    };
  }).toList();
}

/// Item periode yang telah dimapping untuk rendering chip pada kartu penyulang
class PenyulangMappedPeriod {
  final int periode;
  final int tanggal;
  final int bulan;
  final int tahun;
  final bool draft;
  final bool hasManuver;
  final bool isDone;
  final Color color;

  const PenyulangMappedPeriod({
    required this.periode,
    required this.tanggal,
    required this.bulan,
    required this.tahun,
    required this.draft,
    required this.hasManuver,
    required this.isDone,
    required this.color,
  });
}

/// Menghasilkan mapped periods untuk tiap penyulang dengan warna chip sesuai super-i-mobile
List<PenyulangMappedPeriod> mapPenyulangPeriods({
  required PenyulangModel item,
  required List<Map<String, dynamic>> localDrafts,
}) {
  final draftKeyPrefix = '${item.nama}-${item.garduIndukNama}';
  final drafted = localDrafts.where((d) => (d['nama'] as String?) == draftKeyPrefix).toList();

  final manuvers = item.periods.isNotEmpty && item.manuver.isNotEmpty
      ? calculateManuvers(item.periods, item.manuver)
      : <Map<String, dynamic>>[];

  return item.periods.map((period) {
    PenyulangBebanItemModel? beban;
    for (final b in item.beban) {
      if (b.periode == period.periode &&
          b.tanggal == period.tanggal &&
          b.bulan == period.bulan &&
          b.tahun == period.tahun) {
        beban = b;
        break;
      }
    }

    final manuverGroup = manuvers.where((m) =>
        m['periode'] == period.periode &&
        m['tanggal'] == period.tanggal &&
        m['bulan'] == period.bulan &&
        m['tahun'] == period.tahun &&
        m['status'] != null).toList();

    final hasCloseManuver = manuverGroup.isNotEmpty &&
        manuverGroup.any((m) => m['status'] == 'CLOSE');
    final hasManuver = manuverGroup.isNotEmpty && !hasCloseManuver;

    bool isDraft = false;
    if (drafted.isNotEmpty) {
      isDraft = drafted.any((d) {
        final data = d['data'] is Map<String, dynamic>
            ? d['data'] as Map<String, dynamic>
            : <String, dynamic>{};
        final p = data['periode'] is int
            ? data['periode'] as int
            : int.tryParse('${data['periode']}');
        final m = data['bulan'] is int
            ? data['bulan'] as int
            : int.tryParse('${data['bulan']}');
        final y = data['tahun'] is int
            ? data['tahun'] as int
            : int.tryParse('${data['tahun']}');

        return p == period.periode && m == period.bulan && y == period.tahun;
      });
    }

    final isDone = beban != null || hasManuver;

    Color color;
    if (hasManuver) {
      color = const Color(0xFF3B82F6); // Blue-500
    } else if (beban != null) {
      if (beban.status == 'ON TIME') {
        color = const Color(0xFF22C55E); // Green-500
      } else if (beban.status == 'PERHATIAN') {
        color = const Color(0xFFEAB308); // Yellow-500
      } else {
        color = const Color(0xFFEF4444); // Red-500
      }
    } else if (isDraft) {
      color = Colors.white;
    } else {
      color = const Color(0xFF6B7280); // Gray-500
    }

    return PenyulangMappedPeriod(
      periode: period.periode,
      tanggal: period.tanggal,
      bulan: period.bulan,
      tahun: period.tahun,
      draft: isDraft,
      hasManuver: hasManuver,
      isDone: isDone,
      color: color,
    );
  }).toList();
}

/// Parsing draft yang siap untuk dikirim batch (mengecek duplikasi dengan data yang sudah di-server)
class ParsedDraftResult {
  final List<Map<String, dynamic>> parsed;
  final List<int> duplicates;

  const ParsedDraftResult({required this.parsed, required this.duplicates});
}

ParsedDraftResult parseBebanPenyulangDrafts({
  required List<Map<String, dynamic>> localDrafts,
  required int garduIndukId,
  required List<PenyulangModel> penyulangList,
}) {
  final existingKeySet = <String>{};

  for (final item in penyulangList) {
    for (final b in item.beban) {
      final key = '${item.nama}-${item.garduIndukNama}-${b.periode}-${b.tanggal}-${b.bulan}-${b.tahun}';
      existingKeySet.add(key);
    }
  }

  final parsed = <Map<String, dynamic>>[];
  final duplicates = <int>[];

  for (final draft in localDrafts) {
    final draftRowId = draft['id'] is int ? draft['id'] as int : int.tryParse('${draft['id']}');
    final namaDraft = draft['nama'] as String? ?? '';
    Map<String, dynamic> data = {};
    if (draft['data'] is Map) {
      data = Map<String, dynamic>.from(draft['data'] as Map);
    } else if (draft['data'] is String && (draft['data'] as String).isNotEmpty) {
      try {
        data = Map<String, dynamic>.from(jsonDecode(draft['data'] as String) as Map);
      } catch (_) {}
    }

    final penyulangId = data['penyulangId'] is int
        ? data['penyulangId'] as int
        : int.tryParse('${data['penyulangId']}') ??
            (data['id'] is int ? data['id'] as int : int.tryParse('${data['id']}'));

    final giId = data['garduIndukId'] is int
        ? data['garduIndukId'] as int
        : int.tryParse('${data['garduIndukId']}');

    final beban = data['beban'];
    final foto = data['foto'];
    final durasi = data['durasi'];

    if (draftRowId == null ||
        penyulangId == null ||
        beban == null ||
        foto == null ||
        giId != garduIndukId) {
      continue;
    }

    final periodeInt = data['periode'] is int
        ? data['periode'] as int
        : int.tryParse('${data['periode']}') ?? 0;
    final tanggalInt = data['tanggal'] is int
        ? data['tanggal'] as int
        : int.tryParse('${data['tanggal']}') ?? DateTime.now().day;
    final bulanInt = data['bulan'] is int
        ? data['bulan'] as int
        : int.tryParse('${data['bulan']}') ?? DateTime.now().month;
    final tahunInt = data['tahun'] is int
        ? data['tahun'] as int
        : int.tryParse('${data['tahun']}') ?? DateTime.now().year;

    final key = '$namaDraft-$periodeInt-$tanggalInt-$bulanInt-$tahunInt';

    if (existingKeySet.contains(key)) {
      duplicates.add(draftRowId);
      continue;
    }

    final bebanVal = (beban is num)
        ? beban.round()
        : (num.tryParse('$beban') ?? 0).round();
    final durasiVal = (durasi is num)
        ? durasi.toDouble()
        : (num.tryParse('$durasi')?.toDouble() ?? 0.0);

    parsed.add({
      'draftId': draftRowId,
      'penyulangId': penyulangId,
      'beban': bebanVal,
      'durasi': durasiVal,
      'periode': periodeInt,
      'tanggal': tanggalInt,
      'bulan': bulanInt,
      'tahun': tahunInt,
      'garduIndukId': giId,
      'foto': foto,
    });
  }

  return ParsedDraftResult(parsed: parsed, duplicates: duplicates);
}
