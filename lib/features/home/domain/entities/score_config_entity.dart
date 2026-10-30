import 'package:equatable/equatable.dart';

class ScoreConfigEntity extends Equatable {
  final int? id;
  final String? category;
  final String? item;
  final String? color;

  const ScoreConfigEntity({
    this.id,
    this.category,
    this.item,
    this.color,
  });

  @override
  List<Object?> get props => [id, category, item, color];
}
