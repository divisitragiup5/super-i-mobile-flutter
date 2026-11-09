import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/kegiatan_sosial_model.dart';
import '../../data/models/ketenagakerjaan_model.dart';
import '../../data/models/line_walker_performance_model.dart';
import '../../data/models/pembumian_model.dart';
import '../../data/models/ppl_model.dart';
import '../../data/models/tower_asset_model.dart';
import '../../data/models/waterpass_model.dart';
import 'package:super_i_mobile/features/home/data/models/ppl_condition_summary_model.dart';

abstract class LineWalkerRepository {
  Future<Either<Failure, LineWalkerPerformanceModel?>> getMyPerformance({
    int? minggu,
    String? bulan,
    int? tahun,
  });

  Future<Either<Failure, List<TowerAssetModel>>> getTowers({String type = 'GANTRY,TOWER'});
  Future<void> prefetchTowers();

  // Waterpass
  Future<Either<Failure, String>> submitWaterpass(WaterpassInputModel input);
  Future<Either<Failure, WaterpassDetailModel?>> getLastWaterpass(int towerId);

  // Pembumian
  Future<Either<Failure, String>> submitPembumian(PembumianInputModel input);
  Future<Either<Failure, Map<String, dynamic>?>> getLastPembumian(int towerId);
  Future<Either<Failure, List<PembumianHistoryItemModel>>> getPembumianHistory({int cursor = 0, String? search});
  Future<Either<Failure, String>> downloadBAPembumian({required int towerId, required int inspectionId, required String towerName});

  // PPL
  Future<Either<Failure, String>> submitPpl(PPLInputModel input);
  Future<Either<Failure, String>> updatePpl({required int id, File? ttdTLGI, String? namaTTDTLGI});
  Future<Either<Failure, Map<String, dynamic>?>> getLastPpl(int towerId);
  Future<Either<Failure, List<PPLHistoryItemModel>>> getPplHistory({int cursor = 0, String? search, String? type});
  Future<Either<Failure, List<PPLHistoryItemModel>>> getPplHistoryByIdentifier(String identifier, {int cursor = 0});
  Future<Either<Failure, Map<String, dynamic>>> getSummaryRiwayatPpl();
  Future<Either<Failure, PplConditionSummaryModel>> getPplConditionSummary();
  Future<Either<Failure, String>> downloadBAPPL({required int inspectionId, required String towerName});

  // Ketenagakerjaan
  Future<Either<Failure, List<KetenagakerjaanItemModel>>> getSummaryKetenagakerjaan({int cursor = 0, String? search});
  Future<Either<Failure, List<KetenagakerjaanItemModel>>> getKetenagakerjaanDetail(int id, {int cursor = 0, String? timezone});
  Future<Either<Failure, String>> downloadSuratKetenagakerjaan({
    required int id,
    required int minggu,
    required String bulan,
    required int tahun,
    required String status,
  });

  // Kegiatan Sosial
  Future<Either<Failure, String>> submitKegiatanSosial(KegiatanSosialInputModel input);
  Future<Either<Failure, String>> updateKegiatanSosial({
    required int id,
    File? ttdTLGI,
    String? namaTTDTLGI,
    File? ttdLineWalker,
    String? namaTTDLineWalker,
  });
  Future<Either<Failure, Map<String, dynamic>?>> getLastKegiatanSosial(int towerId);
  Future<Either<Failure, List<KegiatanSosialHistoryItemModel>>> getKegiatanSosialHistory({int cursor = 0, String? search});
  Future<Either<Failure, List<KegiatanSosialHistoryItemModel>>> getKegiatanSosialHistoryByIdentifier(String identifier, {int cursor = 0});
  Future<Either<Failure, String>> downloadBAKegiatanSosial({required int inspectionId, required String towerName});
}
