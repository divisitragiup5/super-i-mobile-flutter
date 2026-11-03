import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/riwayat_absen_repository.dart';
import 'riwayat_absen_state.dart';

class RiwayatAbsenCubit extends Cubit<RiwayatAbsenState> {
  final RiwayatAbsenRepository repository;

  RiwayatAbsenCubit(this.repository) : super(RiwayatAbsenInitial());

  Future<void> fetchHistory() async {
    emit(RiwayatAbsenLoading());
    final result = await repository.getAbsenHistory();
    result.fold(
      (failure) => emit(RiwayatAbsenError(failure.message)),
      (data) => emit(
        RiwayatAbsenLoaded(
          items: data.items,
          nextCursor: data.nextCursor,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! RiwayatAbsenLoaded ||
        currentState.nextCursor == null ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await repository.getAbsenHistory(
      cursor: currentState.nextCursor,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (data) => emit(
        currentState.copyWith(
          items: [...currentState.items, ...data.items],
          nextCursor: data.nextCursor,
          isLoadingMore: false,
        ),
      ),
    );
  }
}

class UploadDokumenCubit extends Cubit<UploadDokumenState> {
  final RiwayatAbsenRepository repository;

  UploadDokumenCubit(this.repository) : super(UploadDokumenInitial());

  Future<void> uploadDokumen({
    required int riwayatId,
    required File file,
  }) async {
    emit(UploadDokumenLoading());
    final result = await repository.uploadDokumen(
      riwayatId: riwayatId,
      file: file,
    );
    result.fold(
      (failure) => emit(UploadDokumenError(failure.message)),
      (message) => emit(UploadDokumenSuccess(message)),
    );
  }
}
