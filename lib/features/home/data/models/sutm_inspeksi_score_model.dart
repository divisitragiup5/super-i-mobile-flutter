import '../../domain/entities/sutm_inspeksi_score_entity.dart';
import 'score_config_model.dart';

class SutmInspeksiScoreModel extends SutmInspeksiScoreEntity {
  const SutmInspeksiScoreModel({
    required super.date,
    required super.targetInspeksi,
    required super.realisasiInspeksi,
    required super.pencapaianInspeksi,
    required super.pointPencapaianInspeksi,
    super.pencapaianInspeksiConfig,
    required super.durasiInspeksi,
    required super.pointDurasiInspeksi,
    super.durasiInspeksiConfig,
    required super.performa,
    super.performaConfig,
  });

  factory SutmInspeksiScoreModel.fromJson(Map<String, dynamic> json) {
    return SutmInspeksiScoreModel(
      date: json['date'] as String? ?? '',
      targetInspeksi: (json['targetInspeksi'] as num?)?.toInt() ?? 0,
      realisasiInspeksi: (json['realisasiInspeksi'] as num?)?.toInt() ?? 0,
      pencapaianInspeksi: (json['pencapaianInspeksi'] as num?)?.toDouble() ?? 0.0,
      pointPencapaianInspeksi:
          (json['pointPencapaianInspeksi'] as num?)?.toDouble() ?? 0.0,
      pencapaianInspeksiConfig: json['pencapaianInspeksiConfig'] != null
          ? ScoreConfigModel.fromJson(
              json['pencapaianInspeksiConfig'] as Map<String, dynamic>,
            )
          : null,
      durasiInspeksi: (json['durasiInspeksi'] as num?)?.toDouble() ?? 0.0,
      pointDurasiInspeksi:
          (json['pointDurasiInspeksi'] as num?)?.toDouble() ?? 0.0,
      durasiInspeksiConfig: json['durasiInspeksiConfig'] != null
          ? ScoreConfigModel.fromJson(
              json['durasiInspeksiConfig'] as Map<String, dynamic>,
            )
          : null,
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
      'targetInspeksi': targetInspeksi,
      'realisasiInspeksi': realisasiInspeksi,
      'pencapaianInspeksi': pencapaianInspeksi,
      'pointPencapaianInspeksi': pointPencapaianInspeksi,
      'pencapaianInspeksiConfig':
          (pencapaianInspeksiConfig as ScoreConfigModel?)?.toJson(),
      'durasiInspeksi': durasiInspeksi,
      'pointDurasiInspeksi': pointDurasiInspeksi,
      'durasiInspeksiConfig':
          (durasiInspeksiConfig as ScoreConfigModel?)?.toJson(),
      'performa': performa,
      'performaConfig': (performaConfig as ScoreConfigModel?)?.toJson(),
    };
  }
}
