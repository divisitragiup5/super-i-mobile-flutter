import '../../../../core/network/dio_client.dart';
import '../models/history_penilaian_model.dart';

abstract class HistoryPenilaianRemoteDataSource {
  Future<NilaiBulananPaginationModel> getNilaiBulanan({int? cursor});
  Future<List<NilaiHarianItemModel>> getNilaiHarian({
    required int bulan,
    required int tahun,
  });
  Future<GrafikBulananModel> getGrafikBulanan({
    required int bulan,
    required int tahun,
  });
}

class HistoryPenilaianRemoteDataSourceImpl
    implements HistoryPenilaianRemoteDataSource {
  final DioClient _dioClient;

  HistoryPenilaianRemoteDataSourceImpl(this._dioClient);

  @override
  Future<NilaiBulananPaginationModel> getNilaiBulanan({int? cursor}) async {
    final Map<String, dynamic> query = {};
    if (cursor != null) {
      query['cursor'] = cursor;
    }

    final response = await _dioClient.dio.get(
      '/gama/opgi-20kv/operator-gi/opgi-optimization/nilai-bulanan',
      queryParameters: query,
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return NilaiBulananPaginationModel.fromJson(data);
  }

  @override
  Future<List<NilaiHarianItemModel>> getNilaiHarian({
    required int bulan,
    required int tahun,
  }) async {
    final response = await _dioClient.dio.get(
      '/gama/opgi-20kv/operator-gi/opgi-optimization/nilai-harian',
      queryParameters: {
        'bulan': bulan,
        'tahun': tahun,
      },
    );

    final List<dynamic> list = response.data['data'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => NilaiHarianItemModel.fromJson(e))
        .toList();
  }

  @override
  Future<GrafikBulananModel> getGrafikBulanan({
    required int bulan,
    required int tahun,
  }) async {
    final response = await _dioClient.dio.get(
      '/gama/opgi-20kv/operator-gi/opgi-optimization/grafik-bulanan',
      queryParameters: {
        'bulan': bulan,
        'tahun': tahun,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    return GrafikBulananModel.fromJson(data);
  }
}
