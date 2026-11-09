import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../line_walker/domain/repositories/line_walker_repository.dart';
import 'package:super_i_mobile/features/home/data/models/ppl_condition_summary_model.dart';

abstract class PplConditionSummaryState extends Equatable {
  const PplConditionSummaryState();

  @override
  List<Object?> get props => [];
}

class PplConditionSummaryInitial extends PplConditionSummaryState {}

class PplConditionSummaryLoading extends PplConditionSummaryState {}

class PplConditionSummaryLoaded extends PplConditionSummaryState {
  final PplConditionSummaryModel summary;

  const PplConditionSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class PplConditionSummaryError extends PplConditionSummaryState {
  final String message;

  const PplConditionSummaryError(this.message);

  @override
  List<Object?> get props => [message];
}

class PplConditionSummaryCubit extends Cubit<PplConditionSummaryState> {
  final LineWalkerRepository repository;

  PplConditionSummaryCubit(this.repository)
      : super(PplConditionSummaryInitial());

  Future<void> fetchSummary() async {
    emit(PplConditionSummaryLoading());

    final result = await repository.getPplConditionSummary();

    result.fold(
      (failure) => emit(PplConditionSummaryError(failure.message)),
      (data) => emit(PplConditionSummaryLoaded(data)),
    );
  }
}
