import '../../../../core/network/dio_client.dart';
import '../models/data_shift_model.dart';

abstract class DataShiftRemoteDataSource {
  Future<List<ShiftItemModel>> getDataShift({
    required int bulan,
    required int tahun,
  });

  Future<String> gantiJadwal({
    required int id,
    required int tanggal,
    required String timezone,
  });
}

class DataShiftRemoteDataSourceImpl implements DataShiftRemoteDataSource {
  final DioClient _dioClient;

  DataShiftRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ShiftItemModel>> getDataShift({
    required int bulan,
    required int tahun,
  }) async {
    final response = await _dioClient.dio.get(
      '/absensi/all/shift',
      queryParameters: {
        'bulan': bulan,
        'tahun': tahun,
      },
    );

    final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((e) => ShiftItemModel.fromJson(e))
        .toList();
  }

  @override
  Future<String> gantiJadwal({
    required int id,
    required int tanggal,
    required String timezone,
  }) async {
    final response = await _dioClient.dio.post(
      '/absensi/ganti-jadwal/$id',
      data: {
        'tanggal': tanggal,
        'timezone': timezone,
      },
    );

    return response.data['message']?.toString() ??
        'Jadwal shift berhasil diganti';
  }
}
