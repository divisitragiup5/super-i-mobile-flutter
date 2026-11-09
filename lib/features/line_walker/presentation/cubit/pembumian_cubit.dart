import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/storage/local_database.dart';
import '../../data/models/pembumian_model.dart';
import '../../data/models/tower_asset_model.dart';
import '../../domain/repositories/line_walker_repository.dart';

abstract class PembumianState extends Equatable {
  const PembumianState();
  @override
  List<Object?> get props => [];
}

class PembumianInitial extends PembumianState {}

class PembumianLoading extends PembumianState {}

class PembumianLoaded extends PembumianState {
  final List<TowerAssetModel> towers;
  final TowerAssetModel? selectedTower;
  final Map<String, dynamic>? lastInspection;
  final bool isLoadingLast;

  const PembumianLoaded({
    required this.towers,
    this.selectedTower,
    this.lastInspection,
    this.isLoadingLast = false,
  });

  PembumianLoaded copyWith({
    List<TowerAssetModel>? towers,
    TowerAssetModel? selectedTower,
    Map<String, dynamic>? lastInspection,
    bool? isLoadingLast,
    bool clearLastInspection = false,
  }) {
    return PembumianLoaded(
      towers: towers ?? this.towers,
      selectedTower: selectedTower ?? this.selectedTower,
      lastInspection: clearLastInspection ? null : (lastInspection ?? this.lastInspection),
      isLoadingLast: isLoadingLast ?? this.isLoadingLast,
    );
  }

  @override
  List<Object?> get props => [towers, selectedTower, lastInspection, isLoadingLast];
}

class PembumianSubmitting extends PembumianState {}

class PembumianSubmitSuccess extends PembumianState {
  final String message;
  const PembumianSubmitSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class PembumianSubmitFailure extends PembumianState {
  final String message;
  const PembumianSubmitFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class PembumianHistoryLoaded extends PembumianState {
  final List<PembumianHistoryItemModel> items;
  final bool hasReachedMax;
  final int nextCursor;
  final bool isLoadingMore;

  const PembumianHistoryLoaded({
    required this.items,
    this.hasReachedMax = false,
    this.nextCursor = 0,
    this.isLoadingMore = false,
  });

  PembumianHistoryLoaded copyWith({
    List<PembumianHistoryItemModel>? items,
    bool? hasReachedMax,
    int? nextCursor,
    bool? isLoadingMore,
  }) {
    return PembumianHistoryLoaded(
      items: items ?? this.items,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [items, hasReachedMax, nextCursor, isLoadingMore];
}

class PembumianCubit extends Cubit<PembumianState> {
  final LineWalkerRepository repository;

  PembumianCubit(this.repository) : super(PembumianInitial());

  Future<void> loadTowers() async {
    emit(PembumianLoading());
    final result = await repository.getTowers();
    result.fold(
      (failure) => emit(PembumianSubmitFailure(failure.message)),
      (towers) => emit(PembumianLoaded(towers: towers)),
    );
  }

  Future<void> selectTower(TowerAssetModel tower) async {
    if (state is PembumianLoaded) {
      final current = state as PembumianLoaded;
      emit(current.copyWith(
        selectedTower: tower,
        isLoadingLast: true,
        clearLastInspection: true,
      ));

      final lastRes = await repository.getLastPembumian(tower.id);
      if (state is PembumianLoaded) {
        final updated = state as PembumianLoaded;
        lastRes.fold(
          (_) => emit(updated.copyWith(isLoadingLast: false)),
          (last) => emit(updated.copyWith(
            lastInspection: last,
            isLoadingLast: false,
          )),
        );
      }
    }
  }

  Future<void> submitPembumian(PembumianInputModel input, {int? draftId}) async {
    emit(PembumianSubmitting());
    final result = await repository.submitPembumian(input);
    result.fold(
      (failure) => emit(PembumianSubmitFailure(failure.message)),
      (msg) async {
        if (draftId != null) {
          await LocalDatabase.instance.deleteUnfinishItem(draftId);
        }
        emit(PembumianSubmitSuccess(msg));
      },
    );
  }

  Future<void> saveDraft(PembumianInputModel input) async {
    await LocalDatabase.instance.insertUnfinishItem({
      'nama': input.namaTower ?? 'Draft Pembumian',
      'date': DateTime.now().toIso8601String(),
      'type': 'pembumian',
      'data': jsonEncode(input.toJsonDraft()),
    });
  }

  Future<void> loadHistory({String? search}) async {
    emit(PembumianLoading());
    final result = await repository.getPembumianHistory(cursor: 0, search: search);
    result.fold(
      (failure) => emit(PembumianSubmitFailure(failure.message)),
      (items) => emit(PembumianHistoryLoaded(
        items: items,
        hasReachedMax: items.length < 10,
        nextCursor: items.length,
      )),
    );
  }

  Future<void> loadMoreHistory({String? search}) async {
    if (state is PembumianHistoryLoaded) {
      final current = state as PembumianHistoryLoaded;
      if (current.hasReachedMax || current.isLoadingMore) return;

      emit(current.copyWith(isLoadingMore: true));
      final result = await repository.getPembumianHistory(cursor: current.nextCursor, search: search);
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

  Future<String> downloadBA(PembumianHistoryItemModel item) async {
    final result = await repository.downloadBAPembumian(
      towerId: item.towerId,
      inspectionId: item.id,
      towerName: item.namaTower ?? 'Tower-${item.towerId}',
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (path) => path,
    );
  }
}
