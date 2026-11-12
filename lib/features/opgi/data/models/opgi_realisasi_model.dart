/// Model data untuk Realisasi Beban Trafo, Beban Penyulang, KWH Harian, dan Tegangan Trafo
library;

class BebanTrafoModel {
  final int id;
  final String nama;
  final double iMax;
  final int garduIndukId;
  final String garduIndukNama;
  final List<TrafoBebanItemModel> beban;
  final List<PenyulangPeriodModel> periods;

  // Backward compatibility fields
  int get trafoId => id;
  String get namaTrafo => nama;
  int get periode => beban.isNotEmpty ? beban.first.periode : 0;
  double get arus => beban.isNotEmpty ? beban.first.beban : 0.0;
  double? get tegangan => null;
  double? get suhuWinding => null;
  double? get suhuOli => null;

  const BebanTrafoModel({
    required this.id,
    required this.nama,
    this.iMax = 0.0,
    required this.garduIndukId,
    required this.garduIndukNama,
    this.beban = const [],
    this.periods = const [],
  });

  factory BebanTrafoModel.fromJson(Map<String, dynamic> json) {
    final gi = json['garduInduk'];
    final giId = gi is Map ? (gi['id'] as int? ?? 0) : (json['garduIndukId'] as int? ?? 0);
    final giNama = gi is Map ? (gi['nama'] as String? ?? '-') : (json['garduIndukNama'] as String? ?? '-');

    final rawBeban = json['beban'] as List? ?? [];
    final bebanList = rawBeban
        .whereType<Map<String, dynamic>>()
        .map((b) => TrafoBebanItemModel.fromJson(b))
        .toList();

    final rawPeriods = json['periods'] as List? ?? [];
    final periodList = rawPeriods
        .whereType<Map<String, dynamic>>()
        .map((p) => PenyulangPeriodModel.fromJson(p))
        .toList();

    return BebanTrafoModel(
      id: json['id'] as int? ?? json['trafoId'] as int? ?? 0,
      nama: json['nama'] as String? ?? json['namaTrafo'] as String? ?? (json['trafo'] is Map ? json['trafo']['nama'] as String? ?? '-' : '-'),
      iMax: (json['iMax'] as num?)?.toDouble() ?? 0.0,
      garduIndukId: giId,
      garduIndukNama: giNama,
      beban: bebanList,
      periods: periodList,
    );
  }

  BebanTrafoModel copyWith({
    int? id,
    String? nama,
    double? iMax,
    int? garduIndukId,
    String? garduIndukNama,
    List<TrafoBebanItemModel>? beban,
    List<PenyulangPeriodModel>? periods,
  }) {
    return BebanTrafoModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      iMax: iMax ?? this.iMax,
      garduIndukId: garduIndukId ?? this.garduIndukId,
      garduIndukNama: garduIndukNama ?? this.garduIndukNama,
      beban: beban ?? this.beban,
      periods: periods ?? this.periods,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'iMax': iMax,
        'garduInduk': {
          'id': garduIndukId,
          'nama': garduIndukNama,
        },
        'beban': beban.map((b) => b.toJson()).toList(),
        'periods': periods.map((p) => p.toJson()).toList(),
      };
}

class TrafoBebanItemModel {
  final int id;
  final int periode;
  final double beban;
  final String status;
  final int tanggal;
  final int bulan;
  final int tahun;
  final String? createdAt;

  const TrafoBebanItemModel({
    required this.id,
    required this.periode,
    required this.beban,
    required this.status,
    required this.tanggal,
    required this.bulan,
    required this.tahun,
    this.createdAt,
  });

  factory TrafoBebanItemModel.fromJson(Map<String, dynamic> json) {
    return TrafoBebanItemModel(
      id: json['id'] as int? ?? 0,
      periode: json['periode'] as int? ?? 0,
      beban: (json['beban'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'ON TIME',
      tanggal: json['tanggal'] as int? ?? 0,
      bulan: json['bulan'] as int? ?? 0,
      tahun: json['tahun'] as int? ?? 0,
      createdAt: json['createdAt'] as String?,
    );
  }

  TrafoBebanItemModel copyWith({
    int? id,
    int? periode,
    double? beban,
    String? status,
    int? tanggal,
    int? bulan,
    int? tahun,
    String? createdAt,
  }) {
    return TrafoBebanItemModel(
      id: id ?? this.id,
      periode: periode ?? this.periode,
      beban: beban ?? this.beban,
      status: status ?? this.status,
      tanggal: tanggal ?? this.tanggal,
      bulan: bulan ?? this.bulan,
      tahun: tahun ?? this.tahun,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'periode': periode,
        'beban': beban,
        'status': status,
        'tanggal': tanggal,
        'bulan': bulan,
        'tahun': tahun,
        if (createdAt != null) 'createdAt': createdAt,
      };
}

class BebanTrafoTodayItemModel {
  final int id;
  final int trafoId;
  final String trafoNama;
  final int periode;
  final int tanggal;
  final int bulan;
  final int tahun;
  final double beban;
  final Map<String, dynamic>? foto;
  final String status;
  final DateTime? createdAt;

  const BebanTrafoTodayItemModel({
    required this.id,
    required this.trafoId,
    required this.trafoNama,
    required this.periode,
    required this.tanggal,
    required this.bulan,
    required this.tahun,
    required this.beban,
    this.foto,
    required this.status,
    this.createdAt,
  });

  factory BebanTrafoTodayItemModel.fromJson(Map<String, dynamic> json) {
    final trafo = json['trafo'] is Map ? json['trafo'] as Map : {};
    DateTime? parsedCreatedAt;
    if (json['createdAt'] != null) {
      try {
        parsedCreatedAt = DateTime.parse(json['createdAt'].toString());
      } catch (_) {}
    }

    return BebanTrafoTodayItemModel(
      id: json['id'] as int? ?? 0,
      trafoId: trafo['id'] as int? ?? json['trafoId'] as int? ?? 0,
      trafoNama: trafo['nama'] as String? ?? json['trafoNama'] as String? ?? '-',
      periode: json['periode'] as int? ?? 0,
      tanggal: json['tanggal'] as int? ?? 0,
      bulan: json['bulan'] as int? ?? 0,
      tahun: json['tahun'] as int? ?? 0,
      beban: (json['beban'] as num?)?.toDouble() ?? 0.0,
      foto: json['foto'] is Map<String, dynamic> ? json['foto'] as Map<String, dynamic> : null,
      status: json['status'] as String? ?? 'ON TIME',
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'trafoId': trafoId,
        'trafoNama': trafoNama,
        'periode': periode,
        'tanggal': tanggal,
        'bulan': bulan,
        'tahun': tahun,
        'beban': beban,
        'foto': foto,
        'status': status,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };
}

class PenyulangPeriodModel {
  final int periode;
  final int tanggal;
  final int bulan;
  final int tahun;

  const PenyulangPeriodModel({
    required this.periode,
    required this.tanggal,
    required this.bulan,
    required this.tahun,
  });

  factory PenyulangPeriodModel.fromJson(Map<String, dynamic> json) {
    return PenyulangPeriodModel(
      periode: json['periode'] as int? ?? 0,
      tanggal: json['tanggal'] as int? ?? 0,
      bulan: json['bulan'] as int? ?? 0,
      tahun: json['tahun'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'periode': periode,
        'tanggal': tanggal,
        'bulan': bulan,
        'tahun': tahun,
      };
}

class PenyulangBebanItemModel {
  final int id;
  final int periode;
  final double beban;
  final String status;
  final int tanggal;
  final int bulan;
  final int tahun;
  final String? createdAt;

  const PenyulangBebanItemModel({
    required this.id,
    required this.periode,
    required this.beban,
    required this.status,
    required this.tanggal,
    required this.bulan,
    required this.tahun,
    this.createdAt,
  });

  factory PenyulangBebanItemModel.fromJson(Map<String, dynamic> json) {
    return PenyulangBebanItemModel(
      id: json['id'] as int? ?? 0,
      periode: json['periode'] as int? ?? 0,
      beban: (json['beban'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'ON TIME',
      tanggal: json['tanggal'] as int? ?? 0,
      bulan: json['bulan'] as int? ?? 0,
      tahun: json['tahun'] as int? ?? 0,
      createdAt: json['createdAt'] as String?,
    );
  }

  PenyulangBebanItemModel copyWith({
    int? id,
    int? periode,
    double? beban,
    String? status,
    int? tanggal,
    int? bulan,
    int? tahun,
    String? createdAt,
  }) {
    return PenyulangBebanItemModel(
      id: id ?? this.id,
      periode: periode ?? this.periode,
      beban: beban ?? this.beban,
      status: status ?? this.status,
      tanggal: tanggal ?? this.tanggal,
      bulan: bulan ?? this.bulan,
      tahun: tahun ?? this.tahun,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'periode': periode,
        'beban': beban,
        'status': status,
        'tanggal': tanggal,
        'bulan': bulan,
        'tahun': tahun,
        if (createdAt != null) 'createdAt': createdAt,
      };
}

class PenyulangManuverItemModel {
  final int id;
  final int periode;
  final int tanggal;
  final int bulan;
  final int tahun;
  final String status;

  const PenyulangManuverItemModel({
    required this.id,
    required this.periode,
    required this.tanggal,
    required this.bulan,
    required this.tahun,
    required this.status,
  });

  factory PenyulangManuverItemModel.fromJson(Map<String, dynamic> json) {
    return PenyulangManuverItemModel(
      id: json['id'] as int? ?? 0,
      periode: json['periode'] as int? ?? 0,
      tanggal: json['tanggal'] as int? ?? 0,
      bulan: json['bulan'] as int? ?? 0,
      tahun: json['tahun'] as int? ?? 0,
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'periode': periode,
        'tanggal': tanggal,
        'bulan': bulan,
        'tahun': tahun,
        'status': status,
      };
}

class PenyulangModel {
  final int id;
  final String nama;
  final String statusCB;
  final double iMax;
  final String rel;
  final int noUrutCustom;
  final int garduIndukId;
  final String garduIndukNama;
  final List<PenyulangPeriodModel> periods;
  final List<PenyulangBebanItemModel> beban;
  final List<PenyulangManuverItemModel> manuver;

  const PenyulangModel({
    required this.id,
    required this.nama,
    required this.statusCB,
    required this.iMax,
    required this.rel,
    this.noUrutCustom = 0,
    required this.garduIndukId,
    required this.garduIndukNama,
    this.periods = const [],
    this.beban = const [],
    this.manuver = const [],
  });

  PenyulangModel copyWith({
    int? id,
    String? nama,
    String? statusCB,
    double? iMax,
    String? rel,
    int? noUrutCustom,
    int? garduIndukId,
    String? garduIndukNama,
    List<PenyulangPeriodModel>? periods,
    List<PenyulangBebanItemModel>? beban,
    List<PenyulangManuverItemModel>? manuver,
  }) {
    return PenyulangModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      statusCB: statusCB ?? this.statusCB,
      iMax: iMax ?? this.iMax,
      rel: rel ?? this.rel,
      noUrutCustom: noUrutCustom ?? this.noUrutCustom,
      garduIndukId: garduIndukId ?? this.garduIndukId,
      garduIndukNama: garduIndukNama ?? this.garduIndukNama,
      periods: periods ?? this.periods,
      beban: beban ?? this.beban,
      manuver: manuver ?? this.manuver,
    );
  }

  factory PenyulangModel.fromJson(Map<String, dynamic> json) {
    final gi = json['garduInduk'] is Map
        ? Map<String, dynamic>.from(json['garduInduk'] as Map)
        : <String, dynamic>{};
    final periodsList = (json['periods'] as List?)
            ?.whereType<Map>()
            .map((e) => PenyulangPeriodModel.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    final bebanList = (json['beban'] as List?)
            ?.whereType<Map>()
            .map((e) => PenyulangBebanItemModel.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    final manuverList = (json['manuver'] as List?)
            ?.whereType<Map>()
            .map((e) => PenyulangManuverItemModel.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    return PenyulangModel(
      id: json['id'] as int? ?? 0,
      nama: json['nama'] as String? ?? '-',
      statusCB: json['statusCB'] as String? ?? 'ON',
      iMax: (json['iMax'] as num?)?.toDouble() ?? 0.0,
      rel: json['rel']?.toString() ?? '-',
      noUrutCustom: json['noUrutCustom'] as int? ?? 0,
      garduIndukId: gi['id'] as int? ?? json['garduIndukId'] as int? ?? 0,
      garduIndukNama: gi['nama'] as String? ?? json['garduIndukNama'] as String? ?? '-',
      periods: periodsList,
      beban: bebanList,
      manuver: manuverList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'statusCB': statusCB,
        'iMax': iMax,
        'rel': rel,
        'noUrutCustom': noUrutCustom,
        'garduInduk': {
          'id': garduIndukId,
          'nama': garduIndukNama,
        },
        'periods': periods.map((p) => p.toJson()).toList(),
        'beban': beban.map((b) => b.toJson()).toList(),
        'manuver': manuver.map((m) => m.toJson()).toList(),
      };
}

/// Alias agar kompatibel dengan OpgiRealisasiState lama
typedef BebanPenyulangModel = PenyulangModel;

class BebanPenyulangTodayItemModel {
  final int id;
  final int penyulangId;
  final String penyulangNama;
  final int periode;
  final int tanggal;
  final int bulan;
  final int tahun;
  final double beban;
  final Map<String, dynamic>? foto;
  final String status;
  final DateTime? createdAt;

  const BebanPenyulangTodayItemModel({
    required this.id,
    required this.penyulangId,
    required this.penyulangNama,
    required this.periode,
    required this.tanggal,
    required this.bulan,
    required this.tahun,
    required this.beban,
    this.foto,
    required this.status,
    this.createdAt,
  });

  BebanPenyulangTodayItemModel copyWith({
    int? id,
    int? penyulangId,
    String? penyulangNama,
    int? periode,
    int? tanggal,
    int? bulan,
    int? tahun,
    double? beban,
    Map<String, dynamic>? foto,
    String? status,
    DateTime? createdAt,
  }) {
    return BebanPenyulangTodayItemModel(
      id: id ?? this.id,
      penyulangId: penyulangId ?? this.penyulangId,
      penyulangNama: penyulangNama ?? this.penyulangNama,
      periode: periode ?? this.periode,
      tanggal: tanggal ?? this.tanggal,
      bulan: bulan ?? this.bulan,
      tahun: tahun ?? this.tahun,
      beban: beban ?? this.beban,
      foto: foto ?? this.foto,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory BebanPenyulangTodayItemModel.fromJson(Map<String, dynamic> json) {
    final penyulang = json['penyulang'] as Map<String, dynamic>? ?? {};
    DateTime? parsedCreatedAt;
    if (json['createdAt'] != null) {
      try {
        parsedCreatedAt = DateTime.parse(json['createdAt'].toString());
      } catch (_) {}
    }

    return BebanPenyulangTodayItemModel(
      id: json['id'] as int? ?? 0,
      penyulangId: penyulang['id'] as int? ?? json['penyulangId'] as int? ?? 0,
      penyulangNama: penyulang['nama'] as String? ?? json['penyulangNama'] as String? ?? '-',
      periode: json['periode'] as int? ?? 0,
      tanggal: json['tanggal'] as int? ?? 0,
      bulan: json['bulan'] as int? ?? 0,
      tahun: json['tahun'] as int? ?? 0,
      beban: (json['beban'] as num?)?.toDouble() ?? 0.0,
      foto: json['foto'] is Map<String, dynamic> ? json['foto'] as Map<String, dynamic> : null,
      status: json['status'] as String? ?? 'ON TIME',
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'penyulangId': penyulangId,
        'penyulangNama': penyulangNama,
        'periode': periode,
        'tanggal': tanggal,
        'bulan': bulan,
        'tahun': tahun,
        'beban': beban,
        'foto': foto,
        'status': status,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };
}

class KwhHarianModel {
  final int id; // objectId (penyulangId atau trafoId)
  final String nama;
  final double fk; // faktor kali
  final int? noUrut;
  final int garduIndukId;
  final String garduIndukNama;
  final String type; // 'PENYULANG' | 'TRAFO'
  final String kelompok; // 'FEEDER' | 'TRAFO TRANSAKSI' | 'TRAFO PEMBANDING' | 'TRAFO PS'
  final bool disabled;
  final List<KwhHarianEntryModel> kwhHarian;
  final bool? overrideDone;

  bool get isDone => overrideDone ?? kwhHarian.isNotEmpty;

  // Backward compatibility fields
  String get tanggal => kwhHarian.isNotEmpty ? '${kwhHarian.first.tanggal}-${kwhHarian.first.bulan}-${kwhHarian.first.tahun}' : '';
  String get namaPenyulang => nama;
  double get standAwal => 0.0;
  double get standAkhir => 0.0;
  double get faktorKali => fk;
  double? get totalKwh => null;

  const KwhHarianModel({
    required this.id,
    required this.nama,
    this.fk = 1.0,
    this.noUrut,
    required this.garduIndukId,
    required this.garduIndukNama,
    required this.type,
    required this.kelompok,
    this.disabled = false,
    this.kwhHarian = const [],
    this.overrideDone,
  });

  factory KwhHarianModel.fromJson(Map<String, dynamic> json) {
    final gi = json['garduInduk'];
    final giId = gi is Map ? (gi['id'] as int? ?? 0) : (json['garduIndukId'] as int? ?? 0);
    final giNama = gi is Map ? (gi['nama'] as String? ?? '-') : (json['garduIndukNama'] as String? ?? '-');

    final rawKwh = json['kwhHarian'] as List? ?? [];
    final kwhList = rawKwh
        .whereType<Map<String, dynamic>>()
        .map((k) => KwhHarianEntryModel.fromJson(k))
        .toList();

    return KwhHarianModel(
      id: json['id'] as int? ?? json['objectId'] as int? ?? 0,
      nama: json['nama'] as String? ?? json['namaPenyulang'] as String? ?? '-',
      fk: (json['fk'] as num?)?.toDouble() ?? (json['faktorKali'] as num?)?.toDouble() ?? 1.0,
      noUrut: json['noUrut'] as int?,
      garduIndukId: giId,
      garduIndukNama: giNama,
      type: json['type'] as String? ?? 'PENYULANG',
      kelompok: json['kelompok'] as String? ?? 'FEEDER',
      disabled: json['disabled'] == true || json['disabled'] == 1,
      kwhHarian: kwhList,
    );
  }

  KwhHarianModel copyWith({
    int? id,
    String? nama,
    double? fk,
    int? noUrut,
    int? garduIndukId,
    String? garduIndukNama,
    String? type,
    String? kelompok,
    bool? disabled,
    List<KwhHarianEntryModel>? kwhHarian,
    bool? isDone,
  }) {
    return KwhHarianModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      fk: fk ?? this.fk,
      noUrut: noUrut ?? this.noUrut,
      garduIndukId: garduIndukId ?? this.garduIndukId,
      garduIndukNama: garduIndukNama ?? this.garduIndukNama,
      type: type ?? this.type,
      kelompok: kelompok ?? this.kelompok,
      disabled: disabled ?? this.disabled,
      kwhHarian: kwhHarian ?? this.kwhHarian,
      overrideDone: isDone ?? overrideDone,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'fk': fk,
        if (noUrut != null) 'noUrut': noUrut,
        'garduInduk': {
          'id': garduIndukId,
          'nama': garduIndukNama,
        },
        'type': type,
        'kelompok': kelompok,
        'disabled': disabled,
        'kwhHarian': kwhHarian.map((k) => k.toJson()).toList(),
      };
}

class KwhHarianEntryModel {
  final int id;
  final int tanggal;
  final int bulan;
  final int tahun;
  final String jenis;
  final double stand;
  final String status;
  final String kelompok;
  final String? keterangan;
  final String? createdAt;

  const KwhHarianEntryModel({
    required this.id,
    required this.tanggal,
    required this.bulan,
    required this.tahun,
    required this.jenis,
    required this.stand,
    required this.status,
    required this.kelompok,
    this.keterangan,
    this.createdAt,
  });

  factory KwhHarianEntryModel.fromJson(Map<String, dynamic> json) {
    return KwhHarianEntryModel(
      id: json['id'] as int? ?? 0,
      tanggal: json['tanggal'] as int? ?? 0,
      bulan: json['bulan'] as int? ?? 0,
      tahun: json['tahun'] as int? ?? 0,
      jenis: json['jenis'] as String? ?? '-',
      stand: (json['stand'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'ON TIME',
      kelompok: json['kelompok'] as String? ?? 'FEEDER',
      keterangan: json['keterangan'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tanggal': tanggal,
        'bulan': bulan,
        'tahun': tahun,
        'jenis': jenis,
        'stand': stand,
        'status': status,
        'kelompok': kelompok,
        if (keterangan != null) 'keterangan': keterangan,
        if (createdAt != null) 'createdAt': createdAt,
      };
}

class KwhHarianTodayItemModel {
  final int id;
  final String jenis;
  final double stand;
  final String status;
  final String? keterangan;
  final Map<String, dynamic>? fotoStand;
  final DateTime? createdAt;

  const KwhHarianTodayItemModel({
    required this.id,
    required this.jenis,
    required this.stand,
    required this.status,
    this.keterangan,
    this.fotoStand,
    this.createdAt,
  });

  factory KwhHarianTodayItemModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedCreatedAt;
    if (json['createdAt'] != null) {
      try {
        parsedCreatedAt = DateTime.parse(json['createdAt'].toString());
      } catch (_) {}
    }

    return KwhHarianTodayItemModel(
      id: json['id'] as int? ?? 0,
      jenis: json['jenis'] as String? ?? '-',
      stand: (json['stand'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'ON TIME',
      keterangan: json['keterangan'] as String?,
      fotoStand: json['fotoStand'] is Map<String, dynamic> ? json['fotoStand'] as Map<String, dynamic> : null,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'jenis': jenis,
        'stand': stand,
        'status': status,
        if (keterangan != null) 'keterangan': keterangan,
        'fotoStand': fotoStand,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };
}

class TeganganTrafoModel {
  final int id;
  final String nama;
  final int garduIndukId;
  final String garduIndukNama;
  final List<TrafoTeganganItemModel> tegangan;
  final List<PenyulangPeriodModel> periods;

  // Backward compatibility fields
  int get trafoId => id;
  String get namaTrafo => nama;
  int get periode => tegangan.isNotEmpty ? tegangan.first.periode : 0;
  double? get mv => tegangan.isNotEmpty ? tegangan.first.mv : null;
  double? get hv => tegangan.isNotEmpty ? tegangan.first.hv : null;
  double? get tegangan20kv => mv;
  double? get tegangan150kv => hv;
  double? get vrn => null;
  double? get vsn => null;
  double? get vtn => null;
  double? get vrs => null;
  double? get vst => null;
  double? get vtr => null;
  double get teganganBus => mv ?? 0.0;
  int get tapChanger => 1;

  const TeganganTrafoModel({
    required this.id,
    required this.nama,
    required this.garduIndukId,
    required this.garduIndukNama,
    this.tegangan = const [],
    this.periods = const [],
  });

  factory TeganganTrafoModel.fromJson(Map<String, dynamic> json) {
    final gi = json['garduInduk'];
    final giId = gi is Map ? (gi['id'] as int? ?? 0) : (json['garduIndukId'] as int? ?? 0);
    final giNama = gi is Map ? (gi['nama'] as String? ?? '-') : (json['garduIndukNama'] as String? ?? '-');

    final rawTegangan = json['tegangan'] as List? ?? [];
    final teganganList = rawTegangan
        .whereType<Map<String, dynamic>>()
        .map((t) => TrafoTeganganItemModel.fromJson(t))
        .toList();

    final rawPeriods = json['periods'] as List? ?? [];
    final periodList = rawPeriods
        .whereType<Map<String, dynamic>>()
        .map((p) => PenyulangPeriodModel.fromJson(p))
        .toList();

    return TeganganTrafoModel(
      id: json['id'] as int? ?? json['trafoId'] as int? ?? 0,
      nama: json['nama'] as String? ?? json['namaTrafo'] as String? ?? (json['trafo'] is Map ? json['trafo']['nama'] as String? ?? '-' : '-'),
      garduIndukId: giId,
      garduIndukNama: giNama,
      tegangan: teganganList,
      periods: periodList,
    );
  }

  TeganganTrafoModel copyWith({
    int? id,
    String? nama,
    int? garduIndukId,
    String? garduIndukNama,
    List<TrafoTeganganItemModel>? tegangan,
    List<PenyulangPeriodModel>? periods,
  }) {
    return TeganganTrafoModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      garduIndukId: garduIndukId ?? this.garduIndukId,
      garduIndukNama: garduIndukNama ?? this.garduIndukNama,
      tegangan: tegangan ?? this.tegangan,
      periods: periods ?? this.periods,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'garduInduk': {
          'id': garduIndukId,
          'nama': garduIndukNama,
        },
        'tegangan': tegangan.map((t) => t.toJson()).toList(),
        'periods': periods.map((p) => p.toJson()).toList(),
      };
}

class TrafoTeganganItemModel {
  final int id;
  final int periode;
  final double mv;
  final double hv;
  final String status;
  final int tanggal;
  final int bulan;
  final int tahun;
  final String? createdAt;

  const TrafoTeganganItemModel({
    required this.id,
    required this.periode,
    required this.mv,
    required this.hv,
    required this.status,
    required this.tanggal,
    required this.bulan,
    required this.tahun,
    this.createdAt,
  });

  factory TrafoTeganganItemModel.fromJson(Map<String, dynamic> json) {
    return TrafoTeganganItemModel(
      id: json['id'] as int? ?? 0,
      periode: json['periode'] as int? ?? 0,
      mv: (json['mv'] as num?)?.toDouble() ?? 0.0,
      hv: (json['hv'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'ON TIME',
      tanggal: json['tanggal'] as int? ?? 0,
      bulan: json['bulan'] as int? ?? 0,
      tahun: json['tahun'] as int? ?? 0,
      createdAt: json['createdAt'] as String?,
    );
  }

  TrafoTeganganItemModel copyWith({
    int? id,
    int? periode,
    double? mv,
    double? hv,
    String? status,
    int? tanggal,
    int? bulan,
    int? tahun,
    String? createdAt,
  }) {
    return TrafoTeganganItemModel(
      id: id ?? this.id,
      periode: periode ?? this.periode,
      mv: mv ?? this.mv,
      hv: hv ?? this.hv,
      status: status ?? this.status,
      tanggal: tanggal ?? this.tanggal,
      bulan: bulan ?? this.bulan,
      tahun: tahun ?? this.tahun,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'periode': periode,
        'mv': mv,
        'hv': hv,
        'status': status,
        'tanggal': tanggal,
        'bulan': bulan,
        'tahun': tahun,
        if (createdAt != null) 'createdAt': createdAt,
      };
}

class TeganganTrafoTodayItemModel {
  final int id;
  final int trafoId;
  final String trafoNama;
  final int periode;
  final int tanggal;
  final int bulan;
  final int tahun;
  final double mv;
  final double hv;
  final Map<String, dynamic>? fotoMV;
  final Map<String, dynamic>? fotoHV;
  final String status;
  final DateTime? createdAt;

  const TeganganTrafoTodayItemModel({
    required this.id,
    required this.trafoId,
    required this.trafoNama,
    required this.periode,
    required this.tanggal,
    required this.bulan,
    required this.tahun,
    required this.mv,
    required this.hv,
    this.fotoMV,
    this.fotoHV,
    required this.status,
    this.createdAt,
  });

  factory TeganganTrafoTodayItemModel.fromJson(Map<String, dynamic> json) {
    final trafo = json['trafo'] is Map ? json['trafo'] as Map : {};
    DateTime? parsedCreatedAt;
    if (json['createdAt'] != null) {
      try {
        parsedCreatedAt = DateTime.parse(json['createdAt'].toString());
      } catch (_) {}
    }

    return TeganganTrafoTodayItemModel(
      id: json['id'] as int? ?? 0,
      trafoId: trafo['id'] as int? ?? json['trafoId'] as int? ?? 0,
      trafoNama: trafo['nama'] as String? ?? json['trafoNama'] as String? ?? '-',
      periode: json['periode'] as int? ?? 0,
      tanggal: json['tanggal'] as int? ?? 0,
      bulan: json['bulan'] as int? ?? 0,
      tahun: json['tahun'] as int? ?? 0,
      mv: (json['mv'] as num?)?.toDouble() ?? 0.0,
      hv: (json['hv'] as num?)?.toDouble() ?? 0.0,
      fotoMV: json['fotoMV'] is Map<String, dynamic> ? json['fotoMV'] as Map<String, dynamic> : null,
      fotoHV: json['fotoHV'] is Map<String, dynamic> ? json['fotoHV'] as Map<String, dynamic> : null,
      status: json['status'] as String? ?? 'ON TIME',
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'trafoId': trafoId,
        'trafoNama': trafoNama,
        'periode': periode,
        'tanggal': tanggal,
        'bulan': bulan,
        'tahun': tahun,
        'mv': mv,
        'hv': hv,
        'fotoMV': fotoMV,
        'fotoHV': fotoHV,
        'status': status,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };
}
