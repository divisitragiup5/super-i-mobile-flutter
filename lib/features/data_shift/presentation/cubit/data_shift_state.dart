import 'package:equatable/equatable.dart';
import '../../data/models/data_shift_model.dart';

abstract class DataShiftState extends Equatable {
  const DataShiftState();

  @override
  List<Object?> get props => [];
}

class DataShiftInitial extends DataShiftState {}

class DataShiftLoading extends DataShiftState {}

class DataShiftLoaded extends DataShiftState {
  final List<ShiftItemModel> shifts;
  final int selectedMonth; // 0-11
  final int selectedYear;
  final bool isSubmittingSwap;
  final String? successMessage;
  final String? errorMessage;

  const DataShiftLoaded({
    required this.shifts,
    required this.selectedMonth,
    required this.selectedYear,
    this.isSubmittingSwap = false,
    this.successMessage,
    this.errorMessage,
  });

  DataShiftLoaded copyWith({
    List<ShiftItemModel>? shifts,
    int? selectedMonth,
    int? selectedYear,
    bool? isSubmittingSwap,
    String? successMessage,
    String? errorMessage,
  }) {
    return DataShiftLoaded(
      shifts: shifts ?? this.shifts,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      isSubmittingSwap: isSubmittingSwap ?? this.isSubmittingSwap,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        shifts,
        selectedMonth,
        selectedYear,
        isSubmittingSwap,
        successMessage,
        errorMessage,
      ];
}

class DataShiftError extends DataShiftState {
  final String message;

  const DataShiftError(this.message);

  @override
  List<Object?> get props => [message];
}
