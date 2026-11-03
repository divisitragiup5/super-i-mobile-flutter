import 'sutm_workorder_model.dart';

/// Parameter pencarian aset SUTM di sekitar lokasi petugas Yantek
class YantekFilterParams {
  final double lat;
  final double lng;
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  const YantekFilterParams({
    required this.lat,
    required this.lng,
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });

  Map<String, dynamic> toQueryParams() => {
        'lat': lat,
        'lng': lng,
        'minLat': minLat,
        'maxLat': maxLat,
        'minLng': minLng,
        'maxLng': maxLng,
      };
}

/// Aset SUTM untuk peta interaktif Yantek
class YantekAssetModel {
  final int id;
  final String idAsset;
  final String nama;
  final double latitude;
  final double longitude;
  final String color;
  final LastInspeksiModel? lastInspeksi;

  const YantekAssetModel({
    required this.id,
    required this.idAsset,
    required this.nama,
    required this.latitude,
    required this.longitude,
    required this.color,
    this.lastInspeksi,
  });

  factory YantekAssetModel.fromJson(Map<String, dynamic> json) {
    final lat = double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0;
    final lng = double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0;

    LastInspeksiModel? lastInsp;
    if (json['lastInspeksi'] != null) {
      lastInsp = LastInspeksiModel.fromJson(
        json['lastInspeksi'] as Map<String, dynamic>,
      );
    }

    final healthColor = lastInsp?.healthIndex?.color ?? 'rgba(239, 239, 239, 0.3)';

    return YantekAssetModel(
      id: json['id'] as int? ?? 0,
      idAsset: json['idAsset'] as String? ?? 'SUTM',
      nama: json['nama'] as String? ?? json['name'] as String? ?? 'SUTM',
      latitude: lat,
      longitude: lng,
      color: healthColor,
      lastInspeksi: lastInsp,
    );
  }
}
