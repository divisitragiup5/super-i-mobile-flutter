import 'dart:io';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/absen_info_entity.dart';

abstract class AbsenRepository {
  Future<Either<Failure, AbsenInfoEntity>> getAbsensiInfo();

  Future<Either<Failure, Map<String, dynamic>>> submitAbsen({
    required String type, // 'MASUK' | 'KELUAR'
    required File pictureFile,
    required double latitude,
    required double longitude,
    required int failedAttempt,
    required List<Map<String, dynamic>> faceProps,
    String? address,
    Map<String, dynamic>? extraData,
  });
}