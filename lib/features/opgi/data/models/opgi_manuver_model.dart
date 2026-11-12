/// Model data kegiatan manuver jaringan 20kV
class ManuverItemModel {
  final int id;
  final String tipeManuver; // 'PEKERJAAN' | 'GANGGUAN' | 'TRIP OVERLOAD'
  final String? createdAt;
  final ManuverPenyulangModel penyulang;
  final List<ManuverProgressModel> progres;
  final bool isDisabled;

  const ManuverItemModel({
    required this.id,
    required this.tipeManuver,
    this.createdAt,
    required this.penyulang,
    this.progres = const [],
    this.isDisabled = false,
  });

  bool get isClose =>
      progres.isNotEmpty && progres.first.status?.toUpperCase() == 'CLOSE';

  factory ManuverItemModel.fromJson(Map<String, dynamic> json) {
    ManuverPenyulangModel penyulangObj;
    if (json['penyulang'] is Map) {
      penyulangObj = ManuverPenyulangModel.fromJson(
        Map<String, dynamic>.from(json['penyulang'] as Map),
      );
    } else if (json['penyulang'] is String) {
      penyulangObj = ManuverPenyulangModel(
        id: json['penyulangId'] as int? ?? 0,
        nama: json['penyulang'] as String,
      );
    } else {
      penyulangObj = ManuverPenyulangModel(
        id: json['penyulangId'] as int? ?? 0,
        nama: '-',
      );
    }

    List<ManuverProgressModel> progresList = [];
    if (json['progres'] is List) {
      progresList = (json['progres'] as List)
          .whereType<Map>()
          .map((p) => ManuverProgressModel.fromJson(Map<String, dynamic>.from(p)))
          .toList();
    }

    return ManuverItemModel(
      id: json['id'] as int? ?? 0,
      tipeManuver: json['tipeManuver'] as String? ?? 'GANGGUAN',
      createdAt: json['createdAt'] as String?,
      penyulang: penyulangObj,
      progres: progresList,
      isDisabled: json['isDisabled'] == true || json['isDisabled'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tipeManuver': tipeManuver,
        'createdAt': createdAt,
        'penyulang': penyulang.toJson(),
        'progres': progres.map((p) => p.toJson()).toList(),
        'isDisabled': isDisabled,
      };
}

/// Alias untuk kompatibilitas jika masih ada yang mereferensikan ManuverModel
typedef ManuverModel = ManuverItemModel;

/// Referensi penyulang dalam kegiatan manuver
class ManuverPenyulangModel {
  final int id;
  final String nama;

  const ManuverPenyulangModel({
    required this.id,
    required this.nama,
  });

  factory ManuverPenyulangModel.fromJson(Map<String, dynamic> json) {
    return ManuverPenyulangModel(
      id: json['id'] as int? ?? 0,
      nama: json['nama'] as String? ?? '-',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
      };
}

/// Model setiap tahapan / step progress dalam manuver
class ManuverProgressModel {
  final int id;
  final String objek; // 'PMT' | 'PMS RELL + KABEL' | 'PMS TANAH'
  final String? posisi; // 'TRIP' | 'RACK IN' | 'RACK OUT' | 'MASUK' | 'KELUAR'
  final String? operasi; // 'LOCAL' | 'REMOTE'
  final String? status; // 'OPEN' | 'CLOSE' | 'RACK IN' | 'RACK OUT' | 'KELUAR' | 'MASUK'
  final List<String> jenisGangguan; // ['GFM', 'GF', 'OCM', 'OC', 'UFR']
  final String? keteranganPekerjaan;
  final List<ManuverArusModel> arus;
  final ManuverOperatorModel? operator;
  final ManuverDokumentasiModel? dokumentasi;
  final String? waktu;
  final String? createdAt;
  final bool isDisabled;

  const ManuverProgressModel({
    required this.id,
    required this.objek,
    this.posisi,
    this.operasi,
    this.status,
    this.jenisGangguan = const [],
    this.keteranganPekerjaan,
    this.arus = const [],
    this.operator,
    this.dokumentasi,
    this.waktu,
    this.createdAt,
    this.isDisabled = false,
  });

  bool get isClose => status?.toUpperCase() == 'CLOSE';

  factory ManuverProgressModel.fromJson(Map<String, dynamic> json) {
    List<String> jg = [];
    if (json['jenisGangguan'] is List) {
      jg = (json['jenisGangguan'] as List).map((e) => e.toString()).toList();
    }

    List<ManuverArusModel> arusList = [];
    if (json['arus'] is List) {
      arusList = (json['arus'] as List)
          .whereType<Map>()
          .map((a) => ManuverArusModel.fromJson(Map<String, dynamic>.from(a)))
          .toList();
    } else if (json['arus'] is Map) {
      arusList = [
        ManuverArusModel.fromJson(Map<String, dynamic>.from(json['arus'] as Map))
      ];
    }

    ManuverOperatorModel? op;
    if (json['operator'] is Map) {
      op = ManuverOperatorModel.fromJson(
        Map<String, dynamic>.from(json['operator'] as Map),
      );
    }

    ManuverDokumentasiModel? doc;
    if (json['dokumentasi'] is Map) {
      doc = ManuverDokumentasiModel.fromJson(
        Map<String, dynamic>.from(json['dokumentasi'] as Map),
      );
    } else if (json['dokumentasi'] is String && (json['dokumentasi'] as String).isNotEmpty) {
      doc = ManuverDokumentasiModel(uri: json['dokumentasi'] as String);
    }

    return ManuverProgressModel(
      id: json['id'] as int? ?? 0,
      objek: json['objek'] as String? ?? 'PMT',
      posisi: json['posisi'] as String?,
      operasi: json['operasi'] as String?,
      status: json['status'] as String?,
      jenisGangguan: jg,
      keteranganPekerjaan: json['keteranganPekerjaan'] as String?,
      arus: arusList,
      operator: op,
      dokumentasi: doc,
      waktu: json['waktu'] as String?,
      createdAt: json['createdAt'] as String?,
      isDisabled: json['isDisabled'] == true || json['isDisabled'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'objek': objek,
        if (posisi != null) 'posisi': posisi,
        if (operasi != null) 'operasi': operasi,
        if (status != null) 'status': status,
        'jenisGangguan': jenisGangguan,
        if (keteranganPekerjaan != null) 'keteranganPekerjaan': keteranganPekerjaan,
        'arus': arus.map((a) => a.toJson()).toList(),
        if (operator != null) 'operator': operator!.toJson(),
        if (dokumentasi != null) 'dokumentasi': dokumentasi!.toJson(),
        if (waktu != null) 'waktu': waktu,
        if (createdAt != null) 'createdAt': createdAt,
        'isDisabled': isDisabled,
      };
}

/// Model arus dalam pengukuran manuver
class ManuverArusModel {
  final String type; // 'Ia' | 'Ib' | 'Ic' | 'In'
  final String satuan; // 'A' | 'kA'
  final dynamic value; // angka / string

  const ManuverArusModel({
    required this.type,
    required this.satuan,
    required this.value,
  });

  factory ManuverArusModel.fromJson(Map<String, dynamic> json) {
    return ManuverArusModel(
      type: json['type'] as String? ?? 'Ia',
      satuan: json['satuan'] as String? ?? 'A',
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'satuan': satuan,
        'value': value is String ? num.tryParse(value) ?? value : value,
      };
}

/// Model operator pengisi manuver
class ManuverOperatorModel {
  final String? namaLengkap;

  const ManuverOperatorModel({this.namaLengkap});

  factory ManuverOperatorModel.fromJson(Map<String, dynamic> json) {
    String? nama;
    final petugas = json['petugas'];
    if (petugas is Map) {
      final user = petugas['user'];
      if (user is Map) {
        nama = user['namaLengkap']?.toString();
      }
    }
    nama ??= json['namaLengkap']?.toString();

    return ManuverOperatorModel(namaLengkap: nama);
  }

  Map<String, dynamic> toJson() => {
        'petugas': {
          'user': {
            'namaLengkap': namaLengkap,
          },
        },
      };
}

/// Model foto dokumentasi manuver
class ManuverDokumentasiModel {
  final String? uri;
  final String? date;

  const ManuverDokumentasiModel({this.uri, this.date});

  factory ManuverDokumentasiModel.fromJson(Map<String, dynamic> json) {
    return ManuverDokumentasiModel(
      uri: json['uri'] as String? ?? json['url'] as String?,
      date: json['date'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'uri': uri,
        if (date != null) 'date': date,
      };
}
