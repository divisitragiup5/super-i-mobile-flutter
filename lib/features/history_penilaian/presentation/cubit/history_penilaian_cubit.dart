import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/history_penilaian_repository.dart';
import 'history_penilaian_state.dart';

class HistoryPenilaianCubit extends Cubit<HistoryPenilaianState> {
  final HistoryPenilaianRepository repository;

  HistoryPenilaianCubit(this.repository) : super(HistoryPenilaianInitial());

  Future<void> fetchHistory() async {
    emit(HistoryPenilaianLoading());
    final result = await repository.getNilaiBulanan();
    result.fold(
      (failure) => emit(HistoryPenilaianError(failure.message)),
      (data) => emit(
        HistoryPenilaianLoaded(
          items: data.items,
          nextCursor: data.nextCursor,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! HistoryPenilaianLoaded ||
        currentState.nextCursor == null ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await repository.getNilaiBulanan(
      cursor: currentState.nextCursor,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (data) => emit(
        currentState.copyWith(
          items: [...currentState.items, ...data.items],
          nextCursor: data.nextCursor,
          isLoadingMore: false,
        ),
      ),
    );
  }
}

class DetailHistoryPenilaianCubit
    extends Cubit<DetailHistoryPenilaianState> {
  final HistoryPenilaianRepository repository;

  DetailHistoryPenilaianCubit(this.repository)
      : super(DetailHistoryPenilaianInitial());

  Future<void> fetchDetail({
    required int bulan,
    required int tahun,
  }) async {
    emit(DetailHistoryPenilaianLoading());

    final harianResult = await repository.getNilaiHarian(
      bulan: bulan,
      tahun: tahun,
    );

    final grafikResult = await repository.getGrafikBulanan(
      bulan: bulan,
      tahun: tahun,
    );

    harianResult.fold(
      (failure) => emit(DetailHistoryPenilaianError(failure.message)),
      (harianList) {
        grafikResult.fold(
          (failure) => emit(DetailHistoryPenilaianError(failure.message)),
          (grafik) => emit(
            DetailHistoryPenilaianLoaded(
              harianItems: harianList,
              grafik: grafik,
            ),
          ),
        );
      },
    );
  }
}
