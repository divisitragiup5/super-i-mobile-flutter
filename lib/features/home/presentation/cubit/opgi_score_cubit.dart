import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_time_utils.dart';
import '../../domain/repositories/home_summary_repository.dart';
import 'opgi_score_state.dart';

class OpgiScoreCubit extends Cubit<OpgiScoreState> {
  final HomeSummaryRepository repository;

  OpgiScoreCubit({required this.repository}) : super(OpgiScoreInitial());

  Future<void> fetchScore({String? timezone}) async {
    emit(OpgiScoreLoading());
    final tz = timezone ?? AppTimeUtils.deviceTimezone;
    final result = await repository.getOpgiScoreToday(timezone: tz);
    result.fold(
      (failure) => emit(OpgiScoreError(message: failure.message)),
      (score) => emit(OpgiScoreLoaded(score: score)),
    );
  }
}
