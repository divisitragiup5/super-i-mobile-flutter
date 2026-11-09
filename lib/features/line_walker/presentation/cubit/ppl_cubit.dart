import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/storage/local_database.dart';
import '../../data/models/ppl_model.dart';
import '../../data/models/tower_asset_model.dart';
import '../../domain/repositories/line_walker_repository.dart';

abstract class PplState extends Equatable {
  const PplState();
  @override
  List<Object?> get props => [];
}

class PplInitial extends PplState {}

class PplLoading extends PplState {}

class PplLoaded extends PplState {
  final List<TowerAssetModel> towers;
  final TowerAssetModel? selectedTower;
  final Map<String, dynamic>? lastInspection;
  final bool isLoadingLast;

  const PplLoaded({
    required this.towers,
    this.selectedTower,
    this.lastInspection,
    this.isLoadingLast = false,
  });

  PplLoaded copyWith({
    List<TowerAssetModel>? towers,
    TowerAssetModel? selectedTower,
    Map<String, dynamic>? lastInspection,
    bool? isLoadingLast,
    bool clearLastInspection = false,
  }) {
    return PplLoaded(
      towers: towers ?? this.towers,
      selectedTower: selectedTower ?? this.selectedTower,
      lastInspection: clearLastInspection ? null : (lastInspection ?? this.lastInspection),
      isLoadingLast: isLoadingLast ?? this.isLoadingLast,
    );
  }

  @override
  List<Object?> get props => [towers, selectedTower, lastInspection, isLoadingLast];
}

class PplSubmitting extends PplState {}

class PplSubmitSuccess extends PplState {
  final String message;
  const PplSubmitSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class PplSubmitFailure extends PplState {
  final String message;
  const PplSubmitFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class PplHistoryLoaded extends PplState {
  final List<PPLHistoryItemModel> items;
  final bool hasReachedMax;
  final int nextCursor;
  final bool isLoadingMore;

  const PplHistoryLoaded({
    required this.items,
    this.hasReachedMax = false,
    this.nextCursor = 0,
    this.isLoadingMore = false,
  });

  PplHistoryLoaded copyWith({
    List<PPLHistoryItemModel>? items,
    bool? hasReachedMax,
    int? nextCursor,
    bool? isLoadingMore,
  }) {
    return PplHistoryLoaded(
      items: items ?? this.items,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [items, hasReachedMax, nextCursor, isLoadingMore];
}

class PplSummaryLoaded extends PplState {
  final Map<String, dynamic> summary;
  const PplSummaryLoaded(this.summary);
  @override
  List<Object?> get props => [summary];
}

class PplCubit extends Cubit<PplState> {
  final LineWalkerRepository repository;

  PplCubit(this.repository) : super(PplInitial());

  Future<void> loadTowers() async {
    emit(PplLoading());
    final result = await repository.getTowers(type: 'JOINT,SPAN');
    result.fold(
      (failure) => emit(PplSubmitFailure(failure.message)),
      (towers) => emit(PplLoaded(towers: towers)),
    );
  }

  Future<void> selectTower(TowerAssetModel tower) async {
    if (state is PplLoaded) {
      final current = state as PplLoaded;
      emit(current.copyWith(
        selectedTower: tower,
        isLoadingLast: true,
        clearLastInspection: true,
      ));

      final lastRes = await repository.getLastPpl(tower.id);
      if (state is PplLoaded) {
        final updated = state as PplLoaded;
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

  Future<void> submitPpl(PPLInputModel input, {int? draftId}) async {
    emit(PplSubmitting());
    final result = await repository.submitPpl(input);
    result.fold(
      (failure) => emit(PplSubmitFailure(failure.message)),
      (msg) async {
        if (draftId != null) {
          await LocalDatabase.instance.deleteUnfinishItem(draftId);
        }
        emit(PplSubmitSuccess(msg));
      },
    );
  }

  Future<void> updatePpl({required int id, File? ttdTLGI, String? namaTTDTLGI}) async {
    emit(PplSubmitting());
    final result = await repository.updatePpl(
      id: id,
      ttdTLGI: ttdTLGI,
      namaTTDTLGI: namaTTDTLGI,
    );
    result.fold(
      (failure) => emit(PplSubmitFailure(failure.message)),
      (msg) => emit(PplSubmitSuccess(msg)),
    );
  }

  Future<void> saveDraft(PPLInputModel input) async {
    await LocalDatabase.instance.insertUnfinishItem({
      'nama': input.namaTower ?? 'Draft PPL',
      'date': DateTime.now().toIso8601String(),
      'type': 'ppl',
      'data': jsonEncode(input.toJsonDraft()),
    });
  }

  Future<void> loadSummary() async {
    emit(PplLoading());
    final result = await repository.getSummaryRiwayatPpl();
    result.fold(
      (failure) => emit(PplSubmitFailure(failure.message)),
      (summary) => emit(PplSummaryLoaded(summary)),
    );
  }

  Future<void> loadHistory({String? search, String? type}) async {
    emit(PplLoading());
    final result = await repository.getPplHistory(cursor: 0, search: search, type: type);
    result.fold(
      (failure) => emit(PplSubmitFailure(failure.message)),
      (items) => emit(PplHistoryLoaded(
        items: items,
        hasReachedMax: items.length < 10,
        nextCursor: items.length,
      )),
    );
  }

  Future<void> loadMoreHistory({String? search, String? type}) async {
    if (state is PplHistoryLoaded) {
      final current = state as PplHistoryLoaded;
      if (current.hasReachedMax || current.isLoadingMore) return;

      emit(current.copyWith(isLoadingMore: true));
      final result = await repository.getPplHistory(cursor: current.nextCursor, search: search, type: type);
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

  Future<void> loadHistoryByIdentifier(String identifier) async {
    emit(PplLoading());
    final result = await repository.getPplHistoryByIdentifier(identifier, cursor: 0);
    result.fold(
      (failure) => emit(PplSubmitFailure(failure.message)),
      (items) => emit(PplHistoryLoaded(
        items: items,
        hasReachedMax: items.length < 10,
        nextCursor: items.length,
      )),
    );
  }

  Future<void> loadMoreHistoryByIdentifier(String identifier) async {
    if (state is PplHistoryLoaded) {
      final current = state as PplHistoryLoaded;
      if (current.hasReachedMax || current.isLoadingMore) return;

      emit(current.copyWith(isLoadingMore: true));
      final result = await repository.getPplHistoryByIdentifier(identifier, cursor: current.nextCursor);
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

  Future<String> downloadBA(PPLHistoryItemModel item) async {
    final result = await repository.downloadBAPPL(
      inspectionId: item.id,
      towerName: item.namaTower ?? 'Tower-${item.towerId}',
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (path) => path,
    );
  }
}

