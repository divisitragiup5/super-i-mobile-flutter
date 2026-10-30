import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/home_summary_repository.dart';
import 'sutm_inspeksi_score_state.dart';

class SutmInspeksiScoreCubit extends Cubit<SutmInspeksiScoreState> {
  final HomeSummaryRepository repository;

  SutmInspeksiScoreCubit({required this.repository})
      : super(SutmInspeksiScoreInitial());

  Future<void> fetchScore() async {
    emit(SutmInspeksiScoreLoading());
    final result = await repository.getSutmInspeksiScoreToday();
    result.fold(
      (failure) => emit(SutmInspeksiScoreError(message: failure.message)),
      (score) => emit(SutmInspeksiScoreLoaded(score: score)),
    );
  }
}
