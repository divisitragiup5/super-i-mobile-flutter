import 'package:equatable/equatable.dart';

import 'score_config_entity.dart';

class SutmPemeliharaanScoreEntity extends Equatable {
  final String date;
  final int targetPemeliharaan;
  final int realisasiPemeliharaan;
  final double pencapaianPemeliharaan;
  final double pointPencapaianPemeliharaan;
  final ScoreConfigEntity? pencapaianPemeliharaanConfig;
  final int volumeRencana;
  final int volumeTerlaksana;
  final int volumeKendala;
  final double penyelesaianRencana;
  final double pointPenyelesaianRencana;
  final ScoreConfigEntity? penyelesaianRencanaConfig;
  final int durasiPemeliharaan;
  final double performa;
  final ScoreConfigEntity? performaConfig;

  const SutmPemeliharaanScoreEntity({
    required this.date,
    required this.targetPemeliharaan,
    required this.realisasiPemeliharaan,
    required this.pencapaianPemeliharaan,
    required this.pointPencapaianPemeliharaan,
    this.pencapaianPemeliharaanConfig,
    required this.volumeRencana,
    required this.volumeTerlaksana,
    required this.volumeKendala,
    required this.penyelesaianRencana,
    required this.pointPenyelesaianRencana,
    this.penyelesaianRencanaConfig,
    required this.durasiPemeliharaan,
    required this.performa,
    this.performaConfig,
  });

  @override
  List<Object?> get props => [
        date,
        targetPemeliharaan,
        realisasiPemeliharaan,
        pencapaianPemeliharaan,
        pointPencapaianPemeliharaan,
        pencapaianPemeliharaanConfig,
        volumeRencana,
        volumeTerlaksana,
        volumeKendala,
        penyelesaianRencana,
        pointPenyelesaianRencana,
        penyelesaianRencanaConfig,
        durasiPemeliharaan,
        performa,
        performaConfig,
      ];
}
