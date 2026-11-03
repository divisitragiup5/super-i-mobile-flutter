import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

abstract class UbahPasswordRemoteDataSource {
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class UbahPasswordRemoteDataSourceImpl implements UbahPasswordRemoteDataSource {
  final DioClient dioClient;

  UbahPasswordRemoteDataSourceImpl(this.dioClient);

  @override
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await dioClient.dio.patch(
        ApiConstants.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ?? 'Password berhasil diubah';
      }
      return 'Password berhasil diubah';
    } on DioException catch (e) {
      throw dioClient.handleError(e);
    }
  }
}
