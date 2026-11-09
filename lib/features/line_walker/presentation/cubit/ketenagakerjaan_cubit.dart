import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/ketenagakerjaan_model.dart';
import '../../domain/repositories/line_walker_repository.dart';

abstract class KetenagakerjaanState extends Equatable {
  const KetenagakerjaanState();
  @override
  List<Object?> get props => [];
}

class KetenagakerjaanInitial extends KetenagakerjaanState {}

class KetenagakerjaanLoading extends KetenagakerjaanState {}

class KetenagakerjaanSummaryLoaded extends KetenagakerjaanState {
  final List<KetenagakerjaanItemModel> items;
  final bool hasReachedMax;
  final int nextCursor;
  final bool isLoadingMore;

  const KetenagakerjaanSummaryLoaded({
    required this.items,
    this.hasReachedMax = false,
    this.nextCursor = 0,
    this.isLoadingMore = false,
  });

  KetenagakerjaanSummaryLoaded copyWith({
    List<KetenagakerjaanItemModel>? items,
    bool? hasReachedMax,
    int? nextCursor,
    bool? isLoadingMore,
  }) {
    return KetenagakerjaanSummaryLoaded(
      items: items ?? this.items,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [items, hasReachedMax, nextCursor, isLoadingMore];
}

class KetenagakerjaanDetailLoaded extends KetenagakerjaanState {
  final List<KetenagakerjaanItemModel> items;
  final bool hasReachedMax;
  final int nextCursor;
  final bool isLoadingMore;

  const KetenagakerjaanDetailLoaded({
    required this.items,
    this.hasReachedMax = false,
    this.nextCursor = 0,
    this.isLoadingMore = false,
  });

  KetenagakerjaanDetailLoaded copyWith({
    List<KetenagakerjaanItemModel>? items,
    bool? hasReachedMax,
    int? nextCursor,
    bool? isLoadingMore,
  }) {
    return KetenagakerjaanDetailLoaded(
      items: items ?? this.items,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [items, hasReachedMax, nextCursor, isLoadingMore];
}

class KetenagakerjaanError extends KetenagakerjaanState {
  final String message;
  const KetenagakerjaanError(this.message);
  @override
  List<Object?> get props => [message];
}

class KetenagakerjaanCubit extends Cubit<KetenagakerjaanState> {
  final LineWalkerRepository repository;

  KetenagakerjaanCubit(this.repository) : super(KetenagakerjaanInitial());

  Future<void> loadSummary({String? search}) async {
    emit(KetenagakerjaanLoading());
    final result = await repository.getSummaryKetenagakerjaan(cursor: 0, search: search);
    result.fold(
      (failure) => emit(KetenagakerjaanError(failure.message)),
      (items) => emit(KetenagakerjaanSummaryLoaded(
        items: items,
        hasReachedMax: items.length < 10,
        nextCursor: items.length,
      )),
    );
  }

  Future<void> loadMoreSummary({String? search}) async {
    if (state is KetenagakerjaanSummaryLoaded) {
      final current = state as KetenagakerjaanSummaryLoaded;
      if (current.hasReachedMax || current.isLoadingMore) return;

      emit(current.copyWith(isLoadingMore: true));
      final result = await repository.getSummaryKetenagakerjaan(cursor: current.nextCursor, search: search);
      result.fold(
        (_) => emit(current.copyWith(isLoadingMore: false)),
        (newItems) => emit(current.copyWith(
          items: [...current.items, ...newItems],
          hasReachedMax: newItems.length < 10,
          nextCursor: current.nextCursor + newItems.length,
          isLoadingMore: false,
        )),
      );
    }
  }

  Future<void> loadDetail(int id) async {
    emit(KetenagakerjaanLoading());
    final result = await repository.getKetenagakerjaanDetail(id, cursor: 0);
    result.fold(
      (failure) => emit(KetenagakerjaanError(failure.message)),
      (items) => emit(KetenagakerjaanDetailLoaded(
        items: items,
        hasReachedMax: items.length < 10,
        nextCursor: items.length,
      )),
    );
  }

  Future<void> loadMoreDetail(int id) async {
    if (state is KetenagakerjaanDetailLoaded) {
      final current = state as KetenagakerjaanDetailLoaded;
      if (current.hasReachedMax || current.isLoadingMore) return;

      emit(current.copyWith(isLoadingMore: true));
      final result = await repository.getKetenagakerjaanDetail(id, cursor: current.nextCursor);
      result.fold(
        (_) => emit(current.copyWith(isLoadingMore: false)),
        (newItems) => emit(current.copyWith(
          items: [...current.items, ...newItems],
          hasReachedMax: newItems.length < 10,
          nextCursor: current.nextCursor + newItems.length,
          isLoadingMore: false,
        )),
      );
    }
  }

  Future<String> downloadSurat(KetenagakerjaanItemModel item) async {
    final result = await repository.downloadSuratKetenagakerjaan(
      id: item.id,
      minggu: item.minggu,
      bulan: item.bulan,
      tahun: item.tahun,
      status: item.status,
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (filePath) => filePath,
    );
  }
}
