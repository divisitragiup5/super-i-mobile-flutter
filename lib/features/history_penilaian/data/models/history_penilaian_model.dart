class NilaiBulananItemModel {
  final int id;
  final int tahun;
  final int bulan; // 0-11
  final int perTanggal;
  final double nilaiKinerja;
  final double pointAbsensi;
  final double pointPerforma;
  final String status;

  NilaiBulananItemModel({
    required this.id,
    required this.tahun,
    required this.bulan,
    required this.perTanggal,
    required this.nilaiKinerja,
    required this.pointAbsensi,
    required this.pointPerforma,
    required this.status,
  });

  factory NilaiBulananItemModel.fromJson(Map<String, dynamic> json) {
    return NilaiBulananItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      tahun: json['tahun'] as int? ?? DateTime.now().year,
      bulan: json['bulan'] as int? ?? 0,
      perTanggal: json['perTanggal'] as int? ?? 1,
      nilaiKinerja: (json['nilaiKinerja'] as num?)?.toDouble() ?? 0.0,
      pointAbsensi: (json['pointAbsensi'] as num?)?.toDouble() ?? 0.0,
      pointPerforma: (json['pointPerforma'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'AMAN',
    );
  }
}

class NilaiBulananPaginationModel {
  final List<NilaiBulananItemModel> items;
  final int? nextCursor;

  NilaiBulananPaginationModel({
    required this.items,
    this.nextCursor,
  });

  factory NilaiBulananPaginationModel.fromJson(Map<String, dynamic> json) {
    final list = <NilaiBulananItemModel>[];
    if (json['items'] is List) {
      for (final item in json['items']) {
        if (item is Map<String, dynamic>) {
          list.add(NilaiBulananItemModel.fromJson(item));
        }
      }
    }
    return NilaiBulananPaginationModel(
      items: list,
      nextCursor: json['nextCursor'] as int?,
    );
  }
}

class ScoreComponentItemModel {
  final String code;
  final double totalPoint;
  final double totalTarget;
  final double averagePoint;
  final double totalRealisasi;
  final double persenRealisasi;

  ScoreComponentItemModel({
    required this.code,
    required this.totalPoint,
    required this.totalTarget,
    required this.averagePoint,
    required this.totalRealisasi,
    required this.persenRealisasi,
  });

  factory ScoreComponentItemModel.fromJson(Map<String, dynamic> json) {
    return ScoreComponentItemModel(
      code: json['code']?.toString() ?? '-',
      totalPoint: (json['totalPoint'] as num?)?.toDouble() ?? 0.0,
      totalTarget: (json['totalTarget'] as num?)?.toDouble() ?? 0.0,
      averagePoint: (json['averagePoint'] as num?)?.toDouble() ?? 0.0,
      totalRealisasi: (json['totalRealisasi'] as num?)?.toDouble() ?? 0.0,
      persenRealisasi: (json['persenRealisasi'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class NilaiHarianItemModel {
  final int id;
  final String? createdAt;
  final double nilaiHarian;
  final double pointAbsensi;
  final double pointPerforma;
  final List<ScoreComponentItemModel> scoreComponents;

  NilaiHarianItemModel({
    required this.id,
    this.createdAt,
    required this.nilaiHarian,
    required this.pointAbsensi,
    required this.pointPerforma,
    this.scoreComponents = const [],
  });

  factory NilaiHarianItemModel.fromJson(Map<String, dynamic> json) {
    final components = <ScoreComponentItemModel>[];
    if (json['nilaiHarianScoreComponent'] is List) {
      for (final sc in json['nilaiHarianScoreComponent']) {
        if (sc is Map<String, dynamic>) {
          components.add(ScoreComponentItemModel.fromJson(sc));
        }
      }
    }

    return NilaiHarianItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      createdAt: json['createdAt'] as String?,
      nilaiHarian: (json['nilaiHarian'] as num?)?.toDouble() ?? 0.0,
      pointAbsensi: (json['pointAbsensi'] as num?)?.toDouble() ?? 0.0,
      pointPerforma: (json['pointPerforma'] as num?)?.toDouble() ?? 0.0,
      scoreComponents: components,
    );
  }
}

class GrafikBulananModel {
  final double nilaiKinerja;
  final double pointAbsensi;
  final double pointPerforma;
  final String status;
  final int perTanggal;
  final String bulanString;
  final int tahun;
  final List<Map<String, dynamic>> points;

  GrafikBulananModel({
    required this.nilaiKinerja,
    required this.pointAbsensi,
    required this.pointPerforma,
    required this.status,
    required this.perTanggal,
    required this.bulanString,
    required this.tahun,
    this.points = const [],
  });

  factory GrafikBulananModel.fromJson(Map<String, dynamic> json) {
    final chart = json['chart'] as Map<String, dynamic>? ?? {};
    final rawPoints = json['points'] as List<dynamic>? ?? [];

    return GrafikBulananModel(
      nilaiKinerja: (chart['nilaiKinerja'] as num?)?.toDouble() ?? 0.0,
      pointAbsensi: (chart['pointAbsensi'] as num?)?.toDouble() ?? 0.0,
      pointPerforma: (chart['pointPerforma'] as num?)?.toDouble() ?? 0.0,
      status: chart['status']?.toString() ?? 'AMAN',
      perTanggal: chart['perTanggal'] as int? ?? 1,
      bulanString: chart['bulanString']?.toString() ?? '',
      tahun: chart['tahun'] as int? ?? DateTime.now().year,
      points: rawPoints.whereType<Map<String, dynamic>>().toList(),
    );
  }
}
