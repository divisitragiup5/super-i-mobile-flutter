import '../../domain/entities/score_config_entity.dart';

class ScoreConfigModel extends ScoreConfigEntity {
  const ScoreConfigModel({
    super.id,
    super.category,
    super.item,
    super.color,
  });

  factory ScoreConfigModel.fromJson(Map<String, dynamic> json) {
    return ScoreConfigModel(
      id: json['id'] is int ? json['id'] as int : null,
      category: json['category'] as String?,
      item: json['item'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'item': item,
      'color': color,
    };
  }
}
