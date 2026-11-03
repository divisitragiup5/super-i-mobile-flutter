import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/sutm_workorder_model.dart';
import '../../data/models/yantek_asset_model.dart';

abstract class SutmRepository {
  Future<Either<Failure, List<SutmWorkOrderItem>>> getWorkOrderInspeksiToday(
      String date);
  Future<Either<Failure, List<SutmWorkOrderItem>>> getWorkOrderInspeksiList({
    int page = 1,
    int limit = 10,
    String? search,
  });
  Future<Either<Failure, SutmWorkOrderItem>> getWorkOrderInspeksiDetail(
      String workOrderId);
  Future<Either<Failure, Map<String, dynamic>>>
      getWorkOrderInspeksiRiwayatDetail(String workOrderSutmItemId);
  Future<Either<Failure, Map<String, dynamic>>> submitInspeksi(
      FormData formData);
  Future<Either<Failure, bool>> rejectSutmInspeksi({
    required String workOrderId,
    required List<int> itemIds,
    String? reason,
  });

  Future<Either<Failure, List<SutmWorkOrderItem>>> getValidasiWorkOrderList();
  Future<Either<Failure, List<SutmItemModel>>> getValidasiSutmList();
  Future<Either<Failure, bool>> approveInspeksi({
    required String role,
    required int id,
  });
  Future<Either<Failure, bool>> rejectInspeksi({
    required String role,
    required int id,
    required String reason,
  });
  Future<Either<Failure, bool>> approveBulkInspeksi({
    required String role,
    required List<int> inspeksiIds,
  });
  Future<Either<Failure, bool>> rejectBulkInspeksi({
    required String role,
    required List<int> inspeksiIds,
    required String reason,
  });

  Future<Either<Failure, List<SutmWorkOrderItem>>>
      getWorkOrderPemeliharaanToday(String date);
  Future<Either<Failure, List<SutmWorkOrderItem>>>
      getWorkOrderPemeliharaanList({
    int page = 1,
    int limit = 10,
  });
  Future<Either<Failure, SutmWorkOrderItem>> getWorkOrderPemeliharaanDetail(
      String workOrderId);
  Future<Either<Failure, Map<String, dynamic>>> submitPemeliharaan(
      FormData formData);
  Future<Either<Failure, bool>> rejectSutmPemeliharaan({
    required int workOrderId,
    required List<int> itemIds,
    String? reason,
  });

  Future<Either<Failure, List<YantekAssetModel>>> getYantekMapAssets(
      YantekFilterParams params);
  Future<Either<Failure, LastInspeksiModel?>> getLastInspeksiAsset(
      String assetId);

  Future<Either<Failure, Map<String, dynamic>>>
      getDistribusiPerformanceScoreToday(String type);
  Future<Either<Failure, Map<String, dynamic>>>
      getDistribusiPerformanceHistory({
    required String type,
    int? bulan,
    int? tahun,
  });
  Future<Either<Failure, Map<String, dynamic>>>
      getDistribusiPerformanceDetail({
    required String type,
    required String id,
  });
}
