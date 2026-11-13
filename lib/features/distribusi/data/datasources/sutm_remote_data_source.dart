import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/sutm_workorder_model.dart';
import '../models/yantek_asset_model.dart';

abstract class SutmRemoteDataSource {
  // Inspeksi
  Future<List<SutmWorkOrderItem>> getWorkOrderInspeksiToday(String date);
  Future<List<SutmWorkOrderItem>> getWorkOrderInspeksiList({
    int page = 1,
    int limit = 10,
    String? search,
  });
  Future<SutmWorkOrderItem> getWorkOrderInspeksiDetail(String workOrderId);
  Future<Map<String, dynamic>> getWorkOrderInspeksiRiwayatDetail(
      String workOrderSutmItemId);
  Future<Map<String, dynamic>> submitInspeksi(FormData formData);
  Future<bool> rejectSutmInspeksi({
    required String workOrderId,
    required List<int> itemIds,
    String? reason,
  });

  // Validasi
  Future<List<SutmWorkOrderItem>> getValidasiWorkOrderList();
  Future<List<SutmItemModel>> getValidasiSutmList();
  Future<bool> approveInspeksi({
    required String role,
    required int id,
  });
  Future<bool> rejectInspeksi({
    required String role,
    required int id,
    required String reason,
  });
  Future<Map<String, dynamic>> validateInspeksi({
    required String role,
    required int id,
    required FormData formData,
  });
  Future<bool> approveBulkInspeksi({
    required String role,
    required List<int> inspeksiIds,
  });
  Future<bool> rejectBulkInspeksi({
    required String role,
    required List<int> inspeksiIds,
    required String reason,
  });

  // Pemeliharaan
  Future<List<SutmWorkOrderItem>> getWorkOrderPemeliharaanToday(String date);
  Future<List<SutmWorkOrderItem>> getWorkOrderPemeliharaanList({
    int page = 1,
    int limit = 10,
  });
  Future<SutmWorkOrderItem> getWorkOrderPemeliharaanDetail(String workOrderId);
  Future<Map<String, dynamic>> submitPemeliharaan(FormData formData);
  Future<bool> rejectSutmPemeliharaan({
    required int workOrderId,
    required List<int> itemIds,
    String? reason,
  });

  // Charts
  Future<List<dynamic>> getRiwayatInspeksiChart();
  Future<List<dynamic>> getRiwayatPemeliharaanChart();

  // Pemeliharaan Validation & Detail
  Future<Map<String, dynamic>> getRiwayatPemeliharaanDetail(
      String workOrderSutmItemId);
  Future<List<SutmWorkOrderItem>> getValidasiPemeliharaanWorkOrderList({
    String? search,
  });
  Future<List<SutmItemModel>> getValidasiPemeliharaanSutmList({
    String? search,
  });
  Future<bool> approvePemeliharaan({
    required String role,
    required int id,
  });
  Future<bool> rejectPemeliharaan({
    required String role,
    required int id,
    required String reason,
  });
  Future<bool> approveBulkPemeliharaan({
    required String role,
    required int workOrderId,
    List<int>? ids,
  });
  Future<bool> rejectBulkPemeliharaan({
    required String role,
    required int workOrderId,
    required String reason,
    List<int>? ids,
  });

  // Yantek
  Future<List<YantekAssetModel>> getYantekMapAssets(YantekFilterParams params);
  Future<LastInspeksiModel?> getLastInspeksiAsset(String assetId);

  // Performa / Riwayat Penilaian
  Future<Map<String, dynamic>> getDistribusiPerformanceScoreToday(String type);
  Future<Map<String, dynamic>> getDistribusiPerformanceHistory({
    required String type,
    int? bulan,
    int? tahun,
  });
  Future<Map<String, dynamic>> getDistribusiPerformanceDetail({
    required String type,
    required String id,
  });
  Future<Map<String, dynamic>> getPenilaianHistory({
    required String type,
    int? cursor,
    int? bulan,
    int? tahun,
  });
  Future<Map<String, dynamic>> getPenilaianDetailHistory({
    required String type,
    required String timeSet,
    int? bulan,
    int? tahun,
  });
  Future<Map<String, dynamic>> getPenilaianDetailChart({
    required String type,
    required String timeSet,
    int? bulan,
    int? tahun,
  });
}

class SutmRemoteDataSourceImpl implements SutmRemoteDataSource {
  final DioClient apiClient;

  SutmRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<SutmWorkOrderItem>> getWorkOrderInspeksiToday(String date) async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/wo-inspeksi/petugas/mobile/today',
        queryParameters: {'date': date},
      );
      final rawData = response.data;
      final List<dynamic> items =
          rawData is List ? rawData : (rawData['data'] as List? ?? []);
      return items
          .map((item) =>
              SutmWorkOrderItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Gagal mengambil penugasan inspeksi hari ini: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<SutmWorkOrderItem>> getWorkOrderInspeksiList({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/wo-inspeksi/mobile/list',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      final rawData = response.data;
      final List<dynamic> items =
          rawData is List ? rawData : (rawData['data'] as List? ?? []);
      return items
          .map((item) =>
              SutmWorkOrderItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Gagal mengambil daftar work order: ${e.toString()}',
      );
    }
  }

  @override
  Future<SutmWorkOrderItem> getWorkOrderInspeksiDetail(
      String workOrderId) async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/wo-inspeksi/mobile/sutm',
        queryParameters: {'workOrderId': workOrderId},
      );
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {'items': response.data};
      return SutmWorkOrderItem.fromJson(data);
    } catch (e) {
      throw ServerException(
        message: 'Gagal mengambil detail work order: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getWorkOrderInspeksiRiwayatDetail(
      String workOrderSutmItemId) async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/wo-inspeksi/mobile/riwayat/$workOrderSutmItemId',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ServerException(
        message: 'Gagal mengambil riwayat inspeksi: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> submitInspeksi(FormData formData) async {
    try {
      final response = await apiClient.post(
        '/gama/distribusi/max/inspeksi',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ServerException(
        message: 'Gagal mengirim formulir inspeksi: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> rejectSutmInspeksi({
    required String workOrderId,
    required List<int> itemIds,
    String? reason,
  }) async {
    try {
      await apiClient.post(
        '/gama/distribusi/max/wo-inspeksi/petugas/mobile/$workOrderId/reject',
        data: {
          'itemIds': itemIds,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
      return true;
    } catch (e) {
      throw ServerException(
        message: 'Gagal menolak item SUTM: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<SutmWorkOrderItem>> getValidasiWorkOrderList() async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/wo-inspeksi/mobile/validasi/wo',
      );
      final rawData = response.data;
      final List<dynamic> items =
          rawData is List ? rawData : (rawData['data'] as List? ?? []);
      return items
          .map((item) =>
              SutmWorkOrderItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Gagal mengambil data validasi work order: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<SutmItemModel>> getValidasiSutmList() async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/wo-inspeksi/mobile/validasi/sutm',
      );
      final rawData = response.data;
      final List<dynamic> items =
          rawData is List ? rawData : (rawData['data'] as List? ?? []);
      return items
          .map((item) => SutmItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Gagal mengambil data validasi SUTM: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> approveInspeksi({
    required String role,
    required int id,
  }) async {
    try {
      await apiClient.patch(
        '/gama/distribusi/max/inspeksi/$role/$id/approve',
      );
      return true;
    } catch (e) {
      throw ServerException(
        message: 'Gagal menyetujui inspeksi: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> rejectInspeksi({
    required String role,
    required int id,
    required String reason,
  }) async {
    try {
      await apiClient.patch(
        '/gama/distribusi/max/inspeksi/$role/$id/reject',
        data: {'reason': reason},
      );
      return true;
    } catch (e) {
      throw ServerException(
        message: 'Gagal menolak inspeksi: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> validateInspeksi({
    required String role,
    required int id,
    required FormData formData,
  }) async {
    try {
      final response = await apiClient.post(
        '/gama/distribusi/max/inspeksi/$role/$id/validate',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ServerException(
        message: 'Gagal mengirim validasi inspeksi: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> approveBulkInspeksi({
    required String role,
    required List<int> inspeksiIds,
  }) async {
    try {
      await apiClient.patch(
        '/gama/distribusi/max/inspeksi/$role/approve',
        data: {'inspeksiIds': inspeksiIds},
      );
      return true;
    } catch (e) {
      throw ServerException(
        message: 'Gagal menyetujui inspeksi secara massal: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> rejectBulkInspeksi({
    required String role,
    required List<int> inspeksiIds,
    required String reason,
  }) async {
    try {
      await apiClient.patch(
        '/gama/distribusi/max/inspeksi/$role/reject',
        data: {
          'inspeksiIds': inspeksiIds,
          'reason': reason,
        },
      );
      return true;
    } catch (e) {
      throw ServerException(
        message: 'Gagal menolak inspeksi secara massal: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<SutmWorkOrderItem>> getWorkOrderPemeliharaanToday(
      String date) async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/wo-pemeliharaan/petugas/mobile/today',
        queryParameters: {'date': date},
      );
      final rawData = response.data;
      final List<dynamic> items =
          rawData is List ? rawData : (rawData['data'] as List? ?? []);
      return items
          .map((item) =>
              SutmWorkOrderItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(
        message:
            'Gagal mengambil penugasan pemeliharaan hari ini: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<SutmWorkOrderItem>> getWorkOrderPemeliharaanList({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/wo-pemeliharaan/mobile/list',
        queryParameters: {'page': page, 'limit': limit},
      );
      final rawData = response.data;
      final List<dynamic> items =
          rawData is List ? rawData : (rawData['data'] as List? ?? []);
      return items
          .map((item) =>
              SutmWorkOrderItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(
        message:
            'Gagal mengambil daftar workorder pemeliharaan: ${e.toString()}',
      );
    }
  }

  @override
  Future<SutmWorkOrderItem> getWorkOrderPemeliharaanDetail(
      String workOrderId) async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/wo-pemeliharaan/mobile/sutm',
        queryParameters: {'workOrderId': workOrderId},
      );
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {'items': response.data};
      return SutmWorkOrderItem.fromJson(data);
    } catch (e) {
      throw ServerException(
        message: 'Gagal mengambil detail pemeliharaan: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> submitPemeliharaan(FormData formData) async {
    try {
      final response = await apiClient.post(
        '/gama/distribusi/max/pemeliharaan',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ServerException(
        message: 'Gagal mengirim data pemeliharaan: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> rejectSutmPemeliharaan({
    required int workOrderId,
    required List<int> itemIds,
    String? reason,
  }) async {
    try {
      await apiClient.post(
        '/gama/distribusi/max/wo-pemeliharaan/petugas/mobile/$workOrderId/reject',
        data: {
          'itemIds': itemIds,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
      return true;
    } catch (e) {
      throw ServerException(
        message: 'Gagal menolak item pemeliharaan: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<YantekAssetModel>> getYantekMapAssets(
      YantekFilterParams params) async {
    try {
      final response = await apiClient.get(
        '/data/asset/distribusi/sutm',
        queryParameters: params.toQueryParams(),
      );
      final rawData = response.data;
      final List<dynamic> items =
          rawData is List ? rawData : (rawData['data']?['items'] as List? ?? []);
      return items
          .map((item) =>
              YantekAssetModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Gagal mengambil aset peta Yantek: ${e.toString()}',
      );
    }
  }

  @override
  Future<LastInspeksiModel?> getLastInspeksiAsset(String assetId) async {
    try {
      final response = await apiClient.get(
        '/data/asset/distribusi/sutm/$assetId/last-inspeksi',
      );
      final raw = response.data;
      final map = raw is Map<String, dynamic>
          ? (raw['data']?['lastInspeksi'] ?? raw['lastInspeksi'] ?? raw)
          : null;
      if (map != null && map is Map<String, dynamic>) {
        return LastInspeksiModel.fromJson(map);
      }
      return null;
    } catch (e) {
      throw ServerException(
        message: 'Gagal mengambil inspeksi terakhir aset: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getDistribusiPerformanceScoreToday(
      String type) async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/performa-$type/petugas/mobile/score/today',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ServerException(
        message: 'Gagal mengambil performa hari ini: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getDistribusiPerformanceHistory({
    required String type,
    int? bulan,
    int? tahun,
  }) async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/performa-$type/petugas/mobile/score/history',
        queryParameters: {
          'bulan': ?bulan,
          'tahun': ?tahun,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ServerException(
        message: 'Gagal mengambil riwayat penilaian performa: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getDistribusiPerformanceDetail({
    required String type,
    required String id,
  }) async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/performa-$type/petugas/mobile/score/history/detail',
        queryParameters: {'id': id},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ServerException(
        message: 'Gagal mengambil detail penilaian performa: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<dynamic>> getRiwayatInspeksiChart() async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/wo-inspeksi/mobile/riwayat/chart',
      );
      final data = response.data;
      return data is Map
          ? (data['data'] as List? ?? [])
          : (data is List ? data : []);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<dynamic>> getRiwayatPemeliharaanChart() async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/wo-pemeliharaan/mobile/riwayat/chart',
      );
      final data = response.data;
      return data is Map
          ? (data['data'] as List? ?? [])
          : (data is List ? data : []);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getRiwayatPemeliharaanDetail(
      String workOrderSutmItemId) async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/wo-pemeliharaan/mobile/riwayat/$workOrderSutmItemId',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ServerException(
        message: 'Gagal mengambil detail pemeliharaan: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<SutmWorkOrderItem>> getValidasiPemeliharaanWorkOrderList({
    String? search,
  }) async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/wo-pemeliharaan/mobile/list',
        queryParameters: {
          'status': 'ON_PROGRESS',
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      final rawData = response.data;
      final List<dynamic> items = rawData is List
          ? rawData
          : (rawData['data']?['items'] as List? ??
              rawData['data'] as List? ??
              []);
      return items
          .map((item) =>
              SutmWorkOrderItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(
        message:
            'Gagal mengambil daftar validasi WO pemeliharaan: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<SutmItemModel>> getValidasiPemeliharaanSutmList({
    String? search,
  }) async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/wo-pemeliharaan/mobile/sutm',
        queryParameters: {
          'status': 'ON_PROGRESS',
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      final rawData = response.data;
      final List<dynamic> items = rawData is List
          ? rawData
          : (rawData['data']?['items'] as List? ??
              rawData['data'] as List? ??
              []);
      return items
          .map((item) => SutmItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(
        message:
            'Gagal mengambil daftar validasi SUTM pemeliharaan: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> approvePemeliharaan({
    required String role,
    required int id,
  }) async {
    try {
      await apiClient.patch(
        '/gama/distribusi/max/pemeliharaan/$role/$id/approve',
      );
      return true;
    } catch (e) {
      throw ServerException(
        message: 'Gagal menyetujui pemeliharaan: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> rejectPemeliharaan({
    required String role,
    required int id,
    required String reason,
  }) async {
    try {
      await apiClient.patch(
        '/gama/distribusi/max/pemeliharaan/$role/$id/reject',
        data: {'reason': reason},
      );
      return true;
    } catch (e) {
      throw ServerException(
        message: 'Gagal menolak pemeliharaan: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> approveBulkPemeliharaan({
    required String role,
    required int workOrderId,
    List<int>? ids,
  }) async {
    try {
      await apiClient.patch(
        '/gama/distribusi/max/pemeliharaan/$role/approve',
        data: {
          'workOrderId': workOrderId,
          if (ids != null && ids.isNotEmpty) 'ids': ids,
        },
      );
      return true;
    } catch (e) {
      throw ServerException(
        message: 'Gagal menyetujui massal pemeliharaan: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> rejectBulkPemeliharaan({
    required String role,
    required int workOrderId,
    required String reason,
    List<int>? ids,
  }) async {
    try {
      await apiClient.patch(
        '/gama/distribusi/max/pemeliharaan/$role/reject',
        data: {
          'workOrderId': workOrderId,
          'reason': reason,
          if (ids != null && ids.isNotEmpty) 'ids': ids,
        },
      );
      return true;
    } catch (e) {
      throw ServerException(
        message: 'Gagal menolak massal pemeliharaan: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getPenilaianHistory({
    required String type,
    int? cursor,
    int? bulan,
    int? tahun,
  }) async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/performa-$type/petugas/mobile/score/history',
        queryParameters: {
          'cursor': ?cursor,
          'bulan': ?bulan,
          'tahun': ?tahun,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ServerException(
        message: 'Gagal mengambil riwayat penilaian: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getPenilaianDetailHistory({
    required String type,
    required String timeSet,
    int? bulan,
    int? tahun,
  }) async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/performa-$type/petugas/mobile/score/history/detail',
        queryParameters: {
          'timeSet': timeSet,
          'bulan': ?bulan,
          'tahun': ?tahun,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ServerException(
        message: 'Gagal mengambil detail riwayat penilaian: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getPenilaianDetailChart({
    required String type,
    required String timeSet,
    int? bulan,
    int? tahun,
  }) async {
    try {
      final response = await apiClient.get(
        '/gama/distribusi/max/performa-$type/petugas/mobile/score/history/detail-chart',
        queryParameters: {
          'timeSet': timeSet,
          'bulan': ?bulan,
          'tahun': ?tahun,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ServerException(
        message: 'Gagal mengambil detail chart penilaian: ${e.toString()}',
      );
    }
  }
}
