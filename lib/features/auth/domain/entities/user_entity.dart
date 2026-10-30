import 'package:equatable/equatable.dart';

/// Entity User murni yang merepresentasikan data petugas yang login.
class UserEntity extends Equatable {
  final int id;
  final String namaLengkap;
  final String noTelepon;
  final String nip;
  final List<String> roles;
  final String? picture;

  const UserEntity({
    required this.id,
    required this.namaLengkap,
    required this.noTelepon,
    required this.nip,
    required this.roles,
    this.picture,
  });

  /// Helper untuk mengecek apakah user memiliki role tertentu
  bool hasRole(String role) => roles.contains(role);

  @override
  List<Object?> get props => [id, namaLengkap, noTelepon, nip, roles, picture];
}