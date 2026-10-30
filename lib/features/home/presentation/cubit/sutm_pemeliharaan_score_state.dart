import 'package:equatable/equatable.dart';

import '../../domain/entities/sutm_pemeliharaan_score_entity.dart';

abstract class SutmPemeliharaanScoreState extends Equatable {
  const SutmPemeliharaanScoreState();

  @override
  List<Object?> get props => [];
}

class SutmPemeliharaanScoreInitial extends SutmPemeliharaanScoreState {}

class SutmPemeliharaanScoreLoading extends SutmPemeliharaanScoreState {}

class SutmPemeliharaanScoreLoaded extends SutmPemeliharaanScoreState {
  final SutmPemeliharaanScoreEntity score;

  const SutmPemeliharaanScoreLoaded({required this.score});

  @override
  List<Object?> get props => [score];
}

class SutmPemeliharaanScoreError extends SutmPemeliharaanScoreState {
  final String message;

  const SutmPemeliharaanScoreError({required this.message});

  @override
  List<Object?> get props => [message];
}
