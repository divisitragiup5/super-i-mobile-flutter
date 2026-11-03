import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/services/permission_service.dart';
import '../../domain/repositories/absen_repository.dart';
import 'absen_info_state.dart';

class AbsenInfoCubit extends Cubit<AbsenInfoState> {
  final AbsenRepository repository;
  final PermissionService permissionService;

  AbsenInfoCubit({required this.repository, required this.permissionService})
    : super(AbsenInfoInitial());

  Future<void> fetchAbsenInfo() async {
    emit(AbsenInfoLoading());

    // 1. Ambil izin lokasi
    final hasLocationPermission = await permissionService
        .requestLocationPermission();

    Position? position;
    if (hasLocationPermission) {
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
      } catch (_) {}
    }

    // 2. Ambil data info absen dari backend
    final result = await repository.getAbsensiInfo();

    result.fold((failure) => emit(AbsenInfoError(message: failure.message)), (
      info,
    ) {
      // 3. Hitung apakah posisi user ada di dalam radius geofence
      bool isInside = false;
      if (position != null && info.absenLocation != null) {
        final radius = info.absenLocation!.radius;
        for (final coord in info.absenLocation!.coordinates) {
          final distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            coord.latitude,
            coord.longitude,
          );
          if (distance <= radius) {
            isInside = true;
            break;
          }
        }
      }

      emit(
        AbsenInfoLoaded(
          info: info,
          userPosition: position,
          isInsideRadius: isInside,
        ),
      );
    });
  }
}
