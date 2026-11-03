import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/sutm_workorder_model.dart';
import '../../domain/repositories/sutm_repository.dart';

abstract class WoPemeliharaanState {}

class WoPemeliharaanInitial extends WoPemeliharaanState {}

class WoPemeliharaanLoading extends WoPemeliharaanState {}

class WoPemeliharaanLoaded extends WoPemeliharaanState {
  final List<SutmWorkOrderItem> todayWorkOrders;
  final List<SutmWorkOrderItem> allWorkOrders;
  final SutmWorkOrderItem? detailWorkOrder;

  WoPemeliharaanLoaded({
    this.todayWorkOrders = const [],
    this.allWorkOrders = const [],
    this.detailWorkOrder,
  });

  WoPemeliharaanLoaded copyWith({
    List<SutmWorkOrderItem>? todayWorkOrders,
    List<SutmWorkOrderItem>? allWorkOrders,
    SutmWorkOrderItem? detailWorkOrder,
  }) {
    return WoPemeliharaanLoaded(
      todayWorkOrders: todayWorkOrders ?? this.todayWorkOrders,
      allWorkOrders: allWorkOrders ?? this.allWorkOrders,
      detailWorkOrder: detailWorkOrder ?? this.detailWorkOrder,
    );
  }
}

class WoPemeliharaanError extends WoPemeliharaanState {
  final String message;

  WoPemeliharaanError({required this.message});
}

class WoPemeliharaanCubit extends Cubit<WoPemeliharaanState> {
  final SutmRepository repository;

  WoPemeliharaanCubit({required this.repository})
      : super(WoPemeliharaanInitial());

  Future<void> fetchToday(String date) async {
    emit(WoPemeliharaanLoading());
    final result = await repository.getWorkOrderPemeliharaanToday(date);
    result.fold(
      (failure) => emit(WoPemeliharaanError(message: failure.message)),
      (items) => emit(WoPemeliharaanLoaded(todayWorkOrders: items)),
    );
  }

  Future<void> fetchList({int page = 1, int limit = 10}) async {
    emit(WoPemeliharaanLoading());
    final result = await repository.getWorkOrderPemeliharaanList(
      page: page,
      limit: limit,
    );
    result.fold(
      (failure) => emit(WoPemeliharaanError(message: failure.message)),
      (items) => emit(WoPemeliharaanLoaded(allWorkOrders: items)),
    );
  }

  Future<void> fetchDetail(String workOrderId) async {
    final currentLoaded =
        state is WoPemeliharaanLoaded ? state as WoPemeliharaanLoaded : null;
    emit(WoPemeliharaanLoading());
    final result =
        await repository.getWorkOrderPemeliharaanDetail(workOrderId);
    result.fold(
      (failure) => emit(WoPemeliharaanError(message: failure.message)),
      (detail) {
        if (currentLoaded != null) {
          emit(currentLoaded.copyWith(detailWorkOrder: detail));
        } else {
          emit(WoPemeliharaanLoaded(detailWorkOrder: detail));
        }
      },
    );
  }

  Future<bool> rejectSutm({
    required int workOrderId,
    required List<int> itemIds,
    String? reason,
  }) async {
    final result = await repository.rejectSutmPemeliharaan(
      workOrderId: workOrderId,
      itemIds: itemIds,
      reason: reason,
    );
    return result.fold(
      (failure) {
        emit(WoPemeliharaanError(message: failure.message));
        return false;
      },
      (_) => true,
    );
  }
}
