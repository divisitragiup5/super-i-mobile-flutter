/// Model data untuk Realisasi Beban Trafo, Beban Penyulang, KWH Harian, dan Tegangan Trafo

class BebanTrafoModel {
  final int? id;
  final int trafoId;
  final String namaTrafo;
  final int periode; // 0..23
  final double arus;
  final double? tegangan;
  final double? suhuWinding;
  final double? suhuOli;

  const BebanTrafoModel({
    this.id,
    required this.trafoId,
    required this.namaTrafo,
    required this.periode,
    required this.arus,
    this.tegangan,
    this.suhuWinding,
    this.suhuOli,
  });

  factory BebanTrafoModel.fromJson(Map<String, dynamic> json) {
    return BebanTrafoModel(
      id: json['id'] as int?,
      trafoId: json['trafoId'] as int? ?? json['trafo']?['id'] as int? ?? 0,
      namaTrafo: json['trafo']?['nama'] as String? ?? json['namaTrafo'] as String? ?? '-',
      periode: json['periode'] as int? ?? 0,
      arus: (json['arus'] as num?)?.toDouble() ?? 0.0,
      tegangan: (json['tegangan'] as num?)?.toDouble(),
      suhuWinding: (json['suhuWinding'] as num?)?.toDouble(),
      suhuOli: (json['suhuOli'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'trafoId': trafoId,
        'periode': periode,
        'arus': arus,
        if (tegangan != null) 'tegangan': tegangan,
        if (suhuWinding != null) 'suhuWinding': suhuWinding,
        if (suhuOli != null) 'suhuOli': suhuOli,
      };
}

class BebanPenyulangModel {
  final int? id;
  final int penyulangId;
  final String namaPenyulang;
  final int periode; // 0..23
  final double arusR;
  final double arusS;
  final double arusT;
  final double arusN;
  final double? dayaMw;
  final double? dayaMvar;
  final double? cosPhi;
  final int urutan;

  const BebanPenyulangModel({
    this.id,
    required this.penyulangId,
    required this.namaPenyulang,
    required this.periode,
    required this.arusR,
    required this.arusS,
    required this.arusT,
    required this.arusN,
    this.dayaMw,
    this.dayaMvar,
    this.cosPhi,
    this.urutan = 0,
  });

  factory BebanPenyulangModel.fromJson(Map<String, dynamic> json) {
    return BebanPenyulangModel(
      id: json['id'] as int?,
      penyulangId: json['penyulangId'] as int? ?? json['penyulang']?['id'] as int? ?? 0,
      namaPenyulang: json['penyulang']?['nama'] as String? ?? json['namaPenyulang'] as String? ?? '-',
      periode: json['periode'] as int? ?? 0,
      arusR: (json['arusR'] as num?)?.toDouble() ?? 0.0,
      arusS: (json['arusS'] as num?)?.toDouble() ?? 0.0,
      arusT: (json['arusT'] as num?)?.toDouble() ?? 0.0,
      arusN: (json['arusN'] as num?)?.toDouble() ?? 0.0,
      dayaMw: (json['dayaMw'] as num?)?.toDouble(),
      dayaMvar: (json['dayaMvar'] as num?)?.toDouble(),
      cosPhi: (json['cosPhi'] as num?)?.toDouble(),
      urutan: json['urutan'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'penyulangId': penyulangId,
        'periode': periode,
        'arusR': arusR,
        'arusS': arusS,
        'arusT': arusT,
        'arusN': arusN,
        if (dayaMw != null) 'dayaMw': dayaMw,
        if (dayaMvar != null) 'dayaMvar': dayaMvar,
        if (cosPhi != null) 'cosPhi': cosPhi,
        'urutan': urutan,
      };
}

class KwhHarianModel {
  final int? id;
  final int garduIndukId;
  final String tanggal;
  final String namaPenyulang;
  final double standAwal;
  final double standAkhir;
  final double faktorKali;
  final double? totalKwh;
  final double standAwalKirim;
  final double standAkhirKirim;
  final double standAwalTerima;
  final double standAkhirTerima;

  const KwhHarianModel({
    this.id,
    required this.garduIndukId,
    required this.tanggal,
    this.namaPenyulang = '',
    this.standAwal = 0.0,
    this.standAkhir = 0.0,
    this.faktorKali = 1.0,
    this.totalKwh,
    this.standAwalKirim = 0.0,
    this.standAkhirKirim = 0.0,
    this.standAwalTerima = 0.0,
    this.standAkhirTerima = 0.0,
  });

  factory KwhHarianModel.fromJson(Map<String, dynamic> json) {
    return KwhHarianModel(
      id: json['id'] as int?,
      garduIndukId: json['garduIndukId'] as int? ?? 0,
      tanggal: json['tanggal'] as String? ?? json['date'] as String? ?? '',
      namaPenyulang: json['namaPenyulang'] as String? ?? json['nama'] as String? ?? '',
      standAwal: (json['standAwal'] as num?)?.toDouble() ?? (json['standAwalKirim'] as num?)?.toDouble() ?? 0.0,
      standAkhir: (json['standAkhir'] as num?)?.toDouble() ?? (json['standAkhirKirim'] as num?)?.toDouble() ?? 0.0,
      faktorKali: (json['faktorKali'] as num?)?.toDouble() ?? 1.0,
      totalKwh: (json['totalKwh'] as num?)?.toDouble(),
      standAwalKirim: (json['standAwalKirim'] as num?)?.toDouble() ?? 0.0,
      standAkhirKirim: (json['standAkhirKirim'] as num?)?.toDouble() ?? 0.0,
      standAwalTerima: (json['standAwalTerima'] as num?)?.toDouble() ?? 0.0,
      standAkhirTerima: (json['standAkhirTerima'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'garduIndukId': garduIndukId,
        'tanggal': tanggal,
        'namaPenyulang': namaPenyulang,
        'standAwal': standAwal,
        'standAkhir': standAkhir,
        'faktorKali': faktorKali,
        if (totalKwh != null) 'totalKwh': totalKwh,
        'standAwalKirim': standAwalKirim,
        'standAkhirKirim': standAkhirKirim,
        'standAwalTerima': standAwalTerima,
        'standAkhirTerima': standAkhirTerima,
      };
}

class TeganganTrafoModel {
  final int? id;
  final int trafoId;
  final String namaTrafo;
  final int periode; // 0..23
  final double? tegangan20kv;
  final double? tegangan150kv;
  final double? mv;
  final double? hv;
  final double? vrn;
  final double? vsn;
  final double? vtn;
  final double? vrs;
  final double? vst;
  final double? vtr;
  final double teganganBus;
  final int tapChanger;

  const TeganganTrafoModel({
    this.id,
    required this.trafoId,
    required this.namaTrafo,
    required this.periode,
    this.tegangan20kv,
    this.tegangan150kv,
    this.mv,
    this.hv,
    this.vrn,
    this.vsn,
    this.vtn,
    this.vrs,
    this.vst,
    this.vtr,
    this.teganganBus = 0.0,
    this.tapChanger = 1,
  });

  factory TeganganTrafoModel.fromJson(Map<String, dynamic> json) {
    final mvVal = (json['mv'] as num?)?.toDouble() ?? (json['tegangan20kv'] as num?)?.toDouble();
    final hvVal = (json['hv'] as num?)?.toDouble() ?? (json['tegangan150kv'] as num?)?.toDouble();
    return TeganganTrafoModel(
      id: json['id'] as int?,
      trafoId: json['trafoId'] as int? ?? json['trafo']?['id'] as int? ?? 0,
      namaTrafo: json['trafo']?['nama'] as String? ?? json['namaTrafo'] as String? ?? '-',
      periode: json['periode'] as int? ?? 0,
      tegangan20kv: mvVal,
      tegangan150kv: hvVal,
      mv: mvVal,
      hv: hvVal,
      vrn: (json['vrn'] as num?)?.toDouble(),
      vsn: (json['vsn'] as num?)?.toDouble(),
      vtn: (json['vtn'] as num?)?.toDouble(),
      vrs: (json['vrs'] as num?)?.toDouble(),
      vst: (json['vst'] as num?)?.toDouble(),
      vtr: (json['vtr'] as num?)?.toDouble(),
      teganganBus: (json['teganganBus'] as num?)?.toDouble() ?? mvVal ?? 0.0,
      tapChanger: json['tapChanger'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'trafoId': trafoId,
        'periode': periode,
        if (mv != null) 'mv': mv,
        if (hv != null) 'hv': hv,
        if (tegangan20kv != null) 'tegangan20kv': tegangan20kv,
        if (tegangan150kv != null) 'tegangan150kv': tegangan150kv,
        if (vrn != null) 'vrn': vrn,
        if (vsn != null) 'vsn': vsn,
        if (vtn != null) 'vtn': vtn,
        if (vrs != null) 'vrs': vrs,
        if (vst != null) 'vst': vst,
        if (vtr != null) 'vtr': vtr,
        'teganganBus': teganganBus,
        'tapChanger': tapChanger,
      };
}
