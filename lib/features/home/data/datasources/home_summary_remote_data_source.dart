import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_time_utils.dart';
import '../models/opgi_score_today_model.dart';
import '../models/sutm_inspeksi_score_model.dart';
import '../models/sutm_pemeliharaan_score_model.dart';

abstract class HomeSummaryRemoteDataSource {
  Future<SutmInspeksiScoreModel> getSutmInspeksiScoreToday({String? timezone});
  Future<SutmPemeliharaanScoreModel> getSutmPemeliharaanScoreToday({
    String? timezone,
  });
  Future<OpgiScoreTodayModel?> getOpgiScoreToday({String? timezone});
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

  @override
  Future<OpgiScoreTodayModel?> getOpgiScoreToday({String? timezone}) async {
    try {
      final response = await dioClient.dio.get(
        '/gama/opgi-20kv/scoring/today',
        queryParameters: {
          'timezone': timezone ?? AppTimeUtils.deviceTimezone,
        },
      );

      final rawData = response.data['data'];
      if (rawData == null || (rawData is Map && rawData.isEmpty)) {
        return null;
      }
      if (rawData is Map<String, dynamic>) {
        return OpgiScoreTodayModel.fromJson(rawData);
      } else if (rawData is Map) {
        return OpgiScoreTodayModel.fromJson(Map<String, dynamic>.from(rawData));
      }
      return null;
    } on DioException catch (e) {
      throw dioClient.handleError(e);
    }
  }
}
