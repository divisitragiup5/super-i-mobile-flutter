import 'dart:convert';
import 'package:equatable/equatable.dart';

Map<String, dynamic>? _safeMap(dynamic value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), v));
  }
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.startsWith('{')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map) {
          return decoded.map((k, v) => MapEntry(k.toString(), v));
        }
      } catch (_) {}
    }
  }
  return null;
}

List<dynamic> _safeList(dynamic value) {
  if (value == null) return const [];
  if (value is List) return value;
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.startsWith('[')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) return decoded;
      } catch (_) {}
    }
  }
  return const [];
}

List<String> _safeStringList(dynamic value) {
  if (value == null) return const [];
  if (value is List) {
    return value.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
  }
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.startsWith('[')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) {
          return decoded.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
        }
      } catch (_) {}
    }
    if (trimmed.isNotEmpty) {
      return [trimmed];
    }
  }
  return const [];
}

int? _safeInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

bool _safeBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.trim().toLowerCase();
    if (lower == 'true' || lower == '1') return true;
    if (lower == 'false' || lower == '0') return false;
  }
  return defaultValue;
}

class Il1KubikelItem extends Equatable {
  final int id; // penyulangId
  final String nama;
  final String? kode;
  final int? garduIndukId;
  final String? garduIndukNama;
  final Map<String, dynamic>? garduInduk;
  final String? rel;
  final String? merkKubikel;
  final int? trafoId;
  final bool isDisabled;
  final List<dynamic> il1;
  final Map<String, dynamic>? last;
  final Map<String, dynamic>? lastData;
  final String? status;
  final bool drafted;

  bool get sudahInspeksi => il1.isNotEmpty;

  const Il1KubikelItem({
    required this.id,
    required this.nama,
    this.kode,
    this.garduIndukId,
    this.garduIndukNama,
    this.garduInduk,
    this.rel,
    this.merkKubikel,
    this.trafoId,
    this.isDisabled = false,
    this.il1 = const [],
    this.last,
    this.lastData,
    this.status,
    this.drafted = false,
  });

  factory Il1KubikelItem.fromJson(Map<String, dynamic> json) {
    final il1List = _safeList(json['il1']);
    final lastItem = il1List.isNotEmpty ? _safeMap(il1List.first) : null;
    final gi = _safeMap(json['garduInduk']);

    return Il1KubikelItem(
      id: _safeInt(json['id']) ?? 0,
      nama: json['nama']?.toString() ?? '-',
      kode: json['kode']?.toString(),
      garduIndukId: _safeInt(gi?['id']) ?? _safeInt(json['garduIndukId']),
      garduIndukNama: gi?['nama']?.toString() ?? json['garduIndukNama']?.toString(),
      garduInduk: gi,
      rel: json['rel']?.toString(),
      merkKubikel: json['merkKubikel']?.toString(),
      trafoId: _safeInt(json['trafoId']),
      isDisabled: _safeBool(json['isDisabled']),
      il1: il1List,
      last: lastItem,
      lastData: _safeMap(json['lastData']),
      status: lastItem?['status']?.toString() ?? json['status']?.toString(),
      drafted: _safeBool(json['drafted']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      if (kode != null) 'kode': kode,
      if (garduIndukId != null) 'garduIndukId': garduIndukId,
      if (garduIndukNama != null) 'garduIndukNama': garduIndukNama,
      if (garduInduk != null) 'garduInduk': garduInduk,
      if (rel != null) 'rel': rel,
      if (merkKubikel != null) 'merkKubikel': merkKubikel,
      if (trafoId != null) 'trafoId': trafoId,
      'isDisabled': isDisabled,
      'il1': il1,
      if (last != null) 'last': last,
      if (lastData != null) 'lastData': lastData,
      if (status != null) 'status': status,
      'drafted': drafted,
    };
  }

  Il1KubikelItem copyWith({
    int? id,
    String? nama,
    String? kode,
    int? garduIndukId,
    String? garduIndukNama,
    Map<String, dynamic>? garduInduk,
    String? rel,
    String? merkKubikel,
    int? trafoId,
    bool? isDisabled,
    List<dynamic>? il1,
    Map<String, dynamic>? last,
    Map<String, dynamic>? lastData,
    String? status,
    bool? drafted,
  }) {
    return Il1KubikelItem(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      kode: kode ?? this.kode,
      garduIndukId: garduIndukId ?? this.garduIndukId,
      garduIndukNama: garduIndukNama ?? this.garduIndukNama,
      garduInduk: garduInduk ?? this.garduInduk,
      rel: rel ?? this.rel,
      merkKubikel: merkKubikel ?? this.merkKubikel,
      trafoId: trafoId ?? this.trafoId,
      isDisabled: isDisabled ?? this.isDisabled,
      il1: il1 ?? this.il1,
      last: last ?? this.last,
      lastData: lastData ?? this.lastData,
      status: status ?? this.status,
      drafted: drafted ?? this.drafted,
    );
  }

  @override
  List<Object?> get props => [id, nama, sudahInspeksi, status, drafted, il1];
}

class Il1TrafoPsItem extends Equatable {
  final int id; // trafoId
  final String nama;
  final int? garduIndukId;
  final String? garduIndukNama;
  final Map<String, dynamic>? garduInduk;
  final Map<String, dynamic>? trafo;
  final bool isDisabled;
  final List<dynamic> il1TrafoPS;
  final Map<String, dynamic>? last;
  final Map<String, dynamic>? lastData;
  final String? status;
  final bool drafted;

  bool get sudahInspeksi => il1TrafoPS.isNotEmpty;

  const Il1TrafoPsItem({
    required this.id,
    required this.nama,
    this.garduIndukId,
    this.garduIndukNama,
    this.garduInduk,
    this.trafo,
    this.isDisabled = false,
    this.il1TrafoPS = const [],
    this.last,
    this.lastData,
    this.status,
    this.drafted = false,
  });

  factory Il1TrafoPsItem.fromJson(Map<String, dynamic> json) {
    final il1List = _safeList(json['il1TrafoPS']);
    final lastItem = il1List.isNotEmpty ? _safeMap(il1List.first) : null;
    final gi = _safeMap(json['garduInduk']);

    return Il1TrafoPsItem(
      id: _safeInt(json['id']) ?? 0,
      nama: json['nama']?.toString() ?? '-',
      garduIndukId: _safeInt(gi?['id']) ?? _safeInt(json['garduIndukId']),
      garduIndukNama: gi?['nama']?.toString() ?? json['garduIndukNama']?.toString(),
      garduInduk: gi,
      trafo: _safeMap(json['trafo']),
      isDisabled: _safeBool(json['isDisabled']),
      il1TrafoPS: il1List,
      last: lastItem,
      lastData: _safeMap(json['lastData']),
      status: lastItem?['status']?.toString() ?? json['status']?.toString(),
      drafted: _safeBool(json['drafted']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      if (garduIndukId != null) 'garduIndukId': garduIndukId,
      if (garduIndukNama != null) 'garduIndukNama': garduIndukNama,
      if (garduInduk != null) 'garduInduk': garduInduk,
      if (trafo != null) 'trafo': trafo,
      'isDisabled': isDisabled,
      'il1TrafoPS': il1TrafoPS,
      if (last != null) 'last': last,
      if (lastData != null) 'lastData': lastData,
      if (status != null) 'status': status,
      'drafted': drafted,
    };
  }

  Il1TrafoPsItem copyWith({
    int? id,
    String? nama,
    int? garduIndukId,
    String? garduIndukNama,
    Map<String, dynamic>? garduInduk,
    Map<String, dynamic>? trafo,
    bool? isDisabled,
    List<dynamic>? il1TrafoPS,
    Map<String, dynamic>? last,
    Map<String, dynamic>? lastData,
    String? status,
    bool? drafted,
  }) {
    return Il1TrafoPsItem(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      garduIndukId: garduIndukId ?? this.garduIndukId,
      garduIndukNama: garduIndukNama ?? this.garduIndukNama,
      garduInduk: garduInduk ?? this.garduInduk,
      trafo: trafo ?? this.trafo,
      isDisabled: isDisabled ?? this.isDisabled,
      il1TrafoPS: il1TrafoPS ?? this.il1TrafoPS,
      last: last ?? this.last,
      lastData: lastData ?? this.lastData,
      status: status ?? this.status,
      drafted: drafted ?? this.drafted,
    );
  }

  @override
  List<Object?> get props => [id, nama, sudahInspeksi, status, drafted, il1TrafoPS];
}

class Il1SipilItem extends Equatable {
  final int id;
  final int garduIndukId;
  final String? garduIndukNama;
  final Map<String, dynamic>? garduInduk;
  final String gedung;
  final String nama;
  final bool isDisabled;
  final List<dynamic> il1Sipil;
  final Map<String, dynamic>? last;
  final Map<String, dynamic>? lastData;
  final String? status;
  final bool drafted;

  bool get sudahInspeksi => il1Sipil.isNotEmpty;

  const Il1SipilItem({
    this.id = 0,
    required this.garduIndukId,
    this.garduIndukNama,
    this.garduInduk,
    required this.gedung,
    required this.nama,
    this.isDisabled = false,
    this.il1Sipil = const [],
    this.last,
    this.lastData,
    this.status,
    this.drafted = false,
  });

  factory Il1SipilItem.fromJson(Map<String, dynamic> json) {
    final il1List = _safeList(json['il1Sipil']);
    final lastItem = il1List.isNotEmpty ? _safeMap(il1List.first) : null;
    final gi = _safeMap(json['garduInduk']);

    final resolvedGiId = _safeInt(json['garduIndukId']) ?? _safeInt(gi?['id']) ?? _safeInt(json['id']) ?? 0;

    return Il1SipilItem(
      id: _safeInt(json['id']) ?? 0,
      garduIndukId: resolvedGiId,
      garduIndukNama: gi?['nama']?.toString() ?? json['garduIndukNama']?.toString() ?? json['nama']?.toString(),
      garduInduk: gi,
      gedung: json['gedung']?.toString() ?? 'CELL',
      nama: json['nama']?.toString() ?? 'Gedung Kontrol',
      isDisabled: _safeBool(json['isDisabled']),
      il1Sipil: il1List,
      last: lastItem,
      lastData: _safeMap(json['lastData']),
      status: lastItem?['status']?.toString() ?? json['status']?.toString(),
      drafted: _safeBool(json['drafted']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'garduIndukId': garduIndukId,
      if (garduIndukNama != null) 'garduIndukNama': garduIndukNama,
      if (garduInduk != null) 'garduInduk': garduInduk,
      'gedung': gedung,
      'nama': nama,
      'isDisabled': isDisabled,
      'il1Sipil': il1Sipil,
      if (last != null) 'last': last,
      if (lastData != null) 'lastData': lastData,
      if (status != null) 'status': status,
      'drafted': drafted,
    };
  }

  Il1SipilItem copyWith({
    int? id,
    int? garduIndukId,
    String? garduIndukNama,
    Map<String, dynamic>? garduInduk,
    String? gedung,
    String? nama,
    bool? isDisabled,
    List<dynamic>? il1Sipil,
    Map<String, dynamic>? last,
    Map<String, dynamic>? lastData,
    String? status,
    bool? drafted,
  }) {
    return Il1SipilItem(
      id: id ?? this.id,
      garduIndukId: garduIndukId ?? this.garduIndukId,
      garduIndukNama: garduIndukNama ?? this.garduIndukNama,
      garduInduk: garduInduk ?? this.garduInduk,
      gedung: gedung ?? this.gedung,
      nama: nama ?? this.nama,
      isDisabled: isDisabled ?? this.isDisabled,
      il1Sipil: il1Sipil ?? this.il1Sipil,
      last: last ?? this.last,
      lastData: lastData ?? this.lastData,
      status: status ?? this.status,
      drafted: drafted ?? this.drafted,
    );
  }

  @override
  List<Object?> get props => [id, garduIndukId, gedung, sudahInspeksi, status, drafted, il1Sipil];
}

// =============================================================================
// TODAY DETAIL MODELS
// =============================================================================

class Il1KubikelTodayDetailModel extends Equatable {
  final int id;
  final int? penyulangId;
  final String? status;
  final String? createdAt;
  final Map<String, dynamic>? fotoBuktiInspeksi;
  final String? statusPMT;
  final String? rackPMT;
  final List<String> keteranganPMT;
  final String? kondisiSF6PMT;
  final String? indikatorPegasMekanikPMT;
  final String? bendaAsing;
  final String? binatang;
  final String? tetesanAir;
  final String? desis;
  final String? bau;
  final String? kondisiLVPanel;
  final String? lampuLVPanel;
  final String? indikatorPMTClose;
  final String? indikatorPMTOpen;
  final String? indikatorTeganganKubikel;
  final String? tampilanLCDRelayOCR;
  final String? indikatorHealthyRelayOCR;
  final dynamic pembacaanArusNetralRelayOCR;
  final String? keteranganRelayUFR;
  final String? tampilanLCDRelayUFR;
  final dynamic pembacaanTeganganRelayUFR;
  final dynamic selectorUFR;
  final String? tampilanLCDKWHMeter;
  final String? tombolKWHMeter;
  final String? kondisiAlarm;
  final String? keteranganAnomali;
  final String? anomali;
  final Map<String, dynamic>? fotoAnomali;
  final dynamic durasi;
  final Map<String, dynamic>? penyulang;

  const Il1KubikelTodayDetailModel({
    required this.id,
    this.penyulangId,
    this.status,
    this.createdAt,
    this.fotoBuktiInspeksi,
    this.statusPMT,
    this.rackPMT,
    this.keteranganPMT = const [],
    this.kondisiSF6PMT,
    this.indikatorPegasMekanikPMT,
    this.bendaAsing,
    this.binatang,
    this.tetesanAir,
    this.desis,
    this.bau,
    this.kondisiLVPanel,
    this.lampuLVPanel,
    this.indikatorPMTClose,
    this.indikatorPMTOpen,
    this.indikatorTeganganKubikel,
    this.tampilanLCDRelayOCR,
    this.indikatorHealthyRelayOCR,
    this.pembacaanArusNetralRelayOCR,
    this.keteranganRelayUFR,
    this.tampilanLCDRelayUFR,
    this.pembacaanTeganganRelayUFR,
    this.selectorUFR,
    this.tampilanLCDKWHMeter,
    this.tombolKWHMeter,
    this.kondisiAlarm,
    this.keteranganAnomali,
    this.anomali,
    this.fotoAnomali,
    this.durasi,
    this.penyulang,
  });

  factory Il1KubikelTodayDetailModel.fromJson(Map<String, dynamic> json) {
    return Il1KubikelTodayDetailModel(
      id: _safeInt(json['id']) ?? 0,
      penyulangId: _safeInt(json['penyulangId']),
      status: json['status']?.toString(),
      createdAt: json['createdAt']?.toString(),
      fotoBuktiInspeksi: _safeMap(json['fotoBuktiInspeksi']),
      statusPMT: json['statusPMT']?.toString(),
      rackPMT: json['rackPMT']?.toString(),
      keteranganPMT: _safeStringList(json['keteranganPMT']),
      kondisiSF6PMT: json['kondisiSF6PMT']?.toString(),
      indikatorPegasMekanikPMT: json['indikatorPegasMekanikPMT']?.toString(),
      bendaAsing: json['bendaAsing']?.toString(),
      binatang: json['binatang']?.toString(),
      tetesanAir: json['tetesanAir']?.toString(),
      desis: json['desis']?.toString(),
      bau: json['bau']?.toString(),
      kondisiLVPanel: json['kondisiLVPanel']?.toString(),
      lampuLVPanel: json['lampuLVPanel']?.toString(),
      indikatorPMTClose: json['indikatorPMTClose']?.toString(),
      indikatorPMTOpen: json['indikatorPMTOpen']?.toString(),
      indikatorTeganganKubikel: json['indikatorTeganganKubikel']?.toString(),
      tampilanLCDRelayOCR: json['tampilanLCDRelayOCR']?.toString(),
      indikatorHealthyRelayOCR: json['indikatorHealthyRelayOCR']?.toString(),
      pembacaanArusNetralRelayOCR: json['pembacaanArusNetralRelayOCR'],
      keteranganRelayUFR: json['keteranganRelayUFR']?.toString(),
      tampilanLCDRelayUFR: json['tampilanLCDRelayUFR']?.toString(),
      pembacaanTeganganRelayUFR: json['pembacaanTeganganRelayUFR'],
      selectorUFR: json['selectorUFR'],
      tampilanLCDKWHMeter: json['tampilanLCDKWHMeter']?.toString(),
      tombolKWHMeter: json['tombolKWHMeter']?.toString(),
      kondisiAlarm: json['kondisiAlarm']?.toString(),
      keteranganAnomali: json['keteranganAnomali']?.toString(),
      anomali: json['anomali']?.toString(),
      fotoAnomali: _safeMap(json['fotoAnomali']),
      durasi: json['durasi'],
      penyulang: _safeMap(json['penyulang']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (penyulangId != null) 'penyulangId': penyulangId,
      if (status != null) 'status': status,
      if (createdAt != null) 'createdAt': createdAt,
      if (fotoBuktiInspeksi != null) 'fotoBuktiInspeksi': fotoBuktiInspeksi,
      if (statusPMT != null) 'statusPMT': statusPMT,
      if (rackPMT != null) 'rackPMT': rackPMT,
      'keteranganPMT': keteranganPMT,
      if (kondisiSF6PMT != null) 'kondisiSF6PMT': kondisiSF6PMT,
      if (indikatorPegasMekanikPMT != null) 'indikatorPegasMekanikPMT': indikatorPegasMekanikPMT,
      if (bendaAsing != null) 'bendaAsing': bendaAsing,
      if (binatang != null) 'binatang': binatang,
      if (tetesanAir != null) 'tetesanAir': tetesanAir,
      if (desis != null) 'desis': desis,
      if (bau != null) 'bau': bau,
      if (kondisiLVPanel != null) 'kondisiLVPanel': kondisiLVPanel,
      if (lampuLVPanel != null) 'lampuLVPanel': lampuLVPanel,
      if (indikatorPMTClose != null) 'indikatorPMTClose': indikatorPMTClose,
      if (indikatorPMTOpen != null) 'indikatorPMTOpen': indikatorPMTOpen,
      if (indikatorTeganganKubikel != null) 'indikatorTeganganKubikel': indikatorTeganganKubikel,
      if (tampilanLCDRelayOCR != null) 'tampilanLCDRelayOCR': tampilanLCDRelayOCR,
      if (indikatorHealthyRelayOCR != null) 'indikatorHealthyRelayOCR': indikatorHealthyRelayOCR,
      if (pembacaanArusNetralRelayOCR != null) 'pembacaanArusNetralRelayOCR': pembacaanArusNetralRelayOCR,
      if (keteranganRelayUFR != null) 'keteranganRelayUFR': keteranganRelayUFR,
      if (tampilanLCDRelayUFR != null) 'tampilanLCDRelayUFR': tampilanLCDRelayUFR,
      if (pembacaanTeganganRelayUFR != null) 'pembacaanTeganganRelayUFR': pembacaanTeganganRelayUFR,
      if (selectorUFR != null) 'selectorUFR': selectorUFR,
      if (tampilanLCDKWHMeter != null) 'tampilanLCDKWHMeter': tampilanLCDKWHMeter,
      if (tombolKWHMeter != null) 'tombolKWHMeter': tombolKWHMeter,
      if (kondisiAlarm != null) 'kondisiAlarm': kondisiAlarm,
      if (keteranganAnomali != null) 'keteranganAnomali': keteranganAnomali,
      if (anomali != null) 'anomali': anomali,
      if (fotoAnomali != null) 'fotoAnomali': fotoAnomali,
      if (durasi != null) 'durasi': durasi,
      if (penyulang != null) 'penyulang': penyulang,
    };
  }

  @override
  List<Object?> get props => [id, penyulangId, status, createdAt];
}

class Il1TrafoPsTodayDetailModel extends Equatable {
  final int id;
  final int? trafoId;
  final String? status;
  final String? createdAt;
  final Map<String, dynamic>? fotoBuktiInspeksi;
  final List<String> kebocoranBodyTrafo;
  final List<String> kondisiFisikTrafo;
  final List<String> kondisiRumahTrafo;
  final dynamic durasi;
  final Map<String, dynamic>? trafo;

  const Il1TrafoPsTodayDetailModel({
    required this.id,
    this.trafoId,
    this.status,
    this.createdAt,
    this.fotoBuktiInspeksi,
    this.kebocoranBodyTrafo = const [],
    this.kondisiFisikTrafo = const [],
    this.kondisiRumahTrafo = const [],
    this.durasi,
    this.trafo,
  });

  factory Il1TrafoPsTodayDetailModel.fromJson(Map<String, dynamic> json) {
    return Il1TrafoPsTodayDetailModel(
      id: _safeInt(json['id']) ?? 0,
      trafoId: _safeInt(json['trafoId']),
      status: json['status']?.toString(),
      createdAt: json['createdAt']?.toString(),
      fotoBuktiInspeksi: _safeMap(json['fotoBuktiInspeksi']),
      kebocoranBodyTrafo: _safeStringList(json['kebocoranBodyTrafo']),
      kondisiFisikTrafo: _safeStringList(json['kondisiFisikTrafo']),
      kondisiRumahTrafo: _safeStringList(json['kondisiRumahTrafo']),
      durasi: json['durasi'],
      trafo: _safeMap(json['trafo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (trafoId != null) 'trafoId': trafoId,
      if (status != null) 'status': status,
      if (createdAt != null) 'createdAt': createdAt,
      if (fotoBuktiInspeksi != null) 'fotoBuktiInspeksi': fotoBuktiInspeksi,
      'kebocoranBodyTrafo': kebocoranBodyTrafo,
      'kondisiFisikTrafo': kondisiFisikTrafo,
      'kondisiRumahTrafo': kondisiRumahTrafo,
      if (durasi != null) 'durasi': durasi,
      if (trafo != null) 'trafo': trafo,
    };
  }

  @override
  List<Object?> get props => [id, trafoId, status, createdAt];
}

class Il1SipilTodayDetailModel extends Equatable {
  final int id;
  final int? garduIndukId;
  final String? gedung;
  final String? status;
  final String? createdAt;
  final Map<String, dynamic>? fotoBuktiInspeksi;
  final String? kondisiLampuPenerangan;
  final String? jenisLampuPenerangan;
  final dynamic jumlahLampuPenerangan;
  final dynamic jumlahLampuPeneranganMati;
  final String? keteranganLampuPenerangan;
  final String? kondisiRuangan;
  final dynamic jumlahAC;
  final dynamic jumlahACMenyalaNormal;
  final dynamic jumlahACWindOnly;
  final dynamic jumlahACBocor;
  final dynamic jumlahACRusak;
  final String? keteranganAc;
  final String? kondisiAtap;
  final String? letakKebocoranAtap;
  final String? mainholeTergenangAir;
  final String? powerSupplyAC;
  final String? kebersihanPanelDCBC;
  final String? kebersihanRuangBaterai;
  final dynamic suhuRuangBaterai;
  final dynamic kelembabanRuangBaterai;
  final String? kebersihanBaterai;
  final String? kebocoranBaterai;
  final String? exhaustFan;
  final String? kondisiRuangBaterai;
  final dynamic teganganBeban;
  final dynamic arusBeban;
  final String? kondisiRectifier;
  final String? kebersihanRuangRectifier;
  final dynamic suhuRuangRectifier;
  final dynamic kelembabanRuangRectifier;
  final String? kebersihanPanel;
  final String? kondisiMMI;
  final String? kondisiMouseKomputer;
  final String? kondisiKeyboardKomputer;
  final String? kondisiInternet;
  final String? kondisiRadio;
  final String? kondisiYealink;
  final dynamic durasi;

  const Il1SipilTodayDetailModel({
    required this.id,
    this.garduIndukId,
    this.gedung,
    this.status,
    this.createdAt,
    this.fotoBuktiInspeksi,
    this.kondisiLampuPenerangan,
    this.jenisLampuPenerangan,
    this.jumlahLampuPenerangan,
    this.jumlahLampuPeneranganMati,
    this.keteranganLampuPenerangan,
    this.kondisiRuangan,
    this.jumlahAC,
    this.jumlahACMenyalaNormal,
    this.jumlahACWindOnly,
    this.jumlahACBocor,
    this.jumlahACRusak,
    this.keteranganAc,
    this.kondisiAtap,
    this.letakKebocoranAtap,
    this.mainholeTergenangAir,
    this.powerSupplyAC,
    this.kebersihanPanelDCBC,
    this.kebersihanRuangBaterai,
    this.suhuRuangBaterai,
    this.kelembabanRuangBaterai,
    this.kebersihanBaterai,
    this.kebocoranBaterai,
    this.exhaustFan,
    this.kondisiRuangBaterai,
    this.teganganBeban,
    this.arusBeban,
    this.kondisiRectifier,
    this.kebersihanRuangRectifier,
    this.suhuRuangRectifier,
    this.kelembabanRuangRectifier,
    this.kebersihanPanel,
    this.kondisiMMI,
    this.kondisiMouseKomputer,
    this.kondisiKeyboardKomputer,
    this.kondisiInternet,
    this.kondisiRadio,
    this.kondisiYealink,
    this.durasi,
  });

  factory Il1SipilTodayDetailModel.fromJson(Map<String, dynamic> json) {
    return Il1SipilTodayDetailModel(
      id: _safeInt(json['id']) ?? 0,
      garduIndukId: _safeInt(json['garduIndukId']),
      gedung: json['gedung']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['createdAt']?.toString(),
      fotoBuktiInspeksi: _safeMap(json['fotoBuktiInspeksi']),
      kondisiLampuPenerangan: json['kondisiLampuPenerangan']?.toString(),
      jenisLampuPenerangan: json['jenisLampuPenerangan']?.toString(),
      jumlahLampuPenerangan: json['jumlahLampuPenerangan'],
      jumlahLampuPeneranganMati: json['jumlahLampuPeneranganMati'],
      keteranganLampuPenerangan: json['keteranganLampuPenerangan']?.toString(),
      kondisiRuangan: json['kondisiRuangan']?.toString(),
      jumlahAC: json['jumlahAC'],
      jumlahACMenyalaNormal: json['jumlahACMenyalaNormal'],
      jumlahACWindOnly: json['jumlahACWindOnly'],
      jumlahACBocor: json['jumlahACBocor'],
      jumlahACRusak: json['jumlahACRusak'],
      keteranganAc: json['keteranganAc']?.toString(),
      kondisiAtap: json['kondisiAtap']?.toString(),
      letakKebocoranAtap: json['letakKebocoranAtap']?.toString(),
      mainholeTergenangAir: json['mainholeTergenangAir']?.toString(),
      powerSupplyAC: json['powerSupplyAC']?.toString(),
      kebersihanPanelDCBC: json['kebersihanPanelDCBC']?.toString(),
      kebersihanRuangBaterai: json['kebersihanRuangBaterai']?.toString(),
      suhuRuangBaterai: json['suhuRuangBaterai'],
      kelembabanRuangBaterai: json['kelembabanRuangBaterai'],
      kebersihanBaterai: json['kebersihanBaterai']?.toString(),
      kebocoranBaterai: json['kebocoranBaterai']?.toString(),
      exhaustFan: json['exhaustFan']?.toString(),
      kondisiRuangBaterai: json['kondisiRuangBaterai']?.toString(),
      teganganBeban: json['teganganBeban'],
      arusBeban: json['arusBeban'],
      kondisiRectifier: json['kondisiRectifier']?.toString(),
      kebersihanRuangRectifier: json['kebersihanRuangRectifier']?.toString(),
      suhuRuangRectifier: json['suhuRuangRectifier'],
      kelembabanRuangRectifier: json['kelembabanRuangRectifier'],
      kebersihanPanel: json['kebersihanPanel']?.toString(),
      kondisiMMI: json['kondisiMMI']?.toString(),
      kondisiMouseKomputer: json['kondisiMouseKomputer']?.toString(),
      kondisiKeyboardKomputer: json['kondisiKeyboardKomputer']?.toString(),
      kondisiInternet: json['kondisiInternet']?.toString(),
      kondisiRadio: json['kondisiRadio']?.toString(),
      kondisiYealink: json['kondisiYealink']?.toString(),
      durasi: json['durasi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (garduIndukId != null) 'garduIndukId': garduIndukId,
      if (gedung != null) 'gedung': gedung,
      if (status != null) 'status': status,
      if (createdAt != null) 'createdAt': createdAt,
      if (fotoBuktiInspeksi != null) 'fotoBuktiInspeksi': fotoBuktiInspeksi,
      if (kondisiLampuPenerangan != null) 'kondisiLampuPenerangan': kondisiLampuPenerangan,
      if (jenisLampuPenerangan != null) 'jenisLampuPenerangan': jenisLampuPenerangan,
      if (jumlahLampuPenerangan != null) 'jumlahLampuPenerangan': jumlahLampuPenerangan,
      if (jumlahLampuPeneranganMati != null) 'jumlahLampuPeneranganMati': jumlahLampuPeneranganMati,
      if (keteranganLampuPenerangan != null) 'keteranganLampuPenerangan': keteranganLampuPenerangan,
      if (kondisiRuangan != null) 'kondisiRuangan': kondisiRuangan,
      if (jumlahAC != null) 'jumlahAC': jumlahAC,
      if (jumlahACMenyalaNormal != null) 'jumlahACMenyalaNormal': jumlahACMenyalaNormal,
      if (jumlahACWindOnly != null) 'jumlahACWindOnly': jumlahACWindOnly,
      if (jumlahACBocor != null) 'jumlahACBocor': jumlahACBocor,
      if (jumlahACRusak != null) 'jumlahACRusak': jumlahACRusak,
      if (keteranganAc != null) 'keteranganAc': keteranganAc,
      if (kondisiAtap != null) 'kondisiAtap': kondisiAtap,
      if (letakKebocoranAtap != null) 'letakKebocoranAtap': letakKebocoranAtap,
      if (mainholeTergenangAir != null) 'mainholeTergenangAir': mainholeTergenangAir,
      if (powerSupplyAC != null) 'powerSupplyAC': powerSupplyAC,
      if (kebersihanPanelDCBC != null) 'kebersihanPanelDCBC': kebersihanPanelDCBC,
      if (kebersihanRuangBaterai != null) 'kebersihanRuangBaterai': kebersihanRuangBaterai,
      if (suhuRuangBaterai != null) 'suhuRuangBaterai': suhuRuangBaterai,
      if (kelembabanRuangBaterai != null) 'kelembabanRuangBaterai': kelembabanRuangBaterai,
      if (kebersihanBaterai != null) 'kebersihanBaterai': kebersihanBaterai,
      if (kebocoranBaterai != null) 'kebocoranBaterai': kebocoranBaterai,
      if (exhaustFan != null) 'exhaustFan': exhaustFan,
      if (kondisiRuangBaterai != null) 'kondisiRuangBaterai': kondisiRuangBaterai,
      if (teganganBeban != null) 'teganganBeban': teganganBeban,
      if (arusBeban != null) 'arusBeban': arusBeban,
      if (kondisiRectifier != null) 'kondisiRectifier': kondisiRectifier,
      if (kebersihanRuangRectifier != null) 'kebersihanRuangRectifier': kebersihanRuangRectifier,
      if (suhuRuangRectifier != null) 'suhuRuangRectifier': suhuRuangRectifier,
      if (kelembabanRuangRectifier != null) 'kelembabanRuangRectifier': kelembabanRuangRectifier,
      if (kebersihanPanel != null) 'kebersihanPanel': kebersihanPanel,
      if (kondisiMMI != null) 'kondisiMMI': kondisiMMI,
      if (kondisiMouseKomputer != null) 'kondisiMouseKomputer': kondisiMouseKomputer,
      if (kondisiKeyboardKomputer != null) 'kondisiKeyboardKomputer': kondisiKeyboardKomputer,
      if (kondisiInternet != null) 'kondisiInternet': kondisiInternet,
      if (kondisiRadio != null) 'kondisiRadio': kondisiRadio,
      if (kondisiYealink != null) 'kondisiYealink': kondisiYealink,
      if (durasi != null) 'durasi': durasi,
    };
  }

  @override
  List<Object?> get props => [id, garduIndukId, gedung, status, createdAt];
}
