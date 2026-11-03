class DigantikanModel {
  final int? id;
  final String? namaPetugas;
  final int? startHour;
  final int? startMinute;
  final int? endHour;
  final int? endMinute;

  DigantikanModel({
    this.id,
    this.namaPetugas,
    this.startHour,
    this.startMinute,
    this.endHour,
    this.endMinute,
  });

  factory DigantikanModel.fromJson(Map<String, dynamic> json) {
    String? nama;
    if (json['user'] is Map) {
      nama = json['user']['namaLengkap'] as String?;
    }
    return DigantikanModel(
      id: json['id'] as int?,
      namaPetugas: nama,
      startHour: json['startHour'] as int?,
      startMinute: json['startMinute'] as int?,
      endHour: json['endHour'] as int?,
      endMinute: json['endMinute'] as int?,
    );
  }
}

class RiwayatAbsenItemModel {
  final int id;
  final String? keterangan;
  final int? jamMasuk;
  final int? menitMasuk;
  final int? jamKeluar;
  final int? menitKeluar;
  final String? createdAt;
  final String? absenMasuk;
  final String? absenKeluar;
  final String? statusIn;
  final int? durasiTelatIn;
  final String? statusOut;
  final int? durasiTelatOut;
  final int? durasiKerja;
  final String? premi;
  final String? fotoBuktiPremi;
  final String? izin;
  final String? diagnosaSakit;
  final String? pictureInUri;
  final String? pictureOutUri;
  final String? namaPengganti;
  final List<DigantikanModel> digantikan;

  RiwayatAbsenItemModel({
    required this.id,
    this.keterangan,
    this.jamMasuk,
    this.menitMasuk,
    this.jamKeluar,
    this.menitKeluar,
    this.createdAt,
    this.absenMasuk,
    this.absenKeluar,
    this.statusIn,
    this.durasiTelatIn,
    this.statusOut,
    this.durasiTelatOut,
    this.durasiKerja,
    this.premi,
    this.fotoBuktiPremi,
    this.izin,
    this.diagnosaSakit,
    this.pictureInUri,
    this.pictureOutUri,
    this.namaPengganti,
    this.digantikan = const [],
  });

  bool get isEditable {
    final isOff = premi == 'OFF';
    final isSakit = keterangan == 'SAKIT';
    final noDoc = fotoBuktiPremi == null || fotoBuktiPremi!.isEmpty;
    return isOff && isSakit && noDoc;
  }

  factory RiwayatAbsenItemModel.fromJson(Map<String, dynamic> json) {
    String? picIn;
    if (json['pictureIn'] is Map) {
      picIn = json['pictureIn']['uri'] as String?;
    } else if (json['pictureIn'] is String) {
      picIn = json['pictureIn'] as String;
    }

    String? picOut;
    if (json['pictureOut'] is Map) {
      picOut = json['pictureOut']['uri'] as String?;
    } else if (json['pictureOut'] is String) {
      picOut = json['pictureOut'] as String;
    }

    String? pengganti;
    if (json['penggantiAbsen'] is Map &&
        json['penggantiAbsen']['absensi'] is Map &&
        json['penggantiAbsen']['absensi']['user'] is Map) {
      pengganti =
          json['penggantiAbsen']['absensi']['user']['namaLengkap'] as String?;
    }

    final digantikanList = <DigantikanModel>[];
    if (json['digantikan'] is List) {
      for (final d in json['digantikan']) {
        if (d is Map<String, dynamic>) {
          digantikanList.add(DigantikanModel.fromJson(d));
        }
      }
    }

    return RiwayatAbsenItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      keterangan: json['keterangan'] as String?,
      jamMasuk: json['jamMasuk'] as int?,
      menitMasuk: json['menitMasuk'] as int?,
      jamKeluar: json['jamKeluar'] as int?,
      menitKeluar: json['menitKeluar'] as int?,
      createdAt: json['createdAt'] as String?,
      absenMasuk: json['absenMasuk'] as String?,
      absenKeluar: json['absenKeluar'] as String?,
      statusIn: json['statusIn'] as String?,
      durasiTelatIn: json['durasiTelatIn'] as int?,
      statusOut: json['statusOut'] as String?,
      durasiTelatOut: json['durasiTelatOut'] as int?,
      durasiKerja: json['durasiKerja'] as int?,
      premi: json['premi'] as String?,
      fotoBuktiPremi: json['fotoBuktiPremi'] as String?,
      izin: json['izin'] as String?,
      diagnosaSakit: json['diagnosaSakit'] as String?,
      pictureInUri: picIn,
      pictureOutUri: picOut,
      namaPengganti: pengganti,
      digantikan: digantikanList,
    );
  }
}

class RiwayatAbsenPaginationModel {
  final List<RiwayatAbsenItemModel> items;
  final int? nextCursor;

  RiwayatAbsenPaginationModel({
    required this.items,
    this.nextCursor,
  });

  factory RiwayatAbsenPaginationModel.fromJson(Map<String, dynamic> json) {
    final list = <RiwayatAbsenItemModel>[];
    if (json['items'] is List) {
      for (final item in json['items']) {
        if (item is Map<String, dynamic>) {
          list.add(RiwayatAbsenItemModel.fromJson(item));
        }
      }
    }
    return RiwayatAbsenPaginationModel(
      items: list,
      nextCursor: json['nextCursor'] as int?,
    );
  }
}
