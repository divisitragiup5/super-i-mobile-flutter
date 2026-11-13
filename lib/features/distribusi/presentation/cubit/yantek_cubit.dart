import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/sutm_workorder_model.dart';
import '../../data/models/yantek_asset_model.dart';
import '../../domain/repositories/sutm_repository.dart';

abstract class YantekState {}

class YantekInitial extends YantekState {}

class YantekLoading extends YantekState {}

class YantekLoaded extends YantekState {
  final List<YantekAssetModel> assets;
  final YantekAssetModel? selectedAsset;
  final LastInspeksiModel? lastInspeksi;
  final bool isLoadingDetail;

  YantekLoaded({
    required this.assets,
    this.selectedAsset,
    this.lastInspeksi,
    this.isLoadingDetail = false,
  });

  YantekLoaded copyWith({
    List<YantekAssetModel>? assets,
    YantekAssetModel? selectedAsset,
    LastInspeksiModel? lastInspeksi,
    bool? isLoadingDetail,
  }) {
    return YantekLoaded(
      assets: assets ?? this.assets,
      selectedAsset: selectedAsset ?? this.selectedAsset,
      lastInspeksi: lastInspeksi ?? this.lastInspeksi,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
    );
  }
}

class YantekError extends YantekState {
  final String message;

  YantekError({required this.message});
}

class YantekCubit extends Cubit<YantekState> {
  final SutmRepository repository;

  YantekCubit({required this.repository}) : super(YantekInitial());

  Future<void> fetchNearbyAssets({
    required double lat,
    required double lng,
  }) async {
    emit(YantekLoading());

    // Hitung bounding box ~1 km dari koordinat saat ini
    const deltaLat = 1 / 111.32;
    final deltaLng = 1 / (111.32 * (lat != 0 ? 0.9 : 1.0));

    final params = YantekFilterParams(
      lat: lat,
      lng: lng,
      minLat: lat - deltaLat,
      maxLat: lat + deltaLat,
      minLng: lng - deltaLng,
      maxLng: lng + deltaLng,
    );

    final result = await repository.getYantekMapAssets(params);
    result.fold(
      (failure) => emit(YantekError(message: failure.message)),
      (assets) => emit(YantekLoaded(assets: assets)),
    );
  }

  Future<void> fetchMapAssets(YantekFilterParams params) async {
    emit(YantekLoading());
    final result = await repository.getYantekMapAssets(params);
    result.fold(
      (failure) => emit(YantekError(message: failure.message)),
      (assets) => emit(YantekLoaded(assets: assets)),
    );
  }

  Future<void> selectAsset(YantekAssetModel asset) async {
    if (state is! YantekLoaded) return;
    final current = state as YantekLoaded;

    emit(current.copyWith(
      selectedAsset: asset,
      isLoadingDetail: true,
    ));

    final result = await repository.getLastInspeksiAsset(asset.id.toString());
    result.fold(
      (failure) => emit(current.copyWith(
        selectedAsset: asset,
        lastInspeksi: null,
        isLoadingDetail: false,
      )),
      (lastInsp) => emit(current.copyWith(
        selectedAsset: asset,
        lastInspeksi: lastInsp,
        isLoadingDetail: false,
      )),
    );
  }

  void clearSelectedAsset() {
    if (state is! YantekLoaded) return;
    final current = state as YantekLoaded;
    emit(current.copyWith(
      selectedAsset: null,
      lastInspeksi: null,
      isLoadingDetail: false,
    ));
  }
}
