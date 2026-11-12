import 'package:equatable/equatable.dart';
import '../../data/models/opgi_score_today_model.dart';

abstract class OpgiScoreState extends Equatable {
  const OpgiScoreState();

  @override
  List<Object?> get props => [];
}

class OpgiScoreInitial extends OpgiScoreState {}

class OpgiScoreLoading extends OpgiScoreState {}

class OpgiScoreLoaded extends OpgiScoreState {
  final OpgiScoreTodayModel? score;

  const OpgiScoreLoaded({this.score});

  bool get isEmpty => score == null || score!.main.isEmpty;

  @override
  List<Object?> get props => [score];
}

class OpgiScoreError extends OpgiScoreState {
  final String message;

  const OpgiScoreError({required this.message});

  @override
  List<Object?> get props => [message];
}
