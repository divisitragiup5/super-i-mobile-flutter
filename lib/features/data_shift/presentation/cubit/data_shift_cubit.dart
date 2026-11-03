import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/data_shift_repository.dart';
import 'data_shift_state.dart';

class DataShiftCubit extends Cubit<DataShiftState> {
  final DataShiftRepository repository;

  DataShiftCubit(this.repository) : super(DataShiftInitial());

  Future<void> fetchShifts({int? bulan, int? tahun}) async {
    final now = DateTime.now();
    final targetMonth = bulan ?? (state is DataShiftLoaded ? (state as DataShiftLoaded).selectedMonth : now.month - 1);
    final targetYear = tahun ?? (state is DataShiftLoaded ? (state as DataShiftLoaded).selectedYear : now.year);

    emit(DataShiftLoading());

    final result = await repository.getDataShift(
      bulan: targetMonth,
      tahun: targetYear,
    );

    result.fold(
      (failure) => emit(DataShiftError(failure.message)),
      (shifts) => emit(
        DataShiftLoaded(
          shifts: shifts,
          selectedMonth: targetMonth,
          selectedYear: targetYear,
        ),
      ),
    );
  }

  Future<bool> gantiJadwal({
    required int shiftId,
    required int tanggalBaru,
    String timezone = 'Asia/Jakarta',
  }) async {
    final currentState = state;
    if (currentState is! DataShiftLoaded) return false;

    emit(currentState.copyWith(isSubmittingSwap: true, errorMessage: null, successMessage: null));

    final result = await repository.gantiJadwal(
      id: shiftId,
      tanggal: tanggalBaru,
      timezone: timezone,
    );

    return result.fold(
      (failure) {
        emit(currentState.copyWith(
          isSubmittingSwap: false,
          errorMessage: failure.message,
        ));
        return false;
      },
      (msg) {
        emit(currentState.copyWith(
          isSubmittingSwap: false,
          successMessage: msg,
        ));
        // Refresh shifts for current month
        fetchShifts(
          bulan: currentState.selectedMonth,
          tahun: currentState.selectedYear,
        );
        return true;
      },
    );
  }
}
