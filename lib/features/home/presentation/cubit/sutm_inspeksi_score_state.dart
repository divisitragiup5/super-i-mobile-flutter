import 'package:equatable/equatable.dart';

import '../../domain/entities/sutm_inspeksi_score_entity.dart';

abstract class SutmInspeksiScoreState extends Equatable {
  const SutmInspeksiScoreState();

  @override
  List<Object?> get props => [];
}

class SutmInspeksiScoreInitial extends SutmInspeksiScoreState {}

class SutmInspeksiScoreLoading extends SutmInspeksiScoreState {}

class SutmInspeksiScoreLoaded extends SutmInspeksiScoreState {
  final SutmInspeksiScoreEntity score;

  const SutmInspeksiScoreLoaded({required this.score});

  @override
  List<Object?> get props => [score];
}

class SutmInspeksiScoreError extends SutmInspeksiScoreState {
  final String message;

  const SutmInspeksiScoreError({required this.message});

  @override
  List<Object?> get props => [message];
}
