import '../../domain/entities/sutm_pemeliharaan_score_entity.dart';
import 'score_config_model.dart';

class SutmPemeliharaanScoreModel extends SutmPemeliharaanScoreEntity {
  const SutmPemeliharaanScoreModel({
    required super.date,
    required super.targetPemeliharaan,
    required super.realisasiPemeliharaan,
    required super.pencapaianPemeliharaan,
    required super.pointPencapaianPemeliharaan,
    super.pencapaianPemeliharaanConfig,
    required super.volumeRencana,
    required super.volumeTerlaksana,
    required super.volumeKendala,
    required super.penyelesaianRencana,
    required super.pointPenyelesaianRencana,
    super.penyelesaianRencanaConfig,
    required super.durasiPemeliharaan,
    required super.performa,
    super.performaConfig,
  });

  factory SutmPemeliharaanScoreModel.fromJson(Map<String, dynamic> json) {
    return SutmPemeliharaanScoreModel(
      date: json['date'] as String? ?? '',
      targetPemeliharaan: (json['targetPemeliharaan'] as num?)?.toInt() ?? 0,
      realisasiPemeliharaan:
          (json['realisasiPemeliharaan'] as num?)?.toInt() ?? 0,
      pencapaianPemeliharaan:
          (json['pencapaianPemeliharaan'] as num?)?.toDouble() ?? 0.0,
      pointPencapaianPemeliharaan:
          (json['pointPencapaianPemeliharaan'] as num?)?.toDouble() ?? 0.0,
      pencapaianPemeliharaanConfig: json['pencapaianPemeliharaanConfig'] != null
          ? ScoreConfigModel.fromJson(
              json['pencapaianPemeliharaanConfig'] as Map<String, dynamic>,
            )
          : null,
      volumeRencana: (json['volumeRencana'] as num?)?.toInt() ?? 0,
      volumeTerlaksana: (json['volumeTerlaksana'] as num?)?.toInt() ?? 0,
      volumeKendala: (json['volumeKendala'] as num?)?.toInt() ?? 0,
      penyelesaianRencana:
          (json['penyelesaianRencana'] as num?)?.toDouble() ?? 0.0,
      pointPenyelesaianRencana:
          (json['pointPenyelesaianRencana'] as num?)?.toDouble() ?? 0.0,
      penyelesaianRencanaConfig: json['penyelesaianRencanaConfig'] != null
          ? ScoreConfigModel.fromJson(
              json['penyelesaianRencanaConfig'] as Map<String, dynamic>,
            )
          : null,
      durasiPemeliharaan: (json['durasiPemeliharaan'] as num?)?.toInt() ?? 0,
      performa: (json['performa'] as num?)?.toDouble() ?? 0.0,
      performaConfig: json['performaConfig'] != null
          ? ScoreConfigModel.fromJson(
              json['performaConfig'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'targetPemeliharaan': targetPemeliharaan,
      'realisasiPemeliharaan': realisasiPemeliharaan,
      'pencapaianPemeliharaan': pencapaianPemeliharaan,
      'pointPencapaianPemeliharaan': pointPencapaianPemeliharaan,
      'pencapaianPemeliharaanConfig':
          (pencapaianPemeliharaanConfig as ScoreConfigModel?)?.toJson(),
      'volumeRencana': volumeRencana,
      'volumeTerlaksana': volumeTerlaksana,
      'volumeKendala': volumeKendala,
      'penyelesaianRencana': penyelesaianRencana,
      'pointPenyelesaianRencana': pointPenyelesaianRencana,
      'penyelesaianRencanaConfig':
          (penyelesaianRencanaConfig as ScoreConfigModel?)?.toJson(),
      'durasiPemeliharaan': durasiPemeliharaan,
      'performa': performa,
      'performaConfig': (performaConfig as ScoreConfigModel?)?.toJson(),
    };
  }
}
