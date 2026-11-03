class KetenagakerjaanItemModel {
  final int id;
  final String status;
  final int minggu;
  final String bulan;
  final int tahun;
  final double score;
  final String? namaPetugas;
  final int? userId;
  final List<KegiatanSosialPoinModel> kegiatanSosial;
  final List<PengurangModel> pengurang;
  final String kepatuhan;
  final double pointKepatuhan;
  final String? kategoriKepatuhan;
  final String durasi;
  final double ketentuan;
  final double kinerja;
  final double pointDurasi;
  final String? kategoriDurasiInspeksi;
  final String absensi;
  final String? bantuanAbsensi;
  final double pointAbsensi;
  final String? kategoriKehadiran;
  final String coc;
  final String? bantuanCOC;
  final double pointCOC;
  final String? kategoriCOC;

  KetenagakerjaanItemModel({
    required this.id,
    required this.status,
    required this.minggu,
    required this.bulan,
    required this.tahun,
    required this.score,
    this.namaPetugas,
    this.userId,
    this.kegiatanSosial = const [],
    this.pengurang = const [],
    this.kepatuhan = '',
    this.pointKepatuhan = 0.0,
    this.kategoriKepatuhan,
    this.durasi = '',
    this.ketentuan = 0.0,
    this.kinerja = 0.0,
    this.pointDurasi = 0.0,
    this.kategoriDurasiInspeksi,
    this.absensi = '',
    this.bantuanAbsensi,
    this.pointAbsensi = 0.0,
    this.kategoriKehadiran,
    this.coc = '',
    this.bantuanCOC,
    this.pointCOC = 0.0,
    this.kategoriCOC,
  });

  factory KetenagakerjaanItemModel.fromJson(Map<String, dynamic> json) {
    String? nama;
    int? uid;
    if (json['petugasLineWalker'] is Map &&
        json['petugasLineWalker']['petugas'] is Map &&
        json['petugasLineWalker']['petugas']['user'] is Map) {
      final user = json['petugasLineWalker']['petugas']['user'];
      nama = user['namaLengkap']?.toString();
      uid = user['id'] is int ? user['id'] : int.tryParse('${user['id']}');
    }

    final ksList = (json['kegiatanSosial'] as List?)
            ?.map((e) => KegiatanSosialPoinModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final pList = (json['pengurang'] as List?)
            ?.map((e) => PengurangModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return KetenagakerjaanItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      status: json['status']?.toString() ?? 'AMAN',
      minggu: json['minggu'] is int ? json['minggu'] : int.tryParse('${json['minggu']}') ?? 1,
      bulan: json['bulan']?.toString() ?? '',
      tahun: json['tahun'] is int ? json['tahun'] : int.tryParse('${json['tahun']}') ?? DateTime.now().year,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      namaPetugas: nama,
      userId: uid,
      kegiatanSosial: ksList,
      pengurang: pList,
      kepatuhan: json['kepatuhan']?.toString() ?? '',
      pointKepatuhan: (json['pointKepatuhan'] as num?)?.toDouble() ?? 0.0,
      kategoriKepatuhan: json['kategoriKepatuhan']?.toString(),
      durasi: json['durasi']?.toString() ?? '',
      ketentuan: (json['ketentuan'] as num?)?.toDouble() ?? 0.0,
      kinerja: (json['kinerja'] as num?)?.toDouble() ?? 0.0,
      pointDurasi: (json['pointDurasi'] as num?)?.toDouble() ?? 0.0,
      kategoriDurasiInspeksi: json['kategoriDurasiInspeksi']?.toString(),
      absensi: json['absensi']?.toString() ?? '',
      bantuanAbsensi: json['bantuanAbsensi']?.toString(),
      pointAbsensi: (json['pointAbsensi'] as num?)?.toDouble() ?? 0.0,
      kategoriKehadiran: json['kategoriKehadiran']?.toString(),
      coc: json['coc']?.toString() ?? '',
      bantuanCOC: json['bantuanCOC']?.toString(),
      pointCOC: (json['pointCOC'] as num?)?.toDouble() ?? 0.0,
      kategoriCOC: json['kategoriCOC']?.toString(),
    );
  }
}

class KegiatanSosialPoinModel {
  final double poin;

  KegiatanSosialPoinModel({required this.poin});

  factory KegiatanSosialPoinModel.fromJson(Map<String, dynamic> json) {
    return KegiatanSosialPoinModel(
      poin: (json['poin'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PengurangModel {
  final int id;
  final String type;
  final double poin;

  PengurangModel({
    required this.id,
    required this.type,
    required this.poin,
  });

  factory PengurangModel.fromJson(Map<String, dynamic> json) {
    return PengurangModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      type: json['type']?.toString() ?? '',
      poin: (json['poin'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
