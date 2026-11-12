import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Mengirim request login ke server, mengembalikan token JWT jika sukses.
  Future<Map<String, dynamic>> login({required String nip, required String password});

  /// Mengambil data profil user yang sedang login dari /data/user/me.
  Future<UserModel> getUserProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<Map<String, dynamic>> login({
    required String nip,
    required String password,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.login,
        data: {
          'nip': nip,
          'password': password,
          'withRefreshToken': true, // <--- TAMBAHKAN INI
        },
      );

      final data = response.data;
      if (data != null && data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }

      throw const ServerException(message: 'Format respon server tidak valid.');
    } on DioException catch (e) {
      throw dioClient.handleError(e);
    }
  }

  @override
  Future<UserModel> getUserProfile() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.userMe);
      final data = response.data;

      // Berdasarkan auth-context React Native: res.data.data adalah objek User
      if (data != null && data['data'] != null) {
        return UserModel.fromJson(data['data'] as Map<String, dynamic>);
      }

      throw const ServerException(message: 'Gagal memuat profil pengguna.');
    } on DioException catch (e) {
      throw dioClient.handleError(e);
    }
  }
}
