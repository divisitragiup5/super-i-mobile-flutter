import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/sutm_workorder_model.dart';
import '../../domain/repositories/sutm_repository.dart';

abstract class ValidasiPemeliharaanState {}

class ValidasiPemeliharaanInitial extends ValidasiPemeliharaanState {}

class ValidasiPemeliharaanLoading extends ValidasiPemeliharaanState {}

class ValidasiPemeliharaanLoaded extends ValidasiPemeliharaanState {
  final List<SutmWorkOrderItem> workOrders;
  final List<SutmItemModel> sutmItems;
  final List<int> selectedSutmIds;
  final String activeTab; // 'workorder' | 'sutm'
  final String searchQuery;
  final bool isActionLoading;

  ValidasiPemeliharaanLoaded({
    this.workOrders = const [],
    this.sutmItems = const [],
    this.selectedSutmIds = const [],
    this.activeTab = 'workorder',
    this.searchQuery = '',
    this.isActionLoading = false,
  });

  ValidasiPemeliharaanLoaded copyWith({
    List<SutmWorkOrderItem>? workOrders,
    List<SutmItemModel>? sutmItems,
    List<int>? selectedSutmIds,
    String? activeTab,
    String? searchQuery,
    bool? isActionLoading,
  }) {
    return ValidasiPemeliharaanLoaded(
      workOrders: workOrders ?? this.workOrders,
      sutmItems: sutmItems ?? this.sutmItems,
      selectedSutmIds: selectedSutmIds ?? this.selectedSutmIds,
      activeTab: activeTab ?? this.activeTab,
      searchQuery: searchQuery ?? this.searchQuery,
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }
}

class ValidasiPemeliharaanActionSuccess extends ValidasiPemeliharaanState {
  final String message;

  ValidasiPemeliharaanActionSuccess({required this.message});
}

class ValidasiPemeliharaanError extends ValidasiPemeliharaanState {
  final String message;

  ValidasiPemeliharaanError({required this.message});
}

class ValidasiPemeliharaanCubit extends Cubit<ValidasiPemeliharaanState> {
  final SutmRepository repository;

  ValidasiPemeliharaanCubit({required this.repository})
      : super(ValidasiPemeliharaanInitial());

  Future<void> loadValidasiData({String? search}) async {
    emit(ValidasiPemeliharaanLoading());
    final woResult = await repository.getValidasiPemeliharaanWorkOrderList(
      search: search,
    );
    final sutmResult = await repository.getValidasiPemeliharaanSutmList(
      search: search,
    );

    woResult.fold(
      (failure) => emit(ValidasiPemeliharaanError(message: failure.message)),
      (woList) {
        sutmResult.fold(
          (failure) =>
              emit(ValidasiPemeliharaanError(message: failure.message)),
          (sutmList) {
            emit(ValidasiPemeliharaanLoaded(
              workOrders: woList,
              sutmItems: sutmList,
              selectedSutmIds: const [],
              activeTab: 'workorder',
              searchQuery: search ?? '',
            ));
          },
        );
      },
    );
  }

  void switchTab(String tab) {
    if (state is! ValidasiPemeliharaanLoaded) return;
    final current = state as ValidasiPemeliharaanLoaded;
    emit(current.copyWith(activeTab: tab));
  }

  void toggleSelectSutm(int id) {
    if (state is! ValidasiPemeliharaanLoaded) return;
    final current = state as ValidasiPemeliharaanLoaded;
    final updated = List<int>.from(current.selectedSutmIds);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    emit(current.copyWith(selectedSutmIds: updated));
  }

  void selectAll(List<String> roles) {
    if (state is! ValidasiPemeliharaanLoaded) return;
    final current = state as ValidasiPemeliharaanLoaded;
    final allIds = current.sutmItems
        .where((i) => i.canUserApprove(roles))
        .map((i) => i.id)
        .where((id) => id > 0)
        .toList();
    emit(current.copyWith(selectedSutmIds: allIds));
  }

  void clearSelection() {
    if (state is! ValidasiPemeliharaanLoaded) return;
    final current = state as ValidasiPemeliharaanLoaded;
    emit(current.copyWith(selectedSutmIds: const []));
  }

  Future<bool> approveSingle({required String role, required int id}) async {
    final result = await repository.approvePemeliharaan(role: role, id: id);
    return result.fold(
      (failure) {
        emit(ValidasiPemeliharaanError(message: failure.message));
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
    final result = await repository.rejectPemeliharaan(
      role: role,
      id: id,
      reason: reason,
    );
    return result.fold(
      (failure) {
        emit(ValidasiPemeliharaanError(message: failure.message));
        return false;
      },
      (_) {
        loadValidasiData();
        return true;
      },
    );
  }

  Future<bool> approveBulk({
    required String role,
  }) async {
    if (state is! ValidasiPemeliharaanLoaded) return false;
    final current = state as ValidasiPemeliharaanLoaded;
    if (current.selectedSutmIds.isEmpty) return false;

    // Kelompokkan SUTM terpilih berdasarkan workOrderId
    final Map<int, List<int>> itemsByWo = {};
    for (final id in current.selectedSutmIds) {
      final item = current.sutmItems.firstWhere(
        (i) => i.id == id,
        orElse: () => current.sutmItems.first,
      );
      final woId = item.workOrderId ?? 0;
      if (woId > 0) {
        itemsByWo.putIfAbsent(woId, () => []).add(item.id);
      }
    }

    if (itemsByWo.isEmpty) {
      emit(ValidasiPemeliharaanError(
        message: 'Work Order ID tidak ditemukan pada item terpilih.',
      ));
      return false;
    }

    emit(current.copyWith(isActionLoading: true));
    try {
      for (final entry in itemsByWo.entries) {
        final result = await repository.approveBulkPemeliharaan(
          role: role,
          workOrderId: entry.key,
          ids: entry.value,
        );
        result.fold(
          (f) => throw Exception(f.message),
          (_) {},
        );
      }
      clearSelection();
      loadValidasiData();
      return true;
    } catch (e) {
      emit(ValidasiPemeliharaanError(message: e.toString()));
      return false;
    }
  }

  Future<bool> rejectBulk({
    required String role,
    required String reason,
  }) async {
    if (state is! ValidasiPemeliharaanLoaded) return false;
    final current = state as ValidasiPemeliharaanLoaded;
    if (current.selectedSutmIds.isEmpty) return false;

    // Kelompokkan SUTM terpilih berdasarkan workOrderId
    final Map<int, List<int>> itemsByWo = {};
    for (final id in current.selectedSutmIds) {
      final item = current.sutmItems.firstWhere(
        (i) => i.id == id,
        orElse: () => current.sutmItems.first,
      );
      final woId = item.workOrderId ?? 0;
      if (woId > 0) {
        itemsByWo.putIfAbsent(woId, () => []).add(item.id);
      }
    }

    if (itemsByWo.isEmpty) {
      emit(ValidasiPemeliharaanError(
        message: 'Work Order ID tidak ditemukan pada item terpilih.',
      ));
      return false;
    }

    emit(current.copyWith(isActionLoading: true));
    try {
      for (final entry in itemsByWo.entries) {
        final result = await repository.rejectBulkPemeliharaan(
          role: role,
          workOrderId: entry.key,
          reason: reason,
          ids: entry.value,
        );
        result.fold(
          (f) => throw Exception(f.message),
          (_) {},
        );
      }
      clearSelection();
      loadValidasiData();
      return true;
    } catch (e) {
      emit(ValidasiPemeliharaanError(message: e.toString()));
      return false;
    }
  }
}
