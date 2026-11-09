import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/storage/local_database.dart';
import '../../data/models/kegiatan_sosial_model.dart';
import '../../data/models/tower_asset_model.dart';
import '../../domain/repositories/line_walker_repository.dart';

abstract class KegiatanSosialState extends Equatable {
  const KegiatanSosialState();
  @override
  List<Object?> get props => [];
}

class KegiatanSosialInitial extends KegiatanSosialState {}

class KegiatanSosialLoading extends KegiatanSosialState {}

class KegiatanSosialLoaded extends KegiatanSosialState {
  final List<TowerAssetModel> towers;
  final TowerAssetModel? selectedTower;
  final Map<String, dynamic>? lastInspection;
  final bool isLoadingLast;

  const KegiatanSosialLoaded({
    required this.towers,
    this.selectedTower,
    this.lastInspection,
    this.isLoadingLast = false,
  });

  KegiatanSosialLoaded copyWith({
    List<TowerAssetModel>? towers,
    TowerAssetModel? selectedTower,
    Map<String, dynamic>? lastInspection,
    bool? isLoadingLast,
    bool clearLastInspection = false,
  }) {
    return KegiatanSosialLoaded(
      towers: towers ?? this.towers,
      selectedTower: selectedTower ?? this.selectedTower,
      lastInspection: clearLastInspection ? null : (lastInspection ?? this.lastInspection),
      isLoadingLast: isLoadingLast ?? this.isLoadingLast,
    );
  }

  @override
  List<Object?> get props => [towers, selectedTower, lastInspection, isLoadingLast];
}

class KegiatanSosialSubmitting extends KegiatanSosialState {}

class KegiatanSosialSubmitSuccess extends KegiatanSosialState {
  final String message;
  const KegiatanSosialSubmitSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class KegiatanSosialSubmitFailure extends KegiatanSosialState {
  final String message;
  const KegiatanSosialSubmitFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class KegiatanSosialHistoryLoaded extends KegiatanSosialState {
  final List<KegiatanSosialHistoryItemModel> items;
  final bool hasReachedMax;
  final int nextCursor;
  final bool isLoadingMore;

  const KegiatanSosialHistoryLoaded({
    required this.items,
    this.hasReachedMax = false,
    this.nextCursor = 0,
    this.isLoadingMore = false,
  });

  KegiatanSosialHistoryLoaded copyWith({
    List<KegiatanSosialHistoryItemModel>? items,
    bool? hasReachedMax,
    int? nextCursor,
    bool? isLoadingMore,
  }) {
    return KegiatanSosialHistoryLoaded(
      items: items ?? this.items,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [items, hasReachedMax, nextCursor, isLoadingMore];
}

class KegiatanSosialCubit extends Cubit<KegiatanSosialState> {
  final LineWalkerRepository repository;

  KegiatanSosialCubit(this.repository) : super(KegiatanSosialInitial());

  Future<void> loadTowers() async {
    emit(KegiatanSosialLoading());
    final result = await repository.getTowers();
    result.fold(
      (failure) => emit(KegiatanSosialSubmitFailure(failure.message)),
      (towers) => emit(KegiatanSosialLoaded(towers: towers)),
    );
  }

  Future<void> selectTower(TowerAssetModel tower) async {
    if (state is KegiatanSosialLoaded) {
      final current = state as KegiatanSosialLoaded;
      emit(current.copyWith(
        selectedTower: tower,
        isLoadingLast: true,
        clearLastInspection: true,
      ));

      final lastRes = await repository.getLastKegiatanSosial(tower.id);
      if (state is KegiatanSosialLoaded) {
        final updated = state as KegiatanSosialLoaded;
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

  Future<void> submitKegiatanSosial(KegiatanSosialInputModel input, {int? draftId}) async {
    emit(KegiatanSosialSubmitting());
    final result = await repository.submitKegiatanSosial(input);
    result.fold(
      (failure) => emit(KegiatanSosialSubmitFailure(failure.message)),
      (msg) async {
        if (draftId != null) {
          await LocalDatabase.instance.deleteUnfinishItem(draftId);
        }
        emit(KegiatanSosialSubmitSuccess(msg));
      },
    );
  }

  Future<void> updateKegiatanSosial({
    required int id,
    File? ttdTLGI,
    String? namaTTDTLGI,
    File? ttdLineWalker,
    String? namaTTDLineWalker,
  }) async {
    emit(KegiatanSosialSubmitting());
    final result = await repository.updateKegiatanSosial(
      id: id,
      ttdTLGI: ttdTLGI,
      namaTTDTLGI: namaTTDTLGI,
      ttdLineWalker: ttdLineWalker,
      namaTTDLineWalker: namaTTDLineWalker,
    );
    result.fold(
      (failure) => emit(KegiatanSosialSubmitFailure(failure.message)),
      (msg) => emit(KegiatanSosialSubmitSuccess(msg)),
    );
  }

  Future<void> saveDraft(KegiatanSosialInputModel input) async {
    await LocalDatabase.instance.insertUnfinishItem({
      'nama': input.namaTower ?? 'Draft Kegiatan Sosial',
      'date': DateTime.now().toIso8601String(),
      'type': 'kegiatan-sosial',
      'data': jsonEncode(input.toJsonDraft()),
    });
  }

  Future<void> loadHistory({String? search}) async {
    emit(KegiatanSosialLoading());
    final result = await repository.getKegiatanSosialHistory(cursor: 0, search: search);
    result.fold(
      (failure) => emit(KegiatanSosialSubmitFailure(failure.message)),
      (items) => emit(KegiatanSosialHistoryLoaded(
        items: items,
        hasReachedMax: items.length < 10,
        nextCursor: items.length,
      )),
    );
  }

  Future<void> loadMoreHistory({String? search}) async {
    if (state is KegiatanSosialHistoryLoaded) {
      final current = state as KegiatanSosialHistoryLoaded;
      if (current.hasReachedMax || current.isLoadingMore) return;

      emit(current.copyWith(isLoadingMore: true));
      final result = await repository.getKegiatanSosialHistory(cursor: current.nextCursor, search: search);
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
    emit(KegiatanSosialLoading());
    final result = await repository.getKegiatanSosialHistoryByIdentifier(identifier, cursor: 0);
    result.fold(
      (failure) => emit(KegiatanSosialSubmitFailure(failure.message)),
      (items) => emit(KegiatanSosialHistoryLoaded(
        items: items,
        hasReachedMax: items.length < 10,
        nextCursor: items.length,
      )),
    );
  }

  Future<void> loadMoreHistoryByIdentifier(String identifier) async {
    if (state is KegiatanSosialHistoryLoaded) {
      final current = state as KegiatanSosialHistoryLoaded;
      if (current.hasReachedMax || current.isLoadingMore) return;

      emit(current.copyWith(isLoadingMore: true));
      final result = await repository.getKegiatanSosialHistoryByIdentifier(identifier, cursor: current.nextCursor);
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

  Future<String> downloadBA(KegiatanSosialHistoryItemModel item) async {
    final result = await repository.downloadBAKegiatanSosial(
      inspectionId: item.id,
      towerName: item.namaTower ?? 'Tower-${item.towerId}',
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (path) => path,
    );
  }
}

