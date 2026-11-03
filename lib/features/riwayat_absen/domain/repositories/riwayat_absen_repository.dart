import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/riwayat_absen_model.dart';

abstract class RiwayatAbsenRepository {
  Future<Either<Failure, RiwayatAbsenPaginationModel>> getAbsenHistory({
    int? cursor,
  });

  Future<Either<Failure, String>> uploadDokumen({
    required int riwayatId,
    required File file,
  });
}
