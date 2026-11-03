import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/riwayat_absen_repository.dart';
import '../datasources/riwayat_absen_remote_data_source.dart';
import '../models/riwayat_absen_model.dart';

class RiwayatAbsenRepositoryImpl implements RiwayatAbsenRepository {
  final RiwayatAbsenRemoteDataSource remoteDataSource;

  RiwayatAbsenRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, RiwayatAbsenPaginationModel>> getAbsenHistory({
    int? cursor,
  }) async {
    try {
      final result = await remoteDataSource.getAbsenHistory(cursor: cursor);
      return Right(result);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'];
      return Left(ServerFailure(
        message: msg is List
            ? msg.join('\n')
            : (msg?.toString() ?? e.message ?? 'Gagal memuat riwayat absen'),
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadDokumen({
    required int riwayatId,
    required File file,
  }) async {
    try {
      final result = await remoteDataSource.uploadDokumen(
        riwayatId: riwayatId,
        file: file,
      );
      return Right(result);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'];
      return Left(ServerFailure(
        message: msg is List
            ? msg.join('\n')
            : (msg?.toString() ?? e.message ?? 'Gagal mengunggah dokumen'),
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
