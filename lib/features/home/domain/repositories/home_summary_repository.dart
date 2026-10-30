import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/sutm_inspeksi_score_entity.dart';
import '../entities/sutm_pemeliharaan_score_entity.dart';

abstract class HomeSummaryRepository {
  Future<Either<Failure, SutmInspeksiScoreEntity>> getSutmInspeksiScoreToday({
    String? timezone,
  });

  Future<Either<Failure, SutmPemeliharaanScoreEntity>> getSutmPemeliharaanScoreToday({
    String? timezone,
  });
}
