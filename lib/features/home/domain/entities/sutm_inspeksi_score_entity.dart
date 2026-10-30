import 'package:equatable/equatable.dart';

import 'score_config_entity.dart';

class SutmInspeksiScoreEntity extends Equatable {
  final String date;
  final int targetInspeksi;
  final int realisasiInspeksi;
  final double pencapaianInspeksi;
  final double pointPencapaianInspeksi;
  final ScoreConfigEntity? pencapaianInspeksiConfig;
  final double durasiInspeksi;
  final double pointDurasiInspeksi;
  final ScoreConfigEntity? durasiInspeksiConfig;
  final double performa;
  final ScoreConfigEntity? performaConfig;

  const SutmInspeksiScoreEntity({
    required this.date,
    required this.targetInspeksi,
    required this.realisasiInspeksi,
    required this.pencapaianInspeksi,
    required this.pointPencapaianInspeksi,
    this.pencapaianInspeksiConfig,
    required this.durasiInspeksi,
    required this.pointDurasiInspeksi,
    this.durasiInspeksiConfig,
    required this.performa,
    this.performaConfig,
  });

  @override
  List<Object?> get props => [
        date,
        targetInspeksi,
        realisasiInspeksi,
        pencapaianInspeksi,
        pointPencapaianInspeksi,
        pencapaianInspeksiConfig,
        durasiInspeksi,
        pointDurasiInspeksi,
        durasiInspeksiConfig,
        performa,
        performaConfig,
      ];
}
