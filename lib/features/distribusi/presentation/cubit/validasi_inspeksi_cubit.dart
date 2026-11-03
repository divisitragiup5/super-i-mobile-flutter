import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/sutm_workorder_model.dart';
import '../../domain/repositories/sutm_repository.dart';

abstract class ValidasiInspeksiState {}

class ValidasiInspeksiInitial extends ValidasiInspeksiState {}

class ValidasiInspeksiLoading extends ValidasiInspeksiState {}

class ValidasiInspeksiLoaded extends ValidasiInspeksiState {
  final List<SutmWorkOrderItem> workOrders;
  final List<SutmItemModel> sutmItems;
  final List<int> selectedSutmIds;
  final String activeTab; // 'workorder' | 'sutm'

  ValidasiInspeksiLoaded({
    this.workOrders = const [],
    this.sutmItems = const [],
    this.selectedSutmIds = const [],
    this.activeTab = 'workorder',
  });

  ValidasiInspeksiLoaded copyWith({
    List<SutmWorkOrderItem>? workOrders,
    List<SutmItemModel>? sutmItems,
    List<int>? selectedSutmIds,
    String? activeTab,
  }) {
    return ValidasiInspeksiLoaded(
      workOrders: workOrders ?? this.workOrders,
      sutmItems: sutmItems ?? this.sutmItems,
      selectedSutmIds: selectedSutmIds ?? this.selectedSutmIds,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}

class ValidasiInspeksiActionSuccess extends ValidasiInspeksiState {
  final String message;

  ValidasiInspeksiActionSuccess({required this.message});
}

class ValidasiInspeksiError extends ValidasiInspeksiState {
  final String message;

  ValidasiInspeksiError({required this.message});
}

class ValidasiInspeksiCubit extends Cubit<ValidasiInspeksiState> {
  final SutmRepository repository;

  ValidasiInspeksiCubit({required this.repository})
      : super(ValidasiInspeksiInitial());

  Future<void> loadValidasiData() async {
    emit(ValidasiInspeksiLoading());
    final woResult = await repository.getValidasiWorkOrderList();
    final sutmResult = await repository.getValidasiSutmList();

    woResult.fold(
      (failure) => emit(ValidasiInspeksiError(message: failure.message)),
      (woList) {
        sutmResult.fold(
          (failure) => emit(ValidasiInspeksiError(message: failure.message)),
          (sutmList) {
            emit(ValidasiInspeksiLoaded(
              workOrders: woList,
              sutmItems: sutmList,
              selectedSutmIds: const [],
              activeTab: 'workorder',
            ));
          },
        );
      },
    );
  }

  void switchTab(String tab) {
    if (state is! ValidasiInspeksiLoaded) return;
    final current = state as ValidasiInspeksiLoaded;
    emit(current.copyWith(activeTab: tab));
  }

  void toggleSelectSutm(int id) {
    if (state is! ValidasiInspeksiLoaded) return;
    final current = state as ValidasiInspeksiLoaded;
    final updated = List<int>.from(current.selectedSutmIds);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    emit(current.copyWith(selectedSutmIds: updated));
  }

  void selectAll() {
    if (state is! ValidasiInspeksiLoaded) return;
    final current = state as ValidasiInspeksiLoaded;
    final allIds = current.sutmItems
        .where((i) => i.canValidasi && i.inspectionId != null)
        .map((i) => int.tryParse(i.inspectionId!) ?? 0)
        .where((id) => id > 0)
        .toList();
    emit(current.copyWith(selectedSutmIds: allIds));
  }

  void clearSelection() {
    if (state is! ValidasiInspeksiLoaded) return;
    final current = state as ValidasiInspeksiLoaded;
    emit(current.copyWith(selectedSutmIds: const []));
  }

  Future<bool> approveSingle({required String role, required int id}) async {
    final result = await repository.approveInspeksi(role: role, id: id);
    return result.fold(
      (failure) {
        emit(ValidasiInspeksiError(message: failure.message));
        return false;
      },
      (_) {
        loadValidasiData();
        return true;
      },
    );
  }

  Future<bool> rejectSingle({
    required String role,
    required int id,
    required String reason,
  }) async {
    final result = await repository.rejectInspeksi(
      role: role,
      id: id,
      reason: reason,
    );
    return result.fold(
      (failure) {
        emit(ValidasiInspeksiError(message: failure.message));
        return false;
      },
      (_) {
        loadValidasiData();
        return true;
      },
    );
  }

  Future<bool> approveBulk({required String role}) async {
    if (state is! ValidasiInspeksiLoaded) return false;
    final current = state as ValidasiInspeksiLoaded;
    if (current.selectedSutmIds.isEmpty) return false;

    final result = await repository.approveBulkInspeksi(
      role: role,
      inspeksiIds: current.selectedSutmIds,
    );
    return result.fold(
      (failure) {
        emit(ValidasiInspeksiError(message: failure.message));
        return false;
      },
      (_) {
        loadValidasiData();
        return true;
      },
    );
  }

  Future<bool> rejectBulk({required String role, required String reason}) async {
    if (state is! ValidasiInspeksiLoaded) return false;
    final current = state as ValidasiInspeksiLoaded;
    if (current.selectedSutmIds.isEmpty) return false;

    final result = await repository.rejectBulkInspeksi(
      role: role,
      inspeksiIds: current.selectedSutmIds,
      reason: reason,
    );
    return result.fold(
      (failure) {
        emit(ValidasiInspeksiError(message: failure.message));
        return false;
      },
      (_) {
        loadValidasiData();
        return true;
      },
    );
  }
}
