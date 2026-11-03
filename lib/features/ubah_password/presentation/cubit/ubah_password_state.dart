import 'package:equatable/equatable.dart';

abstract class UbahPasswordState extends Equatable {
  const UbahPasswordState();

  @override
  List<Object?> get props => [];
}

class UbahPasswordInitial extends UbahPasswordState {}

class UbahPasswordLoading extends UbahPasswordState {}

class UbahPasswordSuccess extends UbahPasswordState {
  final String message;

  const UbahPasswordSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class UbahPasswordError extends UbahPasswordState {
  final String message;

  const UbahPasswordError(this.message);

  @override
  List<Object?> get props => [message];
}
