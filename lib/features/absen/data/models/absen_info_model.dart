import '../../domain/entities/absen_info_entity.dart';
import '../../domain/entities/absen_location_entity.dart';

class AbsenInfoModel extends AbsenInfoEntity {
  const AbsenInfoModel({
    super.shift,
    super.absen,
    required super.keterangan,
    super.absenLocation,
  });

  factory AbsenInfoModel.fromJson(Map<String, dynamic> json) {
    AbsenLocationEntity? location;
    if (json['absenLocation'] != null) {
      final locJson = json['absenLocation'] as Map<String, dynamic>;
      final coordsList =
          (locJson['coordinates'] as List<dynamic>?)
              ?.map(
                (item) => LocationCoordinateEntity(
                  latitude: (item['latitude'] as num).toDouble(),
                  longitude: (item['longitude'] as num).toDouble(),
                  nama: item['nama']?.toString() ?? 'Lokasi Presensi',
                  isValid: item['isValid'] as bool? ?? false,
                ),
              )
              .toList() ??
          [];

      location = AbsenLocationEntity(
        coordinates: coordsList,
        radius: (locJson['radius'] as num?)?.toDouble() ?? 100.0,
      );
    }

    return AbsenInfoModel(
      shift: json['shift'] as Map<String, dynamic>?,
      absen: json['absen'] as Map<String, dynamic>?,
      keterangan: json['keterangan']?.toString() ?? 'SHIFT TIDAK DITEMUKAN',
      absenLocation: location,
    );
  }
}
