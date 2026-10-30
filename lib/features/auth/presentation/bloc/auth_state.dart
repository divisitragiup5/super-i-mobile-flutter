import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// State awal saat aplikasi pertama kali menyala
class AuthInitial extends AuthState {}

/// State saat request API sedang berlangsung (menampilkan loading)
class AuthLoading extends AuthState {}

/// State saat login berhasil dan data profil petugas sudah di tangan
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// State saat user belum login atau sesi telah berakhir
class AuthUnauthenticated extends AuthState {}

/// State saat terjadi kegagalan (password salah, server down, tidak ada sinyal)
class AuthFailureState extends AuthState {
  final String message;

  const AuthFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
