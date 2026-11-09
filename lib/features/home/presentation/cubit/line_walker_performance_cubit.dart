import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../line_walker/data/models/line_walker_performance_model.dart';
import '../../../line_walker/domain/repositories/line_walker_repository.dart';

abstract class LineWalkerPerformanceState extends Equatable {
  const LineWalkerPerformanceState();

  @override
  List<Object?> get props => [];
}

class LineWalkerPerformanceInitial extends LineWalkerPerformanceState {}

class LineWalkerPerformanceLoading extends LineWalkerPerformanceState {}

class LineWalkerPerformanceLoaded extends LineWalkerPerformanceState {
  final LineWalkerPerformanceModel? performance;
  final int? filterMinggu;
  final String? filterBulan;
  final int? filterTahun;

  const LineWalkerPerformanceLoaded({
    this.performance,
    this.filterMinggu,
    this.filterBulan,
    this.filterTahun,
  });

  bool get isFiltered =>
      filterMinggu != null || filterBulan != null || filterTahun != null;

  @override
  List<Object?> get props => [
        performance,
        filterMinggu,
        filterBulan,
        filterTahun,
      ];
}

class LineWalkerPerformanceError extends LineWalkerPerformanceState {
  final String message;

  const LineWalkerPerformanceError(this.message);

  @override
  List<Object?> get props => [message];
}

class LineWalkerPerformanceCubit extends Cubit<LineWalkerPerformanceState> {
  final LineWalkerRepository repository;

  int? currentMinggu;
  String? currentBulan;
  int? currentTahun;

  LineWalkerPerformanceCubit(this.repository)
      : super(LineWalkerPerformanceInitial());

  Future<void> fetchPerformance({
    int? minggu,
    String? bulan,
    int? tahun,
  }) async {
    currentMinggu = minggu;
    currentBulan = bulan;
    currentTahun = tahun;

    emit(LineWalkerPerformanceLoading());

    final result = await repository.getMyPerformance(
      minggu: minggu,
      bulan: bulan,
      tahun: tahun,
    );

    result.fold(
      (failure) => emit(LineWalkerPerformanceError(failure.message)),
      (data) => emit(
        LineWalkerPerformanceLoaded(
          performance: data,
          filterMinggu: currentMinggu,
          filterBulan: currentBulan,
          filterTahun: currentTahun,
        ),
      ),
    );
  }

  Future<void> resetFilter() async {
    currentMinggu = null;
    currentBulan = null;
    currentTahun = null;
    await fetchPerformance();
  }
}
