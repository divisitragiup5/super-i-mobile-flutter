class LineWalkerPerformanceModel {
  final int? minggu;
  final String? bulan;
  final int? tahun;
  final double score;
  final String kategoriPerformaTenagaKerja;
  final List<String> penilaian;

  // Pencapaian Inspeksi
  final double pointKepatuhan;
  final double kepatuhan;
  final int targetPencapainInspeksi;

  // COC
  final double pointCOC;
  final double coc;
  final int targetCOC;

  // Kehadiran (Absensi)
  final double pointAbsensi;
  final double absensi;
  final int targetAbsensi;

  // Durasi Inspeksi
  final double pointDurasi;
  final double durasi;
  final int ketentuan;

  final List<Map<String, dynamic>> trends;

  const LineWalkerPerformanceModel({
    this.minggu,
    this.bulan,
    this.tahun,
    required this.score,
    required this.kategoriPerformaTenagaKerja,
    required this.penilaian,
    this.pointKepatuhan = 0.0,
    this.kepatuhan = 0.0,
    this.targetPencapainInspeksi = 0,
    this.pointCOC = 0.0,
    this.coc = 0.0,
    this.targetCOC = 0,
    this.pointAbsensi = 0.0,
    this.absensi = 0.0,
    this.targetAbsensi = 0,
    this.pointDurasi = 0.0,
    this.durasi = 0.0,
    this.ketentuan = 0,
    this.trends = const [],
  });

  factory LineWalkerPerformanceModel.fromJson(Map<String, dynamic> json) {
    // Tangani struktur berakar response.data atau langsung
    final rawData = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final dataInner = rawData['data'] is Map<String, dynamic>
        ? rawData['data'] as Map<String, dynamic>
        : rawData;

    final List<String> penilaianList = [];
    if (rawData['penilaian'] is List) {
      for (final p in rawData['penilaian'] as List) {
        penilaianList.add(p.toString());
      }
    } else if (dataInner['penilaian'] is List) {
      for (final p in dataInner['penilaian'] as List) {
        penilaianList.add(p.toString());
      }
    }

    final List<Map<String, dynamic>> trendsList = [];
    final dynamic rawTrends = rawData['trends'] ?? dataInner['trends'] ?? json['trends'];
    if (rawTrends is List) {
      for (final t in rawTrends) {
        if (t is Map<String, dynamic>) {
          trendsList.add(t);
        } else if (t is Map) {
          trendsList.add(Map<String, dynamic>.from(t));
        }
      }
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return LineWalkerPerformanceModel(
      minggu: dataInner['minggu'] is int
          ? dataInner['minggu'] as int
          : int.tryParse('${dataInner['minggu']}'),
      bulan: dataInner['bulan']?.toString(),
      tahun: dataInner['tahun'] is int
          ? dataInner['tahun'] as int
          : int.tryParse('${dataInner['tahun']}'),
      score: parseDouble(dataInner['score']),
      kategoriPerformaTenagaKerja:
          dataInner['kategoriPerformaTenagaKerja']?.toString() ?? 'top-perform',
      penilaian: penilaianList.isNotEmpty
          ? penilaianList
          : const ['PENCAPAIAN', 'COC', 'ABSENSI', 'DURASI'],
      pointKepatuhan: parseDouble(dataInner['pointKepatuhan']),
      kepatuhan: parseDouble(dataInner['kepatuhan']),
      targetPencapainInspeksi: parseInt(dataInner['targetPencapainInspeksi']),
      pointCOC: parseDouble(dataInner['pointCOC']),
      coc: parseDouble(dataInner['coc']),
      targetCOC: parseInt(dataInner['targetCOC']),
      pointAbsensi: parseDouble(dataInner['pointAbsensi']),
      absensi: parseDouble(dataInner['absensi']),
      targetAbsensi: parseInt(dataInner['targetAbsensi']),
      pointDurasi: parseDouble(dataInner['pointDurasi']),
      durasi: parseDouble(dataInner['durasi']),
      ketentuan: parseInt(dataInner['ketentuan']),
      trends: trendsList,
    );
  }

  /// Mengekstrak daftar TrendDataPoint untuk grafik tren berdasarkan trendKey ('score', 'kepatuhan', 'coc', 'absensi', 'durasi')
  List<TrendDataPoint> getTrendPoints(String trendKey) {
    if (trends.isEmpty) return const [];

    return trends.map((d) {
      final bulanStr = (d['bulan'] ?? '').toString();
      final tahunNum = d['tahun'] is int
          ? d['tahun'] as int
          : int.tryParse('${d['tahun']}') ?? 0;

      final shortBulan = bulanStr.length >= 3
          ? bulanStr.substring(0, 3).toUpperCase()
          : bulanStr.toUpperCase();

      final label = tahunNum > 0 ? '$shortBulan $tahunNum' : shortBulan;

      final rawVal = d[trendKey];
      double val = 0.0;
      if (rawVal != null) {
        if (rawVal is num) {
          val = rawVal.toDouble();
        } else {
          val = double.tryParse(rawVal.toString()) ?? 0.0;
        }
      }

      return TrendDataPoint(
        label: label,
        bulan: bulanStr,
        tahun: tahunNum,
        value: double.parse(val.toStringAsFixed(2)),
      );
    }).toList();
  }
}

class TrendDataPoint {
  final String label;
  final String bulan;
  final int tahun;
  final double value;

  const TrendDataPoint({
    required this.label,
    required this.bulan,
    required this.tahun,
    required this.value,
  });
}
