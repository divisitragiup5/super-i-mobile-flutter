import 'package:equatable/equatable.dart';

class AnomaliReportModel extends Equatable {
  final int id;
  final String jenisAsset; // 'PENYULANG' | 'TRAFO'
  final int assetId;
  final String assetNama;
  final String entitas; // 'KUBIKEL' | 'KWH' | 'TRAFO' | 'RELAY'
  final String urgensi; // 'BAHAYA' | 'INVESTIGASI LANJUTAN' | 'AMAN'
  final String tindakan; // 'TIDAK ADA' | 'ON PROGRES' | 'SELESAI'
  final String keterangan;
  final String? fotoBuktiUrl;
  final String? videoBuktiUrl;
  final DateTime? createdAt;
  final String? namaPetugas;
  final int? garduIndukId;
  final String? namaGarduInduk;
  final List<AnomaliKondisiModel> kondisiList;

  const AnomaliReportModel({
    required this.id,
    required this.jenisAsset,
    required this.assetId,
    required this.assetNama,
    required this.entitas,
    required this.urgensi,
    required this.tindakan,
    required this.keterangan,
    this.fotoBuktiUrl,
    this.videoBuktiUrl,
    this.createdAt,
    this.namaPetugas,
    this.garduIndukId,
    this.namaGarduInduk,
    this.kondisiList = const [],
  });

  factory AnomaliReportModel.fromJson(Map<String, dynamic> json) {
    String assetName = '-';
    if (json['penyulang'] != null && json['penyulang']['nama'] != null) {
      assetName = json['penyulang']['nama'];
    } else if (json['trafo'] != null && json['trafo']['nama'] != null) {
      assetName = json['trafo']['nama'];
    } else if (json['assetNama'] != null) {
      assetName = json['assetNama'];
    }

    String? photoUrl;
    if (json['bukti'] != null && json['bukti']['path'] != null) {
      photoUrl = json['bukti']['path'];
    } else if (json['buktiUrl'] != null) {
      photoUrl = json['buktiUrl'];
    }

    String? vidUrl;
    if (json['buktiVideo'] != null && json['buktiVideo']['path'] != null) {
      vidUrl = json['buktiVideo']['path'];
    }

    List<AnomaliKondisiModel> listKondisi = [];
    if (json['anomaliReportKondisi'] is List) {
      listKondisi = (json['anomaliReportKondisi'] as List)
          .map((k) => AnomaliKondisiModel.fromJson(k))
          .toList();
    }

    return AnomaliReportModel(
      id: json['id'] as int? ?? 0,
      jenisAsset: json['jenisAsset'] as String? ?? 'PENYULANG',
      assetId: json['assetId'] as int? ?? 0,
      assetNama: assetName,
      entitas: json['entitas'] as String? ?? 'KUBIKEL',
      urgensi: json['urgensi'] as String? ?? 'AMAN',
      tindakan: json['tindakan'] as String? ?? 'TIDAK ADA',
      keterangan: json['keterangan'] as String? ?? '',
      fotoBuktiUrl: photoUrl,
      videoBuktiUrl: vidUrl,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      namaPetugas: json['user']?['nama'] as String? ?? json['namaPetugas'] as String?,
      garduIndukId: json['garduIndukId'] as int? ?? json['garduInduk']?['id'] as int?,
      namaGarduInduk: json['garduInduk']?['nama'] as String?,
      kondisiList: listKondisi,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'jenisAsset': jenisAsset,
        'assetId': assetId,
        'entitas': entitas,
        'urgensi': urgensi,
        'tindakan': tindakan,
        'keterangan': keterangan,
        if (garduIndukId != null) 'garduIndukId': garduIndukId,
      };

  @override
  List<Object?> get props => [
        id,
        jenisAsset,
        assetId,
        assetNama,
        entitas,
        urgensi,
        tindakan,
        keterangan,
        fotoBuktiUrl,
        videoBuktiUrl,
        createdAt,
        kondisiList,
      ];
}

class AnomaliKondisiModel extends Equatable {
  final int id;
  final int anomaliId;
  final String urgensi;
  final String tindakan;
  final String keterangan;
  final String? fotoBuktiUrl;
  final String? videoBuktiUrl;
  final DateTime? createdAt;
  final String? namaPetugas;

  const AnomaliKondisiModel({
    required this.id,
    required this.anomaliId,
    required this.urgensi,
    required this.tindakan,
    required this.keterangan,
    this.fotoBuktiUrl,
    this.videoBuktiUrl,
    this.createdAt,
    this.namaPetugas,
  });

  factory AnomaliKondisiModel.fromJson(Map<String, dynamic> json) {
    String? photoUrl;
    if (json['bukti'] != null && json['bukti']['path'] != null) {
      photoUrl = json['bukti']['path'];
    }

    String? vidUrl;
    if (json['buktiVideo'] != null && json['buktiVideo']['path'] != null) {
      vidUrl = json['buktiVideo']['path'];
    }

    return AnomaliKondisiModel(
      id: json['id'] as int? ?? 0,
      anomaliId: json['anomaliId'] as int? ?? json['anomaliReportId'] as int? ?? 0,
      urgensi: json['urgensi'] as String? ?? 'AMAN',
      tindakan: json['tindakan'] as String? ?? 'TIDAK ADA',
      keterangan: json['keterangan'] as String? ?? '',
      fotoBuktiUrl: photoUrl,
      videoBuktiUrl: vidUrl,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      namaPetugas: json['user']?['nama'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'anomaliId': anomaliId,
        'urgensi': urgensi,
        'tindakan': tindakan,
        'keterangan': keterangan,
      };

  @override
  List<Object?> get props => [
        id,
        anomaliId,
        urgensi,
        tindakan,
        keterangan,
        fotoBuktiUrl,
        videoBuktiUrl,
        createdAt,
      ];
}
