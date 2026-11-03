import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/data_shift_repository.dart';
import '../datasources/data_shift_remote_data_source.dart';
import '../models/data_shift_model.dart';

class DataShiftRepositoryImpl implements DataShiftRepository {
  final DataShiftRemoteDataSource remoteDataSource;

  DataShiftRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ShiftItemModel>>> getDataShift({
    required int bulan,
    required int tahun,
  }) async {
    try {
      final result = await remoteDataSource.getDataShift(
        bulan: bulan,
        tahun: tahun,
      );
      return Right(result);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'];
      return Left(ServerFailure(
        message: msg is List
            ? msg.join('\n')
            : (msg?.toString() ?? e.message ?? 'Gagal memuat data shift'),
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> gantiJadwal({
    required int id,
    required int tanggal,
    required String timezone,
  }) async {
    try {
      final result = await remoteDataSource.gantiJadwal(
        id: id,
        tanggal: tanggal,
        timezone: timezone,
      );
      return Right(result);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'];
      return Left(ServerFailure(
        message: msg is List
            ? msg.join('\n')
            : (msg?.toString() ?? e.message ?? 'Gagal mengganti jadwal shift'),
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
