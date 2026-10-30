import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/home_summary_repository.dart';
import 'sutm_pemeliharaan_score_state.dart';

class SutmPemeliharaanScoreCubit extends Cubit<SutmPemeliharaanScoreState> {
  final HomeSummaryRepository repository;

  SutmPemeliharaanScoreCubit({required this.repository})
      : super(SutmPemeliharaanScoreInitial());

  Future<void> fetchScore() async {
    emit(SutmPemeliharaanScoreLoading());
    final result = await repository.getSutmPemeliharaanScoreToday();
    result.fold(
      (failure) => emit(SutmPemeliharaanScoreError(message: failure.message)),
      (score) => emit(SutmPemeliharaanScoreLoaded(score: score)),
    );
  }
}
