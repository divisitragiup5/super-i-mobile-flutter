import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/absen_info_entity.dart';

abstract class AbsenInfoState extends Equatable {
  const AbsenInfoState();

  @override
  List<Object?> get props => [];
}

class AbsenInfoInitial extends AbsenInfoState {}

class AbsenInfoLoading extends AbsenInfoState {}

class AbsenInfoLoaded extends AbsenInfoState {
  final AbsenInfoEntity info;
  final Position? userPosition;
  final bool isInsideRadius;

  const AbsenInfoLoaded({
    required this.info,
    this.userPosition,
    this.isInsideRadius = false,
  });

  @override
  List<Object?> get props => [info, userPosition, isInsideRadius];
}

class AbsenInfoError extends AbsenInfoState {
  final String message;

  const AbsenInfoError({required this.message});

  @override
  List<Object?> get props => [message];
}
