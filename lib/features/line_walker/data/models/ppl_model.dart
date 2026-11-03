import 'dart:io';

class PPLInputModel {
  final int towerId;
  final String? namaTower;
  final String identifier;
  final String namaPekerjaan;
  final String jenisObjek;
  final String keteranganJenisObjek;
  final String kategoriObjek;
  final String keteranganKategoriObjek;
  final String statusObjek;
  final String statusPekerjaan;
  final String progressPekerjaan;
  final String pihakPelaksana;
  final String pjPekerjaan;
  final String noTeleponPJPekerjaan;
  final String tanggapan;
  final String namaValidator;
  final DateTime suratSosialisasi;
  final String lokasi;
  final double latitude;
  final double longitude;
  final File? dokumentasiPerwakilan;
  final File? dokumentasiObjek;
  final File? dokumentasiSekitar;
  final File? ttdLineWalker;
  final String namaTTDLineWalker;
  final File? ttdPJPekerjaan;
  final String namaTTDPJPekerjaan;
  final File? ttdTLGI;
  final String? namaTTDTLGI;

  PPLInputModel({
    required this.towerId,
    this.namaTower,
    this.identifier = 'PPL',
    required this.namaPekerjaan,
    required this.jenisObjek,
    required this.keteranganJenisObjek,
    required this.kategoriObjek,
    required this.keteranganKategoriObjek,
    required this.statusObjek,
    required this.statusPekerjaan,
    required this.progressPekerjaan,
    required this.pihakPelaksana,
    required this.pjPekerjaan,
    required this.noTeleponPJPekerjaan,
    required this.tanggapan,
    required this.namaValidator,
    required this.suratSosialisasi,
    required this.lokasi,
    required this.latitude,
    required this.longitude,
    this.dokumentasiPerwakilan,
    this.dokumentasiObjek,
    this.dokumentasiSekitar,
    this.ttdLineWalker,
    required this.namaTTDLineWalker,
    this.ttdPJPekerjaan,
    required this.namaTTDPJPekerjaan,
    this.ttdTLGI,
    this.namaTTDTLGI,
  });

  Map<String, dynamic> toJsonDraft() {
    return {
      'towerId': towerId,
      'namaTower': namaTower,
      'identifier': identifier,
      'namaPekerjaan': namaPekerjaan,
      'jenisObjek': jenisObjek,
      'keteranganJenisObjek': keteranganJenisObjek,
      'kategoriObjek': kategoriObjek,
      'keteranganKategoriObjek': keteranganKategoriObjek,
      'statusObjek': statusObjek,
      'statusPekerjaan': statusPekerjaan,
      'progressPekerjaan': progressPekerjaan,
      'pihakPelaksana': pihakPelaksana,
      'pjPekerjaan': pjPekerjaan,
      'noTeleponPJPekerjaan': noTeleponPJPekerjaan,
      'tanggapan': tanggapan,
      'namaValidator': namaValidator,
      'suratSosialisasi': suratSosialisasi.toIso8601String(),
      'lokasi': lokasi,
      'latitude': latitude,
      'longitude': longitude,
      'dokumentasiPerwakilanPath': dokumentasiPerwakilan?.path,
      'dokumentasiObjekPath': dokumentasiObjek?.path,
      'dokumentasiSekitarPath': dokumentasiSekitar?.path,
      'ttdLineWalkerPath': ttdLineWalker?.path,
      'namaTTDLineWalker': namaTTDLineWalker,
      'ttdPJPekerjaanPath': ttdPJPekerjaan?.path,
      'namaTTDPJPekerjaan': namaTTDPJPekerjaan,
      'ttdTLGIPath': ttdTLGI?.path,
      'namaTTDTLGI': namaTTDTLGI,
    };
  }

  factory PPLInputModel.fromJsonDraft(Map<String, dynamic> json) {
    return PPLInputModel(
      towerId: json['towerId'] as int? ?? 0,
      namaTower: json['namaTower'] as String?,
      identifier: json['identifier']?.toString() ?? 'PPL',
      namaPekerjaan: json['namaPekerjaan']?.toString() ?? '',
      jenisObjek: json['jenisObjek']?.toString() ?? '',
      keteranganJenisObjek: json['keteranganJenisObjek']?.toString() ?? '',
      kategoriObjek: json['kategoriObjek']?.toString() ?? '',
      keteranganKategoriObjek: json['keteranganKategoriObjek']?.toString() ?? '',
      statusObjek: json['statusObjek']?.toString() ?? '',
      statusPekerjaan: json['statusPekerjaan']?.toString() ?? '',
      progressPekerjaan: json['progressPekerjaan']?.toString() ?? '',
      pihakPelaksana: json['pihakPelaksana']?.toString() ?? '',
      pjPekerjaan: json['pjPekerjaan']?.toString() ?? '',
      noTeleponPJPekerjaan: json['noTeleponPJPekerjaan']?.toString() ?? '',
      tanggapan: json['tanggapan']?.toString() ?? '',
      namaValidator: json['namaValidator']?.toString() ?? '',
      suratSosialisasi: json['suratSosialisasi'] != null
          ? DateTime.tryParse(json['suratSosialisasi'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lokasi: json['lokasi']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      dokumentasiPerwakilan: json['dokumentasiPerwakilanPath'] != null ? File(json['dokumentasiPerwakilanPath']) : null,
      dokumentasiObjek: json['dokumentasiObjekPath'] != null ? File(json['dokumentasiObjekPath']) : null,
      dokumentasiSekitar: json['dokumentasiSekitarPath'] != null ? File(json['dokumentasiSekitarPath']) : null,
      ttdLineWalker: json['ttdLineWalkerPath'] != null ? File(json['ttdLineWalkerPath']) : null,
      namaTTDLineWalker: json['namaTTDLineWalker']?.toString() ?? '',
      ttdPJPekerjaan: json['ttdPJPekerjaanPath'] != null ? File(json['ttdPJPekerjaanPath']) : null,
      namaTTDPJPekerjaan: json['namaTTDPJPekerjaan']?.toString() ?? '',
      ttdTLGI: json['ttdTLGIPath'] != null ? File(json['ttdTLGIPath']) : null,
      namaTTDTLGI: json['namaTTDTLGI']?.toString(),
    );
  }
}

class PPLHistoryItemModel {
  final int id;
  final String? namaPekerjaan;
  final String? namaTower;
  final String? createdAt;
  final String? statusPekerjaan;
  final String? progressPekerjaan;

  PPLHistoryItemModel({
    required this.id,
    this.namaPekerjaan,
    this.namaTower,
    this.createdAt,
    this.statusPekerjaan,
    this.progressPekerjaan,
  });

  factory PPLHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return PPLHistoryItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      namaPekerjaan: json['namaPekerjaan']?.toString(),
      namaTower: json['tower'] is Map ? json['tower']['nama']?.toString() : null,
      createdAt: json['createdAt']?.toString(),
      statusPekerjaan: json['statusPekerjaan']?.toString(),
      progressPekerjaan: json['progressPekerjaan']?.toString(),
    );
  }
}
