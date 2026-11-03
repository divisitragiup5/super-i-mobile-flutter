import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/history_penilaian_repository.dart';
import '../datasources/history_penilaian_remote_data_source.dart';
import '../models/history_penilaian_model.dart';

class HistoryPenilaianRepositoryImpl implements HistoryPenilaianRepository {
  final HistoryPenilaianRemoteDataSource remoteDataSource;

  HistoryPenilaianRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, NilaiBulananPaginationModel>> getNilaiBulanan({
    int? cursor,
  }) async {
    try {
      final result = await remoteDataSource.getNilaiBulanan(cursor: cursor);
      return Right(result);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'];
      return Left(ServerFailure(
        message: msg is List
            ? msg.join('\n')
            : (msg?.toString() ?? e.message ?? 'Gagal memuat nilai bulanan'),
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NilaiHarianItemModel>>> getNilaiHarian({
    required int bulan,
    required int tahun,
  }) async {
    try {
      final result = await remoteDataSource.getNilaiHarian(
        bulan: bulan,
        tahun: tahun,
      );
      return Right(result);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'];
      return Left(ServerFailure(
        message: msg is List
            ? msg.join('\n')
            : (msg?.toString() ?? e.message ?? 'Gagal memuat nilai harian'),
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GrafikBulananModel>> getGrafikBulanan({
    required int bulan,
    required int tahun,
  }) async {
    try {
      final result = await remoteDataSource.getGrafikBulanan(
        bulan: bulan,
        tahun: tahun,
      );
      return Right(result);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'];
      return Left(ServerFailure(
        message: msg is List
            ? msg.join('\n')
            : (msg?.toString() ?? e.message ?? 'Gagal memuat grafik bulanan'),
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
