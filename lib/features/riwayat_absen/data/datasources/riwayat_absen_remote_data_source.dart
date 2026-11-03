import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/riwayat_absen_model.dart';

abstract class RiwayatAbsenRemoteDataSource {
  Future<RiwayatAbsenPaginationModel> getAbsenHistory({int? cursor});
  Future<String> uploadDokumen({
    required int riwayatId,
    required File file,
  });
}

class RiwayatAbsenRemoteDataSourceImpl implements RiwayatAbsenRemoteDataSource {
  final DioClient _dioClient;

  RiwayatAbsenRemoteDataSourceImpl(this._dioClient);

  @override
  Future<RiwayatAbsenPaginationModel> getAbsenHistory({int? cursor}) async {
    final Map<String, dynamic> queryParams = {};
    if (cursor != null) {
      queryParams['cursor'] = cursor;
    }

    final response = await _dioClient.dio.get(
      '/absensi/history',
      queryParameters: queryParams,
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return RiwayatAbsenPaginationModel.fromJson(data);
  }

  @override
  Future<String> uploadDokumen({
    required int riwayatId,
    required File file,
  }) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response = await _dioClient.dio.patch(
      '/absensi/upload-dokumen/$riwayatId',
      data: formData,
    );

    return response.data['message']?.toString() ??
        'Dokumen berhasil diunggah';
  }
}
