import 'package:equatable/equatable.dart';

abstract class AbsenSubmitState extends Equatable {
  const AbsenSubmitState();

  @override
  List<Object?> get props => [];
}

class AbsenSubmitInitial extends AbsenSubmitState {}

class AbsenSubmitLoading extends AbsenSubmitState {}

class AbsenSubmitSuccess extends AbsenSubmitState {
  final String message;
  final Map<String, dynamic> responseData;

  const AbsenSubmitSuccess({required this.message, required this.responseData});

  @override
  List<Object?> get props => [message, responseData];
}

class AbsenSubmitError extends AbsenSubmitState {
  final String message;

  const AbsenSubmitError(this.message);

  @override
  List<Object?> get props => [message];
}
