import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/preferences_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/repositories/line_walker_repository.dart';
import '../datasources/line_walker_remote_data_source.dart';
import '../models/kegiatan_sosial_model.dart';
import '../models/ketenagakerjaan_model.dart';
import '../models/line_walker_performance_model.dart';
import '../models/pembumian_model.dart';
import '../models/ppl_model.dart';
import '../models/tower_asset_model.dart';
import '../models/waterpass_model.dart';
import 'package:super_i_mobile/features/home/data/models/ppl_condition_summary_model.dart';

class LineWalkerRepositoryImpl implements LineWalkerRepository {
  final LineWalkerRemoteDataSource remoteDataSource;
  final PreferencesService? preferencesService;

  LineWalkerRepositoryImpl(this.remoteDataSource, [this.preferencesService]);

  bool _canAccessTower() {
    if (preferencesService == null) return true;
    final userJson = preferencesService!.getString(StorageConstants.userProfile);
    if (userJson == null) return true;
    try {
      final user = UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      return user.canAccessLineWalkerTower;
    } catch (_) {
      return true;
    }
  }

  String _extractError(dynamic e, String defaultMessage) {
    if (e is DioException) {
      final msg = e.response?.data?['message'];
      if (msg is List) return msg.join('\n');
      if (msg != null) return msg.toString();
      return e.message ?? defaultMessage;
    }
    return e.toString();
  }

  @override
  Future<Either<Failure, LineWalkerPerformanceModel?>> getMyPerformance({
    int? minggu,
    String? bulan,
    int? tahun,
  }) async {
    try {
      final res = await remoteDataSource.getMyPerformance(
        minggu: minggu,
        bulan: bulan,
        tahun: tahun,
      );
      return Right(res);
    } catch (e) {
      return Left(
        ServerFailure(message: _extractError(e, 'Gagal memuat kinerja Line Walker')),
      );
    }
  }

  @override
  Future<Either<Failure, List<TowerAssetModel>>> getTowers({String type = 'GANTRY,TOWER'}) async {
    if (!_canAccessTower()) {
      return const Right([]);
    }
    try {
      final res = await remoteDataSource.getTowers(type: type);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal memuat tower')));
    }
  }

  @override
  Future<void> prefetchTowers() async {
    if (!_canAccessTower()) {
      return;
    }
    try {
      await Future.wait([
        remoteDataSource.getTowers(type: 'GANTRY,TOWER'),
        remoteDataSource.getTowers(type: 'JOINT,SPAN'),
      ]);
    } catch (_) {}
  }

  // --- Waterpass ---
  @override
  Future<Either<Failure, String>> submitWaterpass(WaterpassInputModel input) async {
    try {
      final res = await remoteDataSource.submitWaterpass(input);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal menyimpan data waterpass')));
    }
  }

  @override
  Future<Either<Failure, WaterpassDetailModel?>> getLastWaterpass(int towerId) async {
    try {
      final res = await remoteDataSource.getLastWaterpass(towerId);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal memuat riwayat terakhir waterpass')));
    }
  }

  // --- Pembumian ---
  @override
  Future<Either<Failure, String>> submitPembumian(PembumianInputModel input) async {
    try {
      final res = await remoteDataSource.submitPembumian(input);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal menyimpan data pembumian')));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> getLastPembumian(int towerId) async {
    try {
      final res = await remoteDataSource.getLastPembumian(towerId);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal memuat riwayat terakhir pembumian')));
    }
  }

  @override
  Future<Either<Failure, List<PembumianHistoryItemModel>>> getPembumianHistory({int cursor = 0, String? search}) async {
    try {
      final res = await remoteDataSource.getPembumianHistory(cursor: cursor, search: search);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal memuat riwayat pembumian')));
    }
  }

  // --- PPL ---
  @override
  Future<Either<Failure, String>> submitPpl(PPLInputModel input) async {
    try {
      final res = await remoteDataSource.submitPpl(input);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal menyimpan data PPL')));
    }
  }

  @override
  Future<Either<Failure, String>> updatePpl({required int id, File? ttdTLGI, String? namaTTDTLGI}) async {
    try {
      final res = await remoteDataSource.updatePpl(id: id, ttdTLGI: ttdTLGI, namaTTDTLGI: namaTTDTLGI);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal memperbarui data PPL')));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> getLastPpl(int towerId) async {
    try {
      final res = await remoteDataSource.getLastPpl(towerId);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal memuat data terakhir PPL')));
    }
  }

  @override
  Future<Either<Failure, List<PPLHistoryItemModel>>> getPplHistory({int cursor = 0, String? search, String? type}) async {
    try {
      final res = await remoteDataSource.getPplHistory(cursor: cursor, search: search, type: type);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal memuat riwayat PPL')));
    }
  }

  @override
  Future<Either<Failure, List<PPLHistoryItemModel>>> getPplHistoryByIdentifier(String identifier, {int cursor = 0}) async {
    try {
      final res = await remoteDataSource.getPplHistoryByIdentifier(identifier, cursor: cursor);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal memuat daftar pembaruan PPL')));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSummaryRiwayatPpl() async {
    try {
      final res = await remoteDataSource.getSummaryRiwayatPpl();
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal memuat rekap riwayat PPL')));
    }
  }

  @override
  Future<Either<Failure, PplConditionSummaryModel>> getPplConditionSummary() async {
    try {
      final res = await remoteDataSource.getPplConditionSummary();
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal memuat ringkasan kondisi PPL')));
    }
  }

  // --- Ketenagakerjaan ---
  @override
  Future<Either<Failure, List<KetenagakerjaanItemModel>>> getSummaryKetenagakerjaan({int cursor = 0, String? search}) async {
    try {
      final res = await remoteDataSource.getSummaryKetenagakerjaan(cursor: cursor, search: search);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal memuat ringkasan ketenagakerjaan')));
    }
  }

  @override
  Future<Either<Failure, List<KetenagakerjaanItemModel>>> getKetenagakerjaanDetail(int id, {int cursor = 0, String? timezone}) async {
    try {
      final res = await remoteDataSource.getKetenagakerjaanDetail(id, cursor: cursor, timezone: timezone);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal memuat rincian ketenagakerjaan')));
    }
  }

  @override
  Future<Either<Failure, String>> downloadSuratKetenagakerjaan({
    required int id,
    required int minggu,
    required String bulan,
    required int tahun,
    required String status,
  }) async {
    try {
      final res = await remoteDataSource.downloadSuratKetenagakerjaan(
        id: id,
        minggu: minggu,
        bulan: bulan,
        tahun: tahun,
        status: status,
      );
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal mengunduh surat ketenagakerjaan')));
    }
  }

  // --- Kegiatan Sosial ---
  @override
  Future<Either<Failure, String>> submitKegiatanSosial(KegiatanSosialInputModel input) async {
    try {
      final res = await remoteDataSource.submitKegiatanSosial(input);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal menyimpan kegiatan sosial')));
    }
  }

  @override
  Future<Either<Failure, String>> updateKegiatanSosial({
    required int id,
    File? ttdTLGI,
    String? namaTTDTLGI,
    File? ttdLineWalker,
    String? namaTTDLineWalker,
  }) async {
    try {
      final res = await remoteDataSource.updateKegiatanSosial(
        id: id,
        ttdTLGI: ttdTLGI,
        namaTTDTLGI: namaTTDTLGI,
        ttdLineWalker: ttdLineWalker,
        namaTTDLineWalker: namaTTDLineWalker,
      );
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal memperbarui kegiatan sosial')));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> getLastKegiatanSosial(int towerId) async {
    try {
      final res = await remoteDataSource.getLastKegiatanSosial(towerId);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal memuat riwayat terakhir kegiatan sosial')));
    }
  }

  @override
  Future<Either<Failure, List<KegiatanSosialHistoryItemModel>>> getKegiatanSosialHistory({int cursor = 0, String? search}) async {
    try {
      final res = await remoteDataSource.getKegiatanSosialHistory(cursor: cursor, search: search);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal memuat riwayat kegiatan sosial')));
    }
  }

  @override
  Future<Either<Failure, List<KegiatanSosialHistoryItemModel>>> getKegiatanSosialHistoryByIdentifier(String identifier, {int cursor = 0}) async {
    try {
      final res = await remoteDataSource.getKegiatanSosialHistoryByIdentifier(identifier, cursor: cursor);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal memuat rincian riwayat kegiatan sosial')));
    }
  }

  @override
  Future<Either<Failure, String>> downloadBAPembumian({
    required int towerId,
    required int inspectionId,
    required String towerName,
  }) async {
    try {
      final res = await remoteDataSource.downloadBAPembumian(
        towerId: towerId,
        inspectionId: inspectionId,
        towerName: towerName,
      );
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal mengunduh Berita Acara Pembumian')));
    }
  }

  @override
  Future<Either<Failure, String>> downloadBAPPL({
    required int inspectionId,
    required String towerName,
  }) async {
    try {
      final res = await remoteDataSource.downloadBAPPL(
        inspectionId: inspectionId,
        towerName: towerName,
      );
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal mengunduh Berita Acara PPL')));
    }
  }

  @override
  Future<Either<Failure, String>> downloadBAKegiatanSosial({
    required int inspectionId,
    required String towerName,
  }) async {
    try {
      final res = await remoteDataSource.downloadBAKegiatanSosial(
        inspectionId: inspectionId,
        towerName: towerName,
      );
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal mengunduh Berita Acara Kegiatan Sosial')));
    }
  }
}

