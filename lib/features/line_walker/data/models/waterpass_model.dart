import 'dart:io';

class WaterpassInputModel {
  final int towerId;
  final String? namaTower;
  final double? hasilX;
  final double? hasilY;
  final double? hasilZ;
  final File? fotoSebelum;
  final File? fotoSetelah;
  final File? fotoX;
  final File? fotoY;
  final File? fotoZ;

  WaterpassInputModel({
    required this.towerId,
    this.namaTower,
    this.hasilX,
    this.hasilY,
    this.hasilZ,
    this.fotoSebelum,
    this.fotoSetelah,
    this.fotoX,
    this.fotoY,
    this.fotoZ,
  });

  Map<String, dynamic> toJsonDraft() {
    return {
      'towerId': towerId,
      'namaTower': namaTower,
      'hasilX': hasilX,
      'hasilY': hasilY,
      'hasilZ': hasilZ,
      'fotoSebelumPath': fotoSebelum?.path,
      'fotoSetelahPath': fotoSetelah?.path,
      'fotoXPath': fotoX?.path,
      'fotoYPath': fotoY?.path,
      'fotoZPath': fotoZ?.path,
    };
  }

  factory WaterpassInputModel.fromJsonDraft(Map<String, dynamic> json) {
    return WaterpassInputModel(
      towerId: json['towerId'] as int? ?? 0,
      namaTower: json['namaTower'] as String?,
      hasilX: (json['hasilX'] as num?)?.toDouble(),
      hasilY: (json['hasilY'] as num?)?.toDouble(),
      hasilZ: (json['hasilZ'] as num?)?.toDouble(),
      fotoSebelum: json['fotoSebelumPath'] != null
          ? File(json['fotoSebelumPath'])
          : null,
      fotoSetelah: json['fotoSetelahPath'] != null
          ? File(json['fotoSetelahPath'])
          : null,
      fotoX: json['fotoXPath'] != null ? File(json['fotoXPath']) : null,
      fotoY: json['fotoYPath'] != null ? File(json['fotoYPath']) : null,
      fotoZ: json['fotoZPath'] != null ? File(json['fotoZPath']) : null,
    );
  }
}

class WaterpassDetailModel {
  final int id;
  final String? namaTower;
  final String? createdAt;
  final double? hasilX;
  final double? hasilY;
  final double? hasilZ;
  final String? fotoSebelumUrl;
  final String? fotoSetelahUrl;
  final String? fotoXUrl;
  final String? fotoYUrl;
  final String? fotoZUrl;

  WaterpassDetailModel({
    required this.id,
    this.namaTower,
    this.createdAt,
    this.hasilX,
    this.hasilY,
    this.hasilZ,
    this.fotoSebelumUrl,
    this.fotoSetelahUrl,
    this.fotoXUrl,
    this.fotoYUrl,
    this.fotoZUrl,
  });

  factory WaterpassDetailModel.fromJson(Map<String, dynamic> json) {
    return WaterpassDetailModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      namaTower: json['tower'] is Map ? json['tower']['nama']?.toString() : null,
      createdAt: json['createdAt']?.toString(),
      hasilX: (json['waterpassX'] is Map ? json['waterpassX']['hasil'] : json['hasilX']) as double?,
      hasilY: (json['waterpassY'] is Map ? json['waterpassY']['hasil'] : json['hasilY']) as double?,
      hasilZ: (json['waterpassZ'] is Map ? json['waterpassZ']['hasil'] : json['hasilZ']) as double?,
      fotoSebelumUrl: json['fotoTowerSebelumInspeksi'] is Map ? json['fotoTowerSebelumInspeksi']['uri']?.toString() : null,
      fotoSetelahUrl: json['fotoTowerSetelahInspeksi'] is Map ? json['fotoTowerSetelahInspeksi']['uri']?.toString() : null,
      fotoXUrl: json['waterpassX'] is Map && json['waterpassX']['pict'] is Map ? json['waterpassX']['pict']['uri']?.toString() : null,
      fotoYUrl: json['waterpassY'] is Map && json['waterpassY']['pict'] is Map ? json['waterpassY']['pict']['uri']?.toString() : null,
      fotoZUrl: json['waterpassZ'] is Map && json['waterpassZ']['pict'] is Map ? json['waterpassZ']['pict']['uri']?.toString() : null,
    );
  }
}
