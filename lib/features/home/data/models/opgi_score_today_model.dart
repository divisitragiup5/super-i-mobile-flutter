import 'dart:convert';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/app_time_utils.dart';

/// Item metrik utama penilaian harian OPGI (NILAI HARIAN, POINT ABSENSI, POINT PERFORMA)
class OpgiScoreMainItemModel extends Equatable {
  final String label;
  final double point;

  const OpgiScoreMainItemModel({
    required this.label,
    required this.point,
  });

  factory OpgiScoreMainItemModel.fromJson(Map<String, dynamic> json) {
    final rawPoint = json['point'];
    final pointVal = rawPoint is num
        ? rawPoint.toDouble()
        : double.tryParse(rawPoint?.toString() ?? '') ?? 0.0;

    return OpgiScoreMainItemModel(
      label: json['label']?.toString() ?? '',
      point: pointVal,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'point': point,
      };

  @override
  List<Object?> get props => [label, point];
}

/// Item rincian komponen teknis penilaian OPGI (Catat Beban, Inspeksi IL1, Manuver, dll.)
class OpgiScoreDetailItemModel extends Equatable {
  final String label;
  final int target;
  final int realisasi;
  final double totalPoint;
  final double score; // Persentase progress (realisasi / target * 100)

  const OpgiScoreDetailItemModel({
    required this.label,
    required this.target,
    required this.realisasi,
    required this.totalPoint,
    required this.score,
  });

  factory OpgiScoreDetailItemModel.fromJson(Map<String, dynamic> json) {
    final label = json['label']?.toString() ?? '';
    final rawTarget = json['target'];
    final target = rawTarget is num
        ? rawTarget.toInt()
        : int.tryParse(rawTarget?.toString() ?? '') ?? 0;

    final stat = json['stat'] is Map<String, dynamic>
        ? json['stat'] as Map<String, dynamic>
        : <String, dynamic>{};

    final rawRealisasi = stat['realisasi'];
    final realisasi = rawRealisasi is num
        ? rawRealisasi.toInt()
        : int.tryParse(rawRealisasi?.toString() ?? '') ?? 0;

    final rawPoint = stat['totalPoint'];
    final totalPoint = rawPoint is num
        ? rawPoint.toDouble()
        : double.tryParse(rawPoint?.toString() ?? '') ?? 0.0;

    final double score =
        target > 0 ? (realisasi / target) * 100.0 : 0.0;

    return OpgiScoreDetailItemModel(
      label: label,
      target: target,
      realisasi: realisasi,
      totalPoint: totalPoint,
      score: score,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'target': target,
        'realisasi': realisasi,
        'totalPoint': totalPoint,
        'score': score,
      };

  @override
  List<Object?> get props => [label, target, realisasi, totalPoint, score];
}

/// Model data penilaian kinerja harian OPGI 20kV
class OpgiScoreTodayModel extends Equatable {
  final int? tanggal;
  final int? bulan;
  final int? tahun;
  final DateTime? createdAt;
  final List<OpgiScoreMainItemModel> main;
  final List<OpgiScoreDetailItemModel> detail;

  const OpgiScoreTodayModel({
    this.tanggal,
    this.bulan,
    this.tahun,
    this.createdAt,
    this.main = const [],
    this.detail = const [],
  });

  /// Mengonversi tanggal ke DateTime lokal user.
  /// Catatan: Nilai `bulan` dari backend JS (now.getMonth()) berindeks 0–11.
  DateTime get localDateTime {
    if (createdAt != null) {
      return createdAt!.toLocal();
    }
    if (tahun != null && bulan != null && tanggal != null) {
      final m = (bulan! >= 0 && bulan! <= 11) ? bulan! + 1 : bulan!;
      return DateTime(tahun!, m, tanggal!);
    }
    return DateTime.now();
  }

  /// Teks tanggal terformat sesuai bahasa Indonesia & zona waktu user
  String get formattedDate {
    return AppTimeUtils.formatDateTime(
      localDateTime,
      pattern: 'EEEE, dd MMMM yyyy',
    );
  }

  /// Nilai Harian (Primary gauge)
  OpgiScoreMainItemModel get nilaiHarian {
    for (final item in main) {
      if (item.label.toUpperCase().contains('HARIAN')) {
        return item;
      }
    }
    return main.isNotEmpty
        ? main.first
        : const OpgiScoreMainItemModel(label: 'NILAI HARIAN', point: 0.0);
  }

  /// Point Absensi (Secondary gauge 1)
  OpgiScoreMainItemModel get pointAbsensi {
    for (final item in main) {
      if (item.label.toUpperCase().contains('ABSEN')) {
        return item;
      }
    }
    return main.length > 1
        ? main[1]
        : const OpgiScoreMainItemModel(label: 'POINT ABSENSI', point: 0.0);
  }

  /// Point Performa (Secondary gauge 2)
  OpgiScoreMainItemModel get pointPerforma {
    for (final item in main) {
      if (item.label.toUpperCase().contains('PERFOR')) {
        return item;
      }
    }
    return main.length > 2
        ? main[2]
        : const OpgiScoreMainItemModel(label: 'POINT PERFORMA', point: 0.0);
  }

  factory OpgiScoreTodayModel.fromJson(Map<String, dynamic> json) {
    // Parsing list 'main' yang bisa berbentuk List atau JSON string dari MySQL raw query
    dynamic rawMain = json['main'];
    if (rawMain is String) {
      try {
        rawMain = jsonDecode(rawMain);
      } catch (_) {
        rawMain = null;
      }
    }

    final List<OpgiScoreMainItemModel> mainList = [];
    if (rawMain is List) {
      for (final item in rawMain) {
        if (item is Map<String, dynamic>) {
          mainList.add(OpgiScoreMainItemModel.fromJson(item));
        } else if (item is Map) {
          mainList.add(
            OpgiScoreMainItemModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    // Parsing list 'detail'
    dynamic rawDetail = json['detail'];
    if (rawDetail is String) {
      try {
        rawDetail = jsonDecode(rawDetail);
      } catch (_) {
        rawDetail = null;
      }
    }

    final List<OpgiScoreDetailItemModel> detailList = [];
    if (rawDetail is List) {
      for (final item in rawDetail) {
        if (item is Map<String, dynamic>) {
          detailList.add(OpgiScoreDetailItemModel.fromJson(item));
        } else if (item is Map) {
          detailList.add(
            OpgiScoreDetailItemModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final rawCreatedAt = json['createdAt']?.toString();
    final parsedCreatedAt = AppTimeUtils.parseToLocal(rawCreatedAt);

    return OpgiScoreTodayModel(
      tanggal: json['tanggal'] is num
          ? (json['tanggal'] as num).toInt()
          : int.tryParse(json['tanggal']?.toString() ?? ''),
      bulan: json['bulan'] is num
          ? (json['bulan'] as num).toInt()
          : int.tryParse(json['bulan']?.toString() ?? ''),
      tahun: json['tahun'] is num
          ? (json['tahun'] as num).toInt()
          : int.tryParse(json['tahun']?.toString() ?? ''),
      createdAt: parsedCreatedAt,
      main: mainList,
      detail: detailList,
    );
  }

  Map<String, dynamic> toJson() => {
        'tanggal': tanggal,
        'bulan': bulan,
        'tahun': tahun,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        'main': main.map((e) => e.toJson()).toList(),
        'detail': detail.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [tanggal, bulan, tahun, createdAt, main, detail];
}
