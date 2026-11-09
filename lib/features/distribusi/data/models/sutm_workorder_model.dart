class SutmFeederModel {
  final int? id;
  final String nama;
  final String? kode;

  const SutmFeederModel({
    this.id,
    required this.nama,
    this.kode,
  });

  factory SutmFeederModel.fromJson(Map<String, dynamic> json) {
    return SutmFeederModel(
      id: json['id'] as int?,
      nama: json['nama'] as String? ?? json['name'] as String? ?? '-',
      kode: json['kode'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'kode': kode,
      };
}

class HealthIndexModel {
  final int? id;
  final String? name;
  final String? color;
  final int? value;

  const HealthIndexModel({
    this.id,
    this.name,
    this.color,
    this.value,
  });

  factory HealthIndexModel.fromJson(Map<String, dynamic> json) {
    return HealthIndexModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? json['nama'] as String?,
      color: json['color'] as String?,
      value: json['value'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'value': value,
      };
}

class LastInspeksiModel {
  final int? id;
  final String? status;
  final String? tanggal;
  final HealthIndexModel? healthIndex;
  final List<dynamic>? komponen;
  final List<dynamic>? row;
  final String? kendala;
  final String? fotoKendala;
  final String? pelaksanaan;

  const LastInspeksiModel({
    this.id,
    this.status,
    this.tanggal,
    this.healthIndex,
    this.komponen,
    this.row,
    this.kendala,
    this.fotoKendala,
    this.pelaksanaan,
  });

  factory LastInspeksiModel.fromJson(Map<String, dynamic> json) {
    return LastInspeksiModel(
      id: json['id'] as int?,
      status: json['status'] as String?,
      tanggal: json['tanggal'] as String? ?? json['createdAt'] as String?,
      healthIndex: json['healthIndex'] != null
          ? HealthIndexModel.fromJson(json['healthIndex'] as Map<String, dynamic>)
          : null,
      komponen: json['komponen'] as List<dynamic>?,
      row: json['row'] as List<dynamic>?,
      kendala: json['kendala'] as String?,
      fotoKendala: json['fotoKendala'] as String?,
      pelaksanaan: json['pelaksanaan'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'tanggal': tanggal,
        'healthIndex': healthIndex?.toJson(),
        'komponen': komponen,
        'row': row,
        'kendala': kendala,
        'fotoKendala': fotoKendala,
        'pelaksanaan': pelaksanaan,
      };
}

class RencanaItemModel {
  final int id;
  final String sub;
  final String komponen;
  final String? fasa;
  final String? nilai;
  final int jumlah;
  final dynamic progress;

  const RencanaItemModel({
    required this.id,
    required this.sub,
    required this.komponen,
    this.fasa,
    this.nilai,
    this.jumlah = 1,
    this.progress,
  });

  factory RencanaItemModel.fromJson(Map<String, dynamic> json) {
    return RencanaItemModel(
      id: json['id'] as int? ?? 0,
      sub: json['sub'] as String? ?? '',
      komponen: json['komponen'] as String? ?? '',
      fasa: json['fasa'] as String?,
      nilai: json['nilai'] as String?,
      jumlah: json['jumlah'] as int? ?? 1,
      progress: json['progress'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sub': sub,
        'komponen': komponen,
        'fasa': fasa,
        'nilai': nilai,
        'jumlah': jumlah,
        'progress': progress,
      };
}

class SutmItemModel {
  final int id; // ID dari workOrderSutmItem
  final int sutmId;
  final String idAsset;
  final String nama;
  final double? latitude;
  final double? longitude;
  final SutmFeederModel? feeder;
  final String status;
  final String? inspectionId;
  final LastInspeksiModel? lastInspeksi;
  final List<RencanaItemModel> rencana;
  final bool canValidasi;

  const SutmItemModel({
    required this.id,
    required this.sutmId,
    required this.idAsset,
    required this.nama,
    this.latitude,
    this.longitude,
    this.feeder,
    this.status = 'OPEN',
    this.inspectionId,
    this.lastInspeksi,
    this.rencana = const [],
    this.canValidasi = false,
  });

  factory SutmItemModel.fromJson(Map<String, dynamic> json) {
    final sutmJson = json['sutm'] as Map<String, dynamic>? ?? json;

    double? lat;
    final rawLat = sutmJson['latitude'] ?? json['latitude'];
    if (rawLat != null) {
      lat = double.tryParse(rawLat.toString());
    }

    double? lng;
    final rawLng = sutmJson['longitude'] ?? json['longitude'];
    if (rawLng != null) {
      lng = double.tryParse(rawLng.toString());
    }

    // Ekstrak status inspeksi terbaru jika ada di array inspeksiSUTM
    String itemStatus = 'OPEN';
    String? inspId;
    if (json['inspeksiSUTM'] is List && (json['inspeksiSUTM'] as List).isNotEmpty) {
      final firstInsp = (json['inspeksiSUTM'] as List).first as Map<String, dynamic>;
      itemStatus = firstInsp['status'] as String? ?? 'OPEN';
      inspId = firstInsp['id']?.toString();
    } else if (json['status'] != null) {
      itemStatus = json['status'].toString();
    }

    // Ekstrak list rencana pemeliharaan jika ada
    List<RencanaItemModel> rencanaList = [];
    if (json['rencana'] is List) {
      rencanaList = (json['rencana'] as List)
          .map((r) => RencanaItemModel.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    return SutmItemModel(
      id: json['id'] as int? ?? json['workOrderSutmItemId'] as int? ?? 0,
      sutmId: sutmJson['id'] as int? ?? 0,
      idAsset: sutmJson['idAsset'] as String? ?? '-',
      nama: sutmJson['nama'] as String? ?? sutmJson['name'] as String? ?? '-',
      latitude: lat,
      longitude: lng,
      feeder: sutmJson['feeder'] != null
          ? SutmFeederModel.fromJson(sutmJson['feeder'] as Map<String, dynamic>)
          : null,
      status: itemStatus,
      inspectionId: inspId ?? json['inspectionId']?.toString(),
      lastInspeksi: sutmJson['lastInspeksi'] != null
          ? LastInspeksiModel.fromJson(
              sutmJson['lastInspeksi'] as Map<String, dynamic>)
          : null,
      rencana: rencanaList,
      canValidasi: json['canValidasi'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sutmId': sutmId,
        'idAsset': idAsset,
        'nama': nama,
        'latitude': latitude,
        'longitude': longitude,
        'feeder': feeder?.toJson(),
        'status': status,
        'inspectionId': inspectionId,
        'lastInspeksi': lastInspeksi?.toJson(),
        'rencana': rencana.map((r) => r.toJson()).toList(),
        'canValidasi': canValidasi,
      };
}

class SutmWorkOrderItem {
  final int id;
  final String status;
  final String? startDate;
  final String? endDate;
  final int totalSutm;
  final int pendingCount;
  final String? lintasan;
  final String? title;
  final List<SutmItemModel> items;

  const SutmWorkOrderItem({
    required this.id,
    required this.status,
    this.startDate,
    this.endDate,
    this.totalSutm = 0,
    this.pendingCount = 0,
    this.lintasan,
    this.title,
    this.items = const [],
  });

  factory SutmWorkOrderItem.fromJson(Map<String, dynamic> json) {
    List<SutmItemModel> sutmItems = [];
    if (json['items'] is List) {
      sutmItems = (json['items'] as List)
          .map((i) => SutmItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    final total = json['totalSutm'] as int? ??
        json['_count']?['items'] as int? ??
        sutmItems.length;

    return SutmWorkOrderItem(
      id: json['id'] as int? ?? 0,
      status: json['status'] as String? ?? 'OPEN',
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      totalSutm: total,
      pendingCount: json['pendingCount'] as int? ?? 0,
      lintasan: json['lintasan'] as String?,
      title: json['nama'] as String? ??
          json['title'] as String? ??
          json['lintasan'] as String? ??
          'WO-${json['id']}',
      items: sutmItems,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'startDate': startDate,
        'endDate': endDate,
        'totalSutm': totalSutm,
        'pendingCount': pendingCount,
        'lintasan': lintasan,
        'title': title,
        'items': items.map((i) => i.toJson()).toList(),
      };
}
