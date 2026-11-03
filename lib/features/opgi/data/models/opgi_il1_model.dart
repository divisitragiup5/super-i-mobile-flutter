import 'package:equatable/equatable.dart';

class Il1KubikelItem extends Equatable {
  final int id; // penyulangId
  final String nama;
  final String? kode;
  final int? garduIndukId;
  final String? garduIndukNama;
  final bool sudahInspeksi;
  final Map<String, dynamic>? lastInspeksi;

  const Il1KubikelItem({
    required this.id,
    required this.nama,
    this.kode,
    this.garduIndukId,
    this.garduIndukNama,
    this.sudahInspeksi = false,
    this.lastInspeksi,
  });

  factory Il1KubikelItem.fromJson(Map<String, dynamic> json) {
    final il1List = json['il1'] as List?;
    final hasIl1 = il1List != null && il1List.isNotEmpty;
    return Il1KubikelItem(
      id: json['id'] as int? ?? 0,
      nama: json['nama'] as String? ?? '-',
      kode: json['kode'] as String?,
      garduIndukId: json['garduInduk']?['id'] as int? ?? json['garduIndukId'] as int?,
      garduIndukNama: json['garduInduk']?['nama'] as String?,
      sudahInspeksi: hasIl1,
      lastInspeksi: hasIl1 ? il1List.first as Map<String, dynamic>? : null,
    );
  }

  @override
  List<Object?> get props => [id, nama, sudahInspeksi];
}

class Il1TrafoPsItem extends Equatable {
  final int id; // trafoId
  final String nama;
  final int? garduIndukId;
  final String? garduIndukNama;
  final bool sudahInspeksi;
  final Map<String, dynamic>? lastInspeksi;

  const Il1TrafoPsItem({
    required this.id,
    required this.nama,
    this.garduIndukId,
    this.garduIndukNama,
    this.sudahInspeksi = false,
    this.lastInspeksi,
  });

  factory Il1TrafoPsItem.fromJson(Map<String, dynamic> json) {
    final il1List = json['il1TrafoPS'] as List?;
    final hasIl1 = il1List != null && il1List.isNotEmpty;
    return Il1TrafoPsItem(
      id: json['id'] as int? ?? 0,
      nama: json['nama'] as String? ?? '-',
      garduIndukId: json['garduInduk']?['id'] as int? ?? json['garduIndukId'] as int?,
      garduIndukNama: json['garduInduk']?['nama'] as String?,
      sudahInspeksi: hasIl1,
      lastInspeksi: hasIl1 ? il1List.first as Map<String, dynamic>? : null,
    );
  }

  @override
  List<Object?> get props => [id, nama, sudahInspeksi];
}

class Il1SipilItem extends Equatable {
  final int garduIndukId;
  final String gedung;
  final String nama;
  final bool sudahInspeksi;
  final Map<String, dynamic>? lastInspeksi;

  const Il1SipilItem({
    required this.garduIndukId,
    required this.gedung,
    required this.nama,
    this.sudahInspeksi = false,
    this.lastInspeksi,
  });

  factory Il1SipilItem.fromJson(Map<String, dynamic> json) {
    final il1List = json['il1Sipil'] as List?;
    final hasIl1 = il1List != null && il1List.isNotEmpty;
    return Il1SipilItem(
      garduIndukId: json['garduIndukId'] as int? ?? json['garduInduk']?['id'] as int? ?? 0,
      gedung: json['gedung'] as String? ?? 'CELL',
      nama: json['nama'] as String? ?? 'Gedung Kontrol',
      sudahInspeksi: hasIl1,
      lastInspeksi: hasIl1 ? il1List.first as Map<String, dynamic>? : null,
    );
  }

  @override
  List<Object?> get props => [garduIndukId, gedung, sudahInspeksi];
}
