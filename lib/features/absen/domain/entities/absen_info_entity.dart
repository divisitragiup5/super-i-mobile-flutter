import 'package:equatable/equatable.dart';

import 'absen_location_entity.dart';

class AbsenInfoEntity extends Equatable {
  final Map<String, dynamic>? shift;
  final Map<String, dynamic>? absen;
  final String keterangan;
  final AbsenLocationEntity? absenLocation;

  const AbsenInfoEntity({
    this.shift,
    this.absen,
    required this.keterangan,
    this.absenLocation,
  });

  /// Cek apakah user memiliki jadwal shift hari ini
  bool get hasShift => shift != null;

  /// Cek apakah user sudah melakukan absen masuk
  bool get hasInAbsen => absen != null && absen!['absenMasuk'] != null;

  /// Cek apakah status premi OFF
  bool get isPremiOff => absen != null && absen!['premi'] == 'OFF';

  @override
  List<Object?> get props => [shift, absen, keterangan, absenLocation];
}
