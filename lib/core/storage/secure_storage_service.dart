import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_constants.dart';

/// Layanan terpusat untuk menyimpan data sensitif secara terenkripsi di Keystore Android.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  /// Simpan Access Token JWT
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: StorageConstants.accessToken, value: token);
  }

  /// Ambil Access Token JWT
  Future<String?> getAccessToken() async {
    return await _storage.read(key: StorageConstants.accessToken);
  }

  /// Hapus Access Token saat Logout
  Future<void> deleteAccessToken() async {
    await _storage.delete(key: StorageConstants.accessToken);
  }

  /// Bersihkan seluruh data rahasia
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Simpan Refresh Token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: StorageConstants.refreshToken, value: token);
  }

  /// Ambil Refresh Token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageConstants.refreshToken);
  }

  /// Hapus Refresh Token
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: StorageConstants.refreshToken);
  }
}
