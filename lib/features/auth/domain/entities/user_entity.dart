import 'package:equatable/equatable.dart';

import '../../../../core/constants/role_constants.dart';

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

  /// Cek apakah user adalah personil Line Walker
  bool get isLineWalker {
    const lineWalkerRoles = [
      AppRoles.petugasLineWalker,
      AppRoles.koordinatorLineWalker,
      AppRoles.k3LineWalker,
      AppRoles.adminSuper,
    ];
    return roles.any((r) =>
        lineWalkerRoles.contains(r) ||
        r.toLowerCase().contains('line walker'));
  }

  /// Cek apakah user adalah personil OPGI
  bool get isOpgi {
    return roles.any((r) =>
        r.toLowerCase().contains('operator gi') ||
        r.toLowerCase().contains('koordinator gi') ||
        r.toLowerCase().contains('team leader gi') ||
        r.toLowerCase().contains('tim har'));
  }

  /// Cek apakah user adalah personil Distribusi
  bool get isDistribusi {
    return roles.any((r) =>
        r.toLowerCase().contains('sutm') ||
        r.toLowerCase().contains('yantek') ||
        r.toLowerCase().contains('distribusi'));
  }

  /// Hanya user Line Walker yang diizinkan mengakses tower Line Walker.
  /// User OPGI dan Distribusi tidak diizinkan.
  bool get canAccessLineWalkerTower {
    if (isOpgi || isDistribusi) return false;
    return isLineWalker;
  }

  @override
  List<Object?> get props => [id, namaLengkap, noTelepon, nip, roles, picture];
}