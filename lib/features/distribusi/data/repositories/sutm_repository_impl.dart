import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/sutm_repository.dart';
import '../datasources/sutm_remote_data_source.dart';
import '../models/sutm_workorder_model.dart';
import '../models/yantek_asset_model.dart';

class SutmRepositoryImpl implements SutmRepository {
  final SutmRemoteDataSource remoteDataSource;

  SutmRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SutmWorkOrderItem>>> getWorkOrderInspeksiToday(
      String date) async {
    try {
      final result = await remoteDataSource.getWorkOrderInspeksiToday(date);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SutmWorkOrderItem>>> getWorkOrderInspeksiList({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final result = await remoteDataSource.getWorkOrderInspeksiList(
        page: page,
        limit: limit,
        search: search,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SutmWorkOrderItem>> getWorkOrderInspeksiDetail(
      String workOrderId) async {
    try {
      final result =
          await remoteDataSource.getWorkOrderInspeksiDetail(workOrderId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
      getWorkOrderInspeksiRiwayatDetail(String workOrderSutmItemId) async {
    try {
      final result = await remoteDataSource
          .getWorkOrderInspeksiRiwayatDetail(workOrderSutmItemId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> submitInspeksi(
      FormData formData) async {
    try {
      final result = await remoteDataSource.submitInspeksi(formData);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> rejectSutmInspeksi({
    required String workOrderId,
    required List<int> itemIds,
    String? reason,
  }) async {
    try {
      final result = await remoteDataSource.rejectSutmInspeksi(
        workOrderId: workOrderId,
        itemIds: itemIds,
        reason: reason,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SutmWorkOrderItem>>>
      getValidasiWorkOrderList() async {
    try {
      final result = await remoteDataSource.getValidasiWorkOrderList();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SutmItemModel>>> getValidasiSutmList() async {
    try {
      final result = await remoteDataSource.getValidasiSutmList();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> approveInspeksi({
    required String role,
    required int id,
  }) async {
    try {
      final result =
          await remoteDataSource.approveInspeksi(role: role, id: id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> rejectInspeksi({
    required String role,
    required int id,
    required String reason,
  }) async {
    try {
      final result = await remoteDataSource.rejectInspeksi(
        role: role,
        id: id,
        reason: reason,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> approveBulkInspeksi({
    required String role,
    required List<int> inspeksiIds,
  }) async {
    try {
      final result = await remoteDataSource.approveBulkInspeksi(
        role: role,
        inspeksiIds: inspeksiIds,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> rejectBulkInspeksi({
    required String role,
    required List<int> inspeksiIds,
    required String reason,
  }) async {
    try {
      final result = await remoteDataSource.rejectBulkInspeksi(
        role: role,
        inspeksiIds: inspeksiIds,
        reason: reason,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SutmWorkOrderItem>>>
      getWorkOrderPemeliharaanToday(String date) async {
    try {
      final result =
          await remoteDataSource.getWorkOrderPemeliharaanToday(date);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SutmWorkOrderItem>>>
      getWorkOrderPemeliharaanList({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await remoteDataSource.getWorkOrderPemeliharaanList(
        page: page,
        limit: limit,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SutmWorkOrderItem>> getWorkOrderPemeliharaanDetail(
      String workOrderId) async {
    try {
      final result = await remoteDataSource
          .getWorkOrderPemeliharaanDetail(workOrderId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> submitPemeliharaan(
      FormData formData) async {
    try {
      final result = await remoteDataSource.submitPemeliharaan(formData);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> rejectSutmPemeliharaan({
    required int workOrderId,
    required List<int> itemIds,
    String? reason,
  }) async {
    try {
      final result = await remoteDataSource.rejectSutmPemeliharaan(
        workOrderId: workOrderId,
        itemIds: itemIds,
        reason: reason,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<YantekAssetModel>>> getYantekMapAssets(
      YantekFilterParams params) async {
    try {
      final result = await remoteDataSource.getYantekMapAssets(params);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LastInspeksiModel?>> getLastInspeksiAsset(
      String assetId) async {
    try {
      final result = await remoteDataSource.getLastInspeksiAsset(assetId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
      getDistribusiPerformanceScoreToday(String type) async {
    try {
      final result =
          await remoteDataSource.getDistribusiPerformanceScoreToday(type);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
      getDistribusiPerformanceHistory({
    required String type,
    int? bulan,
    int? tahun,
  }) async {
    try {
      final result = await remoteDataSource.getDistribusiPerformanceHistory(
        type: type,
        bulan: bulan,
        tahun: tahun,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
      getDistribusiPerformanceDetail({
    required String type,
    required String id,
  }) async {
    try {
      final result = await remoteDataSource.getDistribusiPerformanceDetail(
        type: type,
        id: id,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
