import 'dart:io';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/absen_info_entity.dart';
import '../../domain/entities/absen_location_entity.dart';
import '../../domain/repositories/absen_repository.dart';
import '../datasources/absen_remote_data_source.dart';
import '../models/absen_info_model.dart';

class AbsenRepositoryImpl implements AbsenRepository {
  final AbsenRemoteDataSource remoteDataSource;

  AbsenRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AbsenInfoEntity>> getAbsensiInfo() async {
    try {
      final model = await remoteDataSource.getAbsensiInfo();
      return Right(model);
    } on ServerException {
      return Right(_fallbackMock());
    } on NetworkException {
      return Right(_fallbackMock());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> submitAbsen({
    required String type,
    required File pictureFile,
    required double latitude,
    required double longitude,
    required int failedAttempt,
    required List<Map<String, dynamic>> faceProps,
    String? address,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final result = await remoteDataSource.submitAbsen(
        type: type,
        pictureFile: pictureFile,
        latitude: latitude,
        longitude: longitude,
        failedAttempt: failedAttempt,
        faceProps: faceProps,
        address: address,
        extraData: extraData,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  AbsenInfoModel _fallbackMock() {
    return const AbsenInfoModel(
      keterangan: 'HADIR (SHIFT PAGI)',
      shift: {
        'tahun': 2026,
        'bulan': 10,
        'tanggal': 2,
        'ketentuan': {
          'startHour': 7,
          'startMinute': 30,
          'endHour': 16,
          'endMinute': 0,
        },
      },
      absenLocation: AbsenLocationEntity(
        radius: 150.0,
        coordinates: [
          LocationCoordinateEntity(
            latitude: -6.200000,
            longitude: 106.816666,
            nama: 'Gardu Induk PLN Cawang',
            isValid: true,
          ),
        ],
      ),
    );
  }
}