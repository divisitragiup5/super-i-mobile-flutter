import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/storage/local_database.dart';
import '../../data/models/tower_asset_model.dart';
import '../../data/models/waterpass_model.dart';
import '../../domain/repositories/line_walker_repository.dart';

abstract class WaterpassState extends Equatable {
  const WaterpassState();
  @override
  List<Object?> get props => [];
}

class WaterpassInitial extends WaterpassState {}

class WaterpassLoading extends WaterpassState {}

class WaterpassLoaded extends WaterpassState {
  final List<TowerAssetModel> towers;
  final TowerAssetModel? selectedTower;
  final WaterpassDetailModel? lastInspection;
  final bool isLoadingLast;

  const WaterpassLoaded({
    required this.towers,
    this.selectedTower,
    this.lastInspection,
    this.isLoadingLast = false,
  });

  WaterpassLoaded copyWith({
    List<TowerAssetModel>? towers,
    TowerAssetModel? selectedTower,
    WaterpassDetailModel? lastInspection,
    bool? isLoadingLast,
    bool clearLastInspection = false,
  }) {
    return WaterpassLoaded(
      towers: towers ?? this.towers,
      selectedTower: selectedTower ?? this.selectedTower,
      lastInspection: clearLastInspection ? null : (lastInspection ?? this.lastInspection),
      isLoadingLast: isLoadingLast ?? this.isLoadingLast,
    );
  }

  @override
  List<Object?> get props => [towers, selectedTower, lastInspection, isLoadingLast];
}

class WaterpassSubmitting extends WaterpassState {}

class WaterpassSubmitSuccess extends WaterpassState {
  final String message;
  const WaterpassSubmitSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class WaterpassSubmitFailure extends WaterpassState {
  final String message;
  const WaterpassSubmitFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class WaterpassCubit extends Cubit<WaterpassState> {
  final LineWalkerRepository repository;

  WaterpassCubit(this.repository) : super(WaterpassInitial());

  Future<void> loadTowers() async {
    emit(WaterpassLoading());
    final result = await repository.getTowers();
    result.fold(
      (failure) => emit(WaterpassSubmitFailure(failure.message)),
      (towers) => emit(WaterpassLoaded(towers: towers)),
    );
  }

  Future<void> selectTower(TowerAssetModel tower) async {
    if (state is WaterpassLoaded) {
      final current = state as WaterpassLoaded;
      emit(current.copyWith(
        selectedTower: tower,
        isLoadingLast: true,
        clearLastInspection: true,
      ));

      final lastRes = await repository.getLastWaterpass(tower.id);
      if (state is WaterpassLoaded) {
        final updated = state as WaterpassLoaded;
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

  Future<void> submitWaterpass(WaterpassInputModel input, {int? draftId}) async {
    emit(WaterpassSubmitting());
    final result = await repository.submitWaterpass(input);
    result.fold(
      (failure) => emit(WaterpassSubmitFailure(failure.message)),
      (msg) async {
        if (draftId != null) {
          await LocalDatabase.instance.deleteUnfinishItem(draftId);
        }
        emit(WaterpassSubmitSuccess(msg));
      },
    );
  }

  Future<void> saveDraft(WaterpassInputModel input) async {
    await LocalDatabase.instance.insertUnfinishItem({
      'nama': input.namaTower ?? 'Draft Waterpass',
      'date': DateTime.now().toIso8601String(),
      'type': 'waterpass',
      'data': jsonEncode(input.toJsonDraft()),
    });
  }
}
