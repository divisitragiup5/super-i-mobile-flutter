import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/data_shift_model.dart';

abstract class DataShiftRepository {
  Future<Either<Failure, List<ShiftItemModel>>> getDataShift({
    required int bulan,
    required int tahun,
  });

  Future<Either<Failure, String>> gantiJadwal({
    required int id,
    required int tanggal,
    required String timezone,
  });
}
