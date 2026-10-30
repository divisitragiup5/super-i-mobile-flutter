import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event saat user menekan tombol login
class AuthLoginRequested extends AuthEvent {
  final String nip;
  final String password;

  const AuthLoginRequested({required this.nip, required this.password});

  @override
  List<Object?> get props => [nip, password];
}

/// Event saat aplikasi mengecek apakah sudah ada sesi login aktif
class AuthCheckRequested extends AuthEvent {}

/// Event saat user menekan tombol logout
class AuthLogoutRequested extends AuthEvent {}
