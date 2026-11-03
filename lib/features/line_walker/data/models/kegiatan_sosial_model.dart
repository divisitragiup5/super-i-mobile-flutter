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
  final String? identifier;
  final String? namaTower;
  final String? jenisAktivitas;
  final String? statusAktivitas;
  final String? pelakuAktivitasSosial;
  final String? createdAt;
  final String? ttdTLGI;

  KegiatanSosialHistoryItemModel({
    required this.id,
    this.identifier,
    this.namaTower,
    this.jenisAktivitas,
    this.statusAktivitas,
    this.pelakuAktivitasSosial,
    this.createdAt,
    this.ttdTLGI,
  });

  factory KegiatanSosialHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return KegiatanSosialHistoryItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      identifier: json['identifier']?.toString(),
      namaTower: json['tower'] is Map ? json['tower']['nama']?.toString() : null,
      jenisAktivitas: json['jenisAktivitas']?.toString(),
      statusAktivitas: json['statusAktivitas']?.toString(),
      pelakuAktivitasSosial: json['pelakuAktivitasSosial']?.toString(),
      createdAt: json['createdAt']?.toString(),
      ttdTLGI: json['ttdTLGI']?.toString(),
    );
  }
}
