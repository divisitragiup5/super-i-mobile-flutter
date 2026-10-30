import '../../domain/entities/user_entity.dart';

/// Model User yang bertugas mengonversi respon JSON dari API backend ke objek Dart.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.namaLengkap,
    required super.noTelepon,
    required super.nip,
    required super.roles,
    super.picture,
  });

  /// Factory constructor untuk mem-parsing data JSON dari server secara aman (null-safe)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      namaLengkap: json['namaLengkap'] as String? ?? json['nama_lengkap'] as String? ?? '',
      noTelepon: json['noTelepon'] as String? ?? json['no_telepon'] as String? ?? '',
      nip: json['nip'] as String? ?? '',
      roles: (json['roles'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      picture: json['picture'] as String?,
    );
  }

  /// Mengonversi objek kembali ke JSON jika dibutuhkan
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaLengkap': namaLengkap,
      'noTelepon': noTelepon,
      'nip': nip,
      'roles': roles,
      'picture': picture,
    };
  }
}