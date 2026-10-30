import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/sutm_inspeksi_score_model.dart';
import '../models/sutm_pemeliharaan_score_model.dart';

abstract class HomeSummaryRemoteDataSource {
  Future<SutmInspeksiScoreModel> getSutmInspeksiScoreToday({String? timezone});
  Future<SutmPemeliharaanScoreModel> getSutmPemeliharaanScoreToday({
    String? timezone,
  });
}

class HomeSummaryRemoteDataSourceImpl implements HomeSummaryRemoteDataSource {
  final DioClient dioClient;

  HomeSummaryRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<SutmInspeksiScoreModel> getSutmInspeksiScoreToday({
    String? timezone,
  }) async {
    try {
      final response = await dioClient.dio.get(
        '/gama/distribusi/max/performa-inspeksi/petugas/mobile/score/today',
        queryParameters: {
          'timezone': timezone ?? 'Asia/Jakarta',
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return SutmInspeksiScoreModel.fromJson(data);
    } on DioException catch (e) {
      throw dioClient.handleError(e);
    }
  }

  @override
  Future<SutmPemeliharaanScoreModel> getSutmPemeliharaanScoreToday({
    String? timezone,
  }) async {
    try {
      final response = await dioClient.dio.get(
        '/gama/distribusi/max/performa-pemeliharaan/petugas/mobile/score/today',
        queryParameters: {
          'timezone': timezone ?? 'Asia/Jakarta',
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return SutmPemeliharaanScoreModel.fromJson(data);
    } on DioException catch (e) {
      throw dioClient.handleError(e);
    }
  }
}
