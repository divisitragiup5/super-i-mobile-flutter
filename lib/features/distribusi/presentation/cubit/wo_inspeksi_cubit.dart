import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/sutm_workorder_model.dart';
import '../../domain/repositories/sutm_repository.dart';

abstract class WoInspeksiState {}

class WoInspeksiInitial extends WoInspeksiState {}

class WoInspeksiLoading extends WoInspeksiState {}

class WoInspeksiLoaded extends WoInspeksiState {
  final List<SutmWorkOrderItem> todayWorkOrders;
  final List<SutmWorkOrderItem> allWorkOrders;
  final SutmWorkOrderItem? detailWorkOrder;

  WoInspeksiLoaded({
    this.todayWorkOrders = const [],
    this.allWorkOrders = const [],
    this.detailWorkOrder,
  });

  WoInspeksiLoaded copyWith({
    List<SutmWorkOrderItem>? todayWorkOrders,
    List<SutmWorkOrderItem>? allWorkOrders,
    SutmWorkOrderItem? detailWorkOrder,
  }) {
    return WoInspeksiLoaded(
      todayWorkOrders: todayWorkOrders ?? this.todayWorkOrders,
      allWorkOrders: allWorkOrders ?? this.allWorkOrders,
      detailWorkOrder: detailWorkOrder ?? this.detailWorkOrder,
    );
  }
}

class WoInspeksiError extends WoInspeksiState {
  final String message;

  WoInspeksiError({required this.message});
}

class WoInspeksiActionSuccess extends WoInspeksiState {
  final String message;

  WoInspeksiActionSuccess({required this.message});
}

class WoInspeksiCubit extends Cubit<WoInspeksiState> {
  final SutmRepository repository;

  WoInspeksiCubit({required this.repository}) : super(WoInspeksiInitial());

  Future<void> fetchToday(String date) async {
    emit(WoInspeksiLoading());
    final result = await repository.getWorkOrderInspeksiToday(date);
    result.fold(
      (failure) => emit(WoInspeksiError(message: failure.message)),
      (items) => emit(WoInspeksiLoaded(todayWorkOrders: items)),
    );
  }

  Future<void> fetchList({int page = 1, int limit = 10, String? search}) async {
    emit(WoInspeksiLoading());
    final result = await repository.getWorkOrderInspeksiList(
      page: page,
      limit: limit,
      search: search,
    );
    result.fold(
      (failure) => emit(WoInspeksiError(message: failure.message)),
      (items) => emit(WoInspeksiLoaded(allWorkOrders: items)),
    );
  }

  Future<void> fetchDetail(String workOrderId) async {
    final currentLoaded = state is WoInspeksiLoaded ? state as WoInspeksiLoaded : null;
    emit(WoInspeksiLoading());
    final result = await repository.getWorkOrderInspeksiDetail(workOrderId);
    result.fold(
      (failure) => emit(WoInspeksiError(message: failure.message)),
      (detail) {
        if (currentLoaded != null) {
          emit(currentLoaded.copyWith(detailWorkOrder: detail));
        } else {
          emit(WoInspeksiLoaded(detailWorkOrder: detail));
        }
      },
    );
  }

  Future<bool> rejectSutm({
    required String workOrderId,
    required List<int> itemIds,
    String? reason,
  }) async {
    final result = await repository.rejectSutmInspeksi(
      workOrderId: workOrderId,
      itemIds: itemIds,
      reason: reason,
    );
    return result.fold(
      (failure) {
        emit(WoInspeksiError(message: failure.message));
        return false;
      },
      (_) => true,
    );
  }
}
