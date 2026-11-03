import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/sutm_pemeliharaan_model.dart';
import '../../data/models/sutm_workorder_model.dart';
import '../../domain/repositories/sutm_repository.dart';

abstract class PemeliharaanFormState {}

class PemeliharaanFormInitial extends PemeliharaanFormState {}

class PemeliharaanFormLoaded extends PemeliharaanFormState {
  final List<RincianPemeliharaanItem> rincianItems;
  final String? globalKendala;
  final File? globalFotoKendala;

  PemeliharaanFormLoaded({
    required this.rincianItems,
    this.globalKendala,
    this.globalFotoKendala,
  });

  PemeliharaanFormLoaded copyWith({
    List<RincianPemeliharaanItem>? rincianItems,
    String? globalKendala,
    File? globalFotoKendala,
  }) {
    return PemeliharaanFormLoaded(
      rincianItems: rincianItems ?? this.rincianItems,
      globalKendala: globalKendala ?? this.globalKendala,
      globalFotoKendala: globalFotoKendala ?? this.globalFotoKendala,
    );
  }
}

class PemeliharaanFormSubmitting extends PemeliharaanFormState {}

class PemeliharaanFormSuccess extends PemeliharaanFormState {
  final String message;

  PemeliharaanFormSuccess({required this.message});
}

class PemeliharaanFormError extends PemeliharaanFormState {
  final String message;

  PemeliharaanFormError({required this.message});
}

class PemeliharaanFormCubit extends Cubit<PemeliharaanFormState> {
  final SutmRepository repository;

  PemeliharaanFormCubit({required this.repository})
      : super(PemeliharaanFormInitial());

  void initFromRencana(List<RencanaItemModel> rencanaList) {
    final items = rencanaList.map((r) {
      return RincianPemeliharaanItem(
        rencanaId: r.id,
        sub: r.sub,
        komponen: r.komponen,
        fasa: r.fasa,
        jumlah: r.jumlah,
        status: 'TERLAKSANA',
      );
    }).toList();

    emit(PemeliharaanFormLoaded(rincianItems: items));
  }

  void updateRincianItem(int index, RincianPemeliharaanItem updatedItem) {
    if (state is! PemeliharaanFormLoaded) return;
    final current = state as PemeliharaanFormLoaded;
    final list = List<RincianPemeliharaanItem>.from(current.rincianItems);
    if (index >= 0 && index < list.length) {
      list[index] = updatedItem;
      emit(current.copyWith(rincianItems: list));
    }
  }

  void setGlobalKendala(String? kendala, File? foto) {
    if (state is! PemeliharaanFormLoaded) return;
    final current = state as PemeliharaanFormLoaded;
    emit(current.copyWith(
      globalKendala: kendala,
      globalFotoKendala: foto,
    ));
  }

  Future<void> submitPemeliharaan({
    required int workOrderId,
    required int workOrderSutmItemId,
    required int sutmId,
  }) async {
    if (state is! PemeliharaanFormLoaded) return;
    final current = state as PemeliharaanFormLoaded;

    emit(PemeliharaanFormSubmitting());

    final formData = SutmPemeliharaanPayload.buildFormData(
      workOrderId: workOrderId,
      workOrderSutmItemId: workOrderSutmItemId,
      sutmId: sutmId,
      rincianItems: current.rincianItems,
      globalKendala: current.globalKendala,
      globalFotoKendala: current.globalFotoKendala,
    );

    final result = await repository.submitPemeliharaan(formData);
    result.fold(
      (failure) => emit(PemeliharaanFormError(message: failure.message)),
      (_) => emit(PemeliharaanFormSuccess(
          message: 'Data pemeliharaan SUTM berhasil disimpan!')),
    );
  }
}
