import 'package:equatable/equatable.dart';

class LocationCoordinateEntity extends Equatable {
  final double latitude;
  final double longitude;
  final String nama;
  final bool isValid;

  const LocationCoordinateEntity({
    required this.latitude,
    required this.longitude,
    required this.nama,
    required this.isValid,
  });

  @override
  List<Object?> get props => [latitude, longitude, nama, isValid];
}

class AbsenLocationEntity extends Equatable {
  final List<LocationCoordinateEntity> coordinates;
  final double radius;

  const AbsenLocationEntity({required this.coordinates, required this.radius});

  @override
  List<Object?> get props => [coordinates, radius];
}
