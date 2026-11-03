import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/history_penilaian_model.dart';

abstract class HistoryPenilaianRepository {
  Future<Either<Failure, NilaiBulananPaginationModel>> getNilaiBulanan({
    int? cursor,
  });

  Future<Either<Failure, List<NilaiHarianItemModel>>> getNilaiHarian({
    required int bulan,
    required int tahun,
  });

  Future<Either<Failure, GrafikBulananModel>> getGrafikBulanan({
    required int bulan,
    required int tahun,
  });
}
