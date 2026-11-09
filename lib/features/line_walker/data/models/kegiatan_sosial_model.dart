import 'dart:io';

class KegiatanSosialInputModel {
  final int towerId;
  final String? namaTower;
  final String identifier;
  final String jenisAktivitas;
  final String statusAktivitas;
  final String progresPenanganan;
  final String tindakan;
  final String keterangan;
  final String statusObjek;
  final String pelakuAktivitasSosial;
  final String tanggapan;
  final String lokasi;
  final double latitude;
  final double longitude;
  final File? dokumentasiSosialisasi;
  final File? dokumentasiAktivitasSosial;
  final File? ttdLineWalker;
  final String namaTTDLineWalker;
  final File? ttdTLGI;
  final String? namaTTDTLGI;
  final String temuan;
  final int? jumlahTemuan;

  KegiatanSosialInputModel({
    required this.towerId,
    this.namaTower,
    this.identifier = 'KEGIATAN_SOSIAL',
    required this.jenisAktivitas,
    required this.statusAktivitas,
    required this.progresPenanganan,
    required this.tindakan,
    required this.keterangan,
    required this.statusObjek,
    required this.pelakuAktivitasSosial,
    required this.tanggapan,
    required this.lokasi,
    required this.latitude,
    required this.longitude,
    this.dokumentasiSosialisasi,
    this.dokumentasiAktivitasSosial,
    this.ttdLineWalker,
    required this.namaTTDLineWalker,
    this.ttdTLGI,
    this.namaTTDTLGI,
    this.temuan = 'TIDAK ADA TEMUAN',
    this.jumlahTemuan,
  });

  Map<String, dynamic> toJsonDraft() {
    return {
      'towerId': towerId,
      'namaTower': namaTower,
      'identifier': identifier,
      'jenisAktivitas': jenisAktivitas,
      'statusAktivitas': statusAktivitas,
      'progresPenanganan': progresPenanganan,
      'tindakan': tindakan,
      'keterangan': keterangan,
      'statusObjek': statusObjek,
      'pelakuAktivitasSosial': pelakuAktivitasSosial,
      'tanggapan': tanggapan,
      'lokasi': lokasi,
      'latitude': latitude,
      'longitude': longitude,
      'dokumentasiSosialisasiPath': dokumentasiSosialisasi?.path,
      'dokumentasiAktivitasSosialPath': dokumentasiAktivitasSosial?.path,
      'ttdLineWalkerPath': ttdLineWalker?.path,
      'namaTTDLineWalker': namaTTDLineWalker,
      'ttdTLGIPath': ttdTLGI?.path,
      'namaTTDTLGI': namaTTDTLGI,
      'temuan': temuan,
      'jumlahTemuan': jumlahTemuan,
    };
  }

  factory KegiatanSosialInputModel.fromJsonDraft(Map<String, dynamic> json) {
    return KegiatanSosialInputModel(
      towerId: json['towerId'] as int? ?? 0,
      namaTower: json['namaTower'] as String?,
      identifier: json['identifier']?.toString() ?? 'KEGIATAN_SOSIAL',
      jenisAktivitas: json['jenisAktivitas']?.toString() ?? '',
      statusAktivitas: json['statusAktivitas']?.toString() ?? '',
      progresPenanganan: json['progresPenanganan']?.toString() ?? '',
      tindakan: json['tindakan']?.toString() ?? '',
      keterangan: json['keterangan']?.toString() ?? '',
      statusObjek: json['statusObjek']?.toString() ?? '',
      pelakuAktivitasSosial: json['pelakuAktivitasSosial']?.toString() ?? '',
      tanggapan: json['tanggapan']?.toString() ?? '',
      lokasi: json['lokasi']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      dokumentasiSosialisasi: json['dokumentasiSosialisasiPath'] != null
          ? File(json['dokumentasiSosialisasiPath'])
          : null,
      dokumentasiAktivitasSosial: json['dokumentasiAktivitasSosialPath'] != null
          ? File(json['dokumentasiAktivitasSosialPath'])
          : null,
      ttdLineWalker: json['ttdLineWalkerPath'] != null
          ? File(json['ttdLineWalkerPath'])
          : null,
      namaTTDLineWalker: json['namaTTDLineWalker']?.toString() ?? '',
      ttdTLGI: json['ttdTLGIPath'] != null ? File(json['ttdTLGIPath']) : null,
      namaTTDTLGI: json['namaTTDTLGI']?.toString(),
      temuan: json['temuan']?.toString() ?? 'TIDAK ADA TEMUAN',
      jumlahTemuan: json['jumlahTemuan'] as int?,
    );
  }
}

class KegiatanSosialHistoryItemModel {
  final int id;
  final int towerId;
  final String identifier;
  final String? namaTower;
  final String? namaAktivitas;
  final String? jenisAktivitas;
  final String? statusAktivitas;
  final String kategoriAktivitas;
  final String? statusObjek;
  final String? pelakuAktivitasSosial;
  final String? createdAt;
  final int totalUpdate;
  final int belumTTDTLGI;
  final int sudahTTDTLGI;
  final String? ttdTLGI;
  final String? namaTTDTLGI;
  final String? ttdLineWalker;
  final String? namaTTDLineWalker;
  final bool isEditable;
  final Map<String, dynamic> rawJson;

  KegiatanSosialHistoryItemModel({
    required this.id,
    required this.towerId,
    required this.identifier,
    this.namaTower,
    this.namaAktivitas,
    this.jenisAktivitas,
    this.statusAktivitas,
    this.kategoriAktivitas = 'NORMAL',
    this.statusObjek,
    this.pelakuAktivitasSosial,
    this.createdAt,
    this.totalUpdate = 0,
    this.belumTTDTLGI = 0,
    this.sudahTTDTLGI = 0,
    this.ttdTLGI,
    this.namaTTDTLGI,
    this.ttdLineWalker,
    this.namaTTDLineWalker,
    this.isEditable = true,
    this.rawJson = const {},
  });

  factory KegiatanSosialHistoryItemModel.fromJson(Map<String, dynamic> json) {
    final towerMap = json['tower'] is Map ? json['tower'] as Map<String, dynamic> : null;
    final tId = towerMap != null && towerMap['id'] != null
        ? (towerMap['id'] is int ? towerMap['id'] as int : int.tryParse('${towerMap['id']}') ?? 0)
        : (json['towerId'] is int ? json['towerId'] as int : int.tryParse('${json['towerId']}') ?? 0);

    return KegiatanSosialHistoryItemModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      towerId: tId,
      identifier: json['identifier']?.toString() ?? '',
      namaTower: towerMap != null ? towerMap['nama']?.toString() : json['namaTower']?.toString(),
      namaAktivitas: json['namaAktivitas']?.toString(),
      jenisAktivitas: json['jenisAktivitas']?.toString(),
      statusAktivitas: json['statusAktivitas']?.toString(),
      kategoriAktivitas: json['kategoriAktivitas']?.toString() ?? 'NORMAL',
      statusObjek: json['statusObjek']?.toString(),
      pelakuAktivitasSosial: json['pelakuAktivitasSosial']?.toString(),
      createdAt: json['createdAt']?.toString(),
      totalUpdate: json['totalUpdate'] is int
          ? json['totalUpdate'] as int
          : int.tryParse('${json['totalUpdate']}') ?? 0,
      belumTTDTLGI: json['belumTTDTLGI'] is int
          ? json['belumTTDTLGI'] as int
          : int.tryParse('${json['belumTTDTLGI']}') ?? 0,
      sudahTTDTLGI: json['sudahTTDTLGI'] is int
          ? json['sudahTTDTLGI'] as int
          : int.tryParse('${json['sudahTTDTLGI']}') ?? 0,
      ttdTLGI: json['ttdTLGI']?.toString(),
      namaTTDTLGI: json['namaTTDTLGI']?.toString(),
      ttdLineWalker: json['ttdLineWalker']?.toString(),
      namaTTDLineWalker: json['namaTTDLineWalker']?.toString(),
      isEditable: json['isEditable'] != false,
      rawJson: json,
    );
  }
}

