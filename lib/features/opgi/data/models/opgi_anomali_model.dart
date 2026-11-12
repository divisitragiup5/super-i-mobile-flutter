import 'package:equatable/equatable.dart';
import '../../../../core/utils/app_time_utils.dart';

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
  final Map<String, dynamic>? rawJson;

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
    this.rawJson,
  });

  /// Kondisi terakhir (terbaru) dari laporan anomali ini
  AnomaliKondisiModel? get latestKondisi =>
      kondisiList.isNotEmpty ? kondisiList.first : null;

  String get latestUrgensi => latestKondisi?.urgensi ?? urgensi;
  String get latestTindakan => latestKondisi?.tindakan ?? tindakan;
  String get latestKeterangan => latestKondisi?.keterangan ?? keterangan;
  String? get latestFotoBuktiUrl => latestKondisi?.fotoBuktiUrl ?? fotoBuktiUrl;
  String? get latestVideoBuktiUrl =>
      latestKondisi?.videoBuktiUrl ?? videoBuktiUrl;
  DateTime? get latestCreatedAt => (latestKondisi?.createdAt ?? createdAt)?.toLocal();

  bool get isSelesai => latestTindakan.toUpperCase() == 'SELESAI';

  factory AnomaliReportModel.fromJson(Map<String, dynamic> json) {
    // 1. Ambil Nama Aset
    String assetName = '-';
    int aId = json['assetId'] as int? ?? 0;
    int? giId = json['garduIndukId'] as int?;
    String? giNama = json['namaGarduInduk'] as String?;

    if (json['penyulang'] is Map) {
      final p = json['penyulang'] as Map<String, dynamic>;
      assetName = p['nama']?.toString() ?? '-';
      if (p['id'] != null) aId = p['id'] as int;
      if (p['garduInduk'] is Map) {
        giId = p['garduInduk']['id'] as int?;
        giNama = p['garduInduk']['nama']?.toString();
      } else if (p['garduIndukId'] != null) {
        giId = p['garduIndukId'] as int?;
      }
    } else if (json['trafo'] is Map) {
      final t = json['trafo'] as Map<String, dynamic>;
      assetName = t['nama']?.toString() ?? '-';
      if (t['id'] != null) aId = t['id'] as int;
      if (t['garduInduk'] is Map) {
        giId = t['garduInduk']['id'] as int?;
        giNama = t['garduInduk']['nama']?.toString();
      } else if (t['garduIndukId'] != null) {
        giId = t['garduIndukId'] as int?;
      }
    } else if (json['assetNama'] != null) {
      assetName = json['assetNama'].toString();
    }

    // 2. Ambil Nama Petugas / Operator
    String? petugas;
    if (json['operator'] is Map && json['operator']['petugas'] is Map) {
      final pet = json['operator']['petugas'];
      if (pet['user'] is Map && pet['user']['namaLengkap'] != null) {
        petugas = pet['user']['namaLengkap']?.toString();
      } else if (pet['nama'] != null) {
        petugas = pet['nama']?.toString();
      }
    } else if (json['user'] is Map && json['user']['nama'] != null) {
      petugas = json['user']['nama']?.toString();
    } else if (json['namaPetugas'] != null) {
      petugas = json['namaPetugas']?.toString();
    }

    // 3. Ambil URL Foto Bukti & Video Bukti
    String? photoUrl = _extractMediaUrl(json['bukti'] ?? json['fotoBuktiUrl']);
    String? vidUrl = _extractMediaUrl(
        json['vidioBukti'] ?? json['buktiVideo'] ?? json['videoBuktiUrl']);

    // 4. Ambil Daftar Kondisi
    List<AnomaliKondisiModel> listKondisi = [];
    final rawKondisi = json['kondisi'] ?? json['anomaliReportKondisi'];
    if (rawKondisi is List) {
      for (int i = 0; i < rawKondisi.length; i++) {
        final k = rawKondisi[i];
        if (k is Map<String, dynamic>) {
          listKondisi.add(AnomaliKondisiModel.fromJson(k, isLast: i == 0));
        }
      }
    }

    // 5. Default urgensi/tindakan dari latest kondisi jika ada
    String defUrgensi = json['urgensi']?.toString() ?? 'AMAN';
    String defTindakan = json['tindakan']?.toString() ?? 'TIDAK ADA';
    String defKeterangan = json['keterangan']?.toString() ?? '';
    if (listKondisi.isNotEmpty) {
      defUrgensi = listKondisi.first.urgensi;
      defTindakan = listKondisi.first.tindakan;
      if (defKeterangan.isEmpty) {
        defKeterangan = listKondisi.first.keterangan;
      }
      photoUrl ??= listKondisi.first.fotoBuktiUrl;
      vidUrl ??= listKondisi.first.videoBuktiUrl;
    }

    return AnomaliReportModel(
      id: json['id'] as int? ?? 0,
      jenisAsset: json['jenisAsset']?.toString() ?? 'PENYULANG',
      assetId: aId,
      assetNama: assetName,
      entitas: json['entitas']?.toString() ?? 'KUBIKEL',
      urgensi: defUrgensi,
      tindakan: defTindakan,
      keterangan: defKeterangan,
      fotoBuktiUrl: photoUrl,
      videoBuktiUrl: vidUrl,
      createdAt: AppTimeUtils.parseToLocal(json['createdAt']?.toString()),
      namaPetugas: petugas,
      garduIndukId: giId,
      namaGarduInduk: giNama,
      kondisiList: listKondisi,
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'jenisAsset': jenisAsset,
        'assetId': assetId,
        'assetNama': assetNama,
        'entitas': entitas,
        'urgensi': urgensi,
        'tindakan': tindakan,
        'keterangan': keterangan,
        if (fotoBuktiUrl != null) 'fotoBuktiUrl': fotoBuktiUrl,
        if (videoBuktiUrl != null) 'videoBuktiUrl': videoBuktiUrl,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (namaPetugas != null) 'namaPetugas': namaPetugas,
        if (garduIndukId != null) 'garduIndukId': garduIndukId,
        if (namaGarduInduk != null) 'namaGarduInduk': namaGarduInduk,
        'kondisi': kondisiList.map((k) => k.toJson()).toList(),
      };

  AnomaliReportModel copyWith({
    int? id,
    String? jenisAsset,
    int? assetId,
    String? assetNama,
    String? entitas,
    String? urgensi,
    String? tindakan,
    String? keterangan,
    String? fotoBuktiUrl,
    String? videoBuktiUrl,
    DateTime? createdAt,
    String? namaPetugas,
    int? garduIndukId,
    String? namaGarduInduk,
    List<AnomaliKondisiModel>? kondisiList,
  }) {
    return AnomaliReportModel(
      id: id ?? this.id,
      jenisAsset: jenisAsset ?? this.jenisAsset,
      assetId: assetId ?? this.assetId,
      assetNama: assetNama ?? this.assetNama,
      entitas: entitas ?? this.entitas,
      urgensi: urgensi ?? this.urgensi,
      tindakan: tindakan ?? this.tindakan,
      keterangan: keterangan ?? this.keterangan,
      fotoBuktiUrl: fotoBuktiUrl ?? this.fotoBuktiUrl,
      videoBuktiUrl: videoBuktiUrl ?? this.videoBuktiUrl,
      createdAt: createdAt ?? this.createdAt,
      namaPetugas: namaPetugas ?? this.namaPetugas,
      garduIndukId: garduIndukId ?? this.garduIndukId,
      namaGarduInduk: namaGarduInduk ?? this.namaGarduInduk,
      kondisiList: kondisiList ?? this.kondisiList,
      rawJson: rawJson,
    );
  }

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
        namaPetugas,
        garduIndukId,
        namaGarduInduk,
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
  final bool isLast;
  final Map<String, dynamic>? rawJson;

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
    this.isLast = false,
    this.rawJson,
  });

  factory AnomaliKondisiModel.fromJson(Map<String, dynamic> json,
      {bool isLast = false}) {
    String? photoUrl = _extractMediaUrl(json['bukti'] ?? json['fotoBuktiUrl']);
    String? vidUrl = _extractMediaUrl(
        json['vidioBukti'] ?? json['buktiVideo'] ?? json['videoBuktiUrl']);

    return AnomaliKondisiModel(
      id: json['id'] as int? ?? 0,
      anomaliId:
          json['anomaliId'] as int? ?? json['anomaliReportId'] as int? ?? 0,
      urgensi: json['urgensi']?.toString() ?? 'AMAN',
      tindakan: json['tindakan']?.toString() ?? 'TIDAK ADA',
      keterangan: json['keterangan']?.toString() ?? '',
      fotoBuktiUrl: photoUrl,
      videoBuktiUrl: vidUrl,
      createdAt: AppTimeUtils.parseToLocal(json['createdAt']?.toString()),
      namaPetugas: json['user']?['nama']?.toString() ??
          json['operator']?['petugas']?['user']?['namaLengkap']?.toString() ??
          json['namaPetugas']?.toString(),
      isLast: isLast,
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'anomaliId': anomaliId,
        'urgensi': urgensi,
        'tindakan': tindakan,
        'keterangan': keterangan,
        if (fotoBuktiUrl != null) 'fotoBuktiUrl': fotoBuktiUrl,
        if (videoBuktiUrl != null) 'videoBuktiUrl': videoBuktiUrl,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (namaPetugas != null) 'namaPetugas': namaPetugas,
        'isLast': isLast,
      };

  AnomaliKondisiModel copyWith({
    int? id,
    int? anomaliId,
    String? urgensi,
    String? tindakan,
    String? keterangan,
    String? fotoBuktiUrl,
    String? videoBuktiUrl,
    DateTime? createdAt,
    String? namaPetugas,
    bool? isLast,
  }) {
    return AnomaliKondisiModel(
      id: id ?? this.id,
      anomaliId: anomaliId ?? this.anomaliId,
      urgensi: urgensi ?? this.urgensi,
      tindakan: tindakan ?? this.tindakan,
      keterangan: keterangan ?? this.keterangan,
      fotoBuktiUrl: fotoBuktiUrl ?? this.fotoBuktiUrl,
      videoBuktiUrl: videoBuktiUrl ?? this.videoBuktiUrl,
      createdAt: createdAt ?? this.createdAt,
      namaPetugas: namaPetugas ?? this.namaPetugas,
      isLast: isLast ?? this.isLast,
      rawJson: rawJson,
    );
  }

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
        namaPetugas,
        isLast,
      ];
}

String? _extractMediaUrl(dynamic media) {
  if (media == null) return null;
  if (media is String) {
    if (media.trim().isEmpty) return null;
    return media;
  }
  if (media is Map) {
    if (media['uri'] != null && media['uri'].toString().isNotEmpty) {
      return media['uri'].toString();
    }
    if (media['path'] != null && media['path'].toString().isNotEmpty) {
      return media['path'].toString();
    }
    if (media['url'] != null && media['url'].toString().isNotEmpty) {
      return media['url'].toString();
    }
  }
  return null;
}
