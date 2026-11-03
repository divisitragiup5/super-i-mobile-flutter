import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/line_walker_repository.dart';
import '../datasources/line_walker_remote_data_source.dart';
import '../models/kegiatan_sosial_model.dart';
import '../models/ketenagakerjaan_model.dart';
import '../models/pembumian_model.dart';
import '../models/ppl_model.dart';
import '../models/tower_asset_model.dart';
import '../models/waterpass_model.dart';

class LineWalkerRepositoryImpl implements LineWalkerRepository {
  final LineWalkerRemoteDataSource remoteDataSource;

  LineWalkerRepositoryImpl(this.remoteDataSource);

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
  Future<Either<Failure, List<TowerAssetModel>>> getTowers({String type = 'GANTRY,TOWER'}) async {
    try {
      final res = await remoteDataSource.getTowers(type: type);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(message: _extractError(e, 'Gagal memuat tower')));
    }
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
}
