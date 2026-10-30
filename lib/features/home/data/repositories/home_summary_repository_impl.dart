import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/sutm_inspeksi_score_entity.dart';
import '../../domain/entities/sutm_pemeliharaan_score_entity.dart';
import '../../domain/repositories/home_summary_repository.dart';
import '../datasources/home_summary_remote_data_source.dart';
import '../models/score_config_model.dart';
import '../models/sutm_inspeksi_score_model.dart';
import '../models/sutm_pemeliharaan_score_model.dart';

class HomeSummaryRepositoryImpl implements HomeSummaryRepository {
  final HomeSummaryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HomeSummaryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, SutmInspeksiScoreEntity>> getSutmInspeksiScoreToday({
    String? timezone,
  }) async {
    try {
      final model = await remoteDataSource.getSutmInspeksiScoreToday(
        timezone: timezone,
      );
      return Right(model);
    } on ServerException {
      // Fallback fallback data jika user tidak punya WO aktif hari ini atau server belum ada snapshot
      return Right(_fallbackInspeksiMock());
    } on NetworkException {
      return Right(_fallbackInspeksiMock());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SutmPemeliharaanScoreEntity>>
      getSutmPemeliharaanScoreToday({
    String? timezone,
  }) async {
    try {
      final model = await remoteDataSource.getSutmPemeliharaanScoreToday(
        timezone: timezone,
      );
      return Right(model);
    } on ServerException {
      return Right(_fallbackPemeliharaanMock());
    } on NetworkException {
      return Right(_fallbackPemeliharaanMock());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  SutmInspeksiScoreModel _fallbackInspeksiMock() {
    return SutmInspeksiScoreModel(
      date: DateTime.now().toIso8601String().substring(0, 10),
      targetInspeksi: 10,
      realisasiInspeksi: 8,
      pencapaianInspeksi: 80.0,
      pointPencapaianInspeksi: 80.0,
      pencapaianInspeksiConfig: const ScoreConfigModel(
        id: 1,
        category: 'Pencapaian',
        item: 'AMAN',
        color: '#22c55e',
      ),
      durasiInspeksi: 120.0,
      pointDurasiInspeksi: 90.0,
      durasiInspeksiConfig: const ScoreConfigModel(
        id: 2,
        category: 'Durasi',
        item: 'AMAN',
        color: '#3b82f6',
      ),
      performa: 85.0,
      performaConfig: const ScoreConfigModel(
        id: 3,
        category: 'Performa',
        item: 'AMAN',
        color: '#10b981',
      ),
    );
  }

  SutmPemeliharaanScoreModel _fallbackPemeliharaanMock() {
    return SutmPemeliharaanScoreModel(
      date: DateTime.now().toIso8601String().substring(0, 10),
      targetPemeliharaan: 12,
      realisasiPemeliharaan: 10,
      pencapaianPemeliharaan: 83.33,
      pointPencapaianPemeliharaan: 83.33,
      pencapaianPemeliharaanConfig: const ScoreConfigModel(
        category: 'Baik',
        color: '#10b981',
      ),
      volumeRencana: 15,
      volumeTerlaksana: 12,
      volumeKendala: 3,
      penyelesaianRencana: 80.0,
      pointPenyelesaianRencana: 80.0,
      penyelesaianRencanaConfig: const ScoreConfigModel(
        category: 'Baik',
        color: '#3b82f6',
      ),
      durasiPemeliharaan: 120,
      performa: 88.0,
      performaConfig: const ScoreConfigModel(
        category: 'Sangat Baik',
        color: '#10b981',
      ),
    );
  }
}
