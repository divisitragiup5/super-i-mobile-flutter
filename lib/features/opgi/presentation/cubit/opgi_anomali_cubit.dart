import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/storage/local_database.dart';
import '../../data/models/opgi_anomali_model.dart';
import '../../domain/repositories/opgi_repository.dart';

abstract class OpgiAnomaliState extends Equatable {
  const OpgiAnomaliState();
  @override
  List<Object?> get props => [];
}

class OpgiAnomaliInitial extends OpgiAnomaliState {}

class OpgiAnomaliLoading extends OpgiAnomaliState {}

class OpgiAnomaliLoaded extends OpgiAnomaliState {
  final List<AnomaliReportModel> items;
  final List<Map<String, dynamic>> localDrafts;
  const OpgiAnomaliLoaded({required this.items, this.localDrafts = const []});
  @override
  List<Object?> get props => [items, localDrafts];
}

class OpgiAnomaliKondisiLoaded extends OpgiAnomaliState {
  final List<AnomaliKondisiModel> conditions;
  final List<Map<String, dynamic>> localDrafts;
  const OpgiAnomaliKondisiLoaded({
    required this.conditions,
    this.localDrafts = const [],
  });
  @override
  List<Object?> get props => [conditions, localDrafts];
}

class OpgiAnomaliAssetsLoaded extends OpgiAnomaliState {
  final List<Map<String, dynamic>> assets;
  const OpgiAnomaliAssetsLoaded(this.assets);
  @override
  List<Object?> get props => [assets];
}

class OpgiAnomaliSuccess extends OpgiAnomaliState {
  final String message;
  final dynamic extra;
  const OpgiAnomaliSuccess(this.message, {this.extra});
  @override
  List<Object?> get props => [message, extra];
}

class OpgiAnomaliError extends OpgiAnomaliState {
  final String message;
  const OpgiAnomaliError(this.message);
  @override
  List<Object?> get props => [message];
}

class OpgiAnomaliCubit extends Cubit<OpgiAnomaliState> {
  final OpgiRepository _repository;

  OpgiAnomaliCubit(this._repository) : super(OpgiAnomaliInitial());

  Future<void> loadHistory(int garduIndukId, {int? cursor}) async {
    emit(OpgiAnomaliLoading());
    try {
      final items =
          await _repository.getAnomaliHistory(garduIndukId, cursor: cursor);
      List<Map<String, dynamic>> drafts = [];
      try {
        drafts =
            await LocalDatabase.instance.getUnfinishItemGi(type: 'anomali');
      } catch (_) {}
      emit(OpgiAnomaliLoaded(items: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiAnomaliError(e.toString()));
    }
  }

  Future<void> loadKondisiHistory(int anomaliId,
      {int? cursor, String? draftKey}) async {
    emit(OpgiAnomaliLoading());
    try {
      final items = await _repository.getKondisiAnomaliHistory(anomaliId,
          cursor: cursor);
      List<Map<String, dynamic>> drafts = [];
      if (draftKey != null && draftKey.isNotEmpty) {
        try {
          drafts = await LocalDatabase.instance.getUnfinishItemGi(
            nama: draftKey,
            type: 'anomali-progress',
          );
        } catch (_) {}
      }
      emit(OpgiAnomaliKondisiLoaded(conditions: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiAnomaliError(e.toString()));
    }
  }

  Future<void> loadAssets(int garduIndukId, String jenisAsset) async {
    try {
      final assets =
          await _repository.getAnomaliAssets(garduIndukId, jenisAsset);
      emit(OpgiAnomaliAssetsLoaded(assets));
    } catch (e) {
      emit(OpgiAnomaliError(e.toString()));
    }
  }

  Future<void> submitAnomali({
    required Map<String, dynamic> data,
    XFile? imageFile,
    XFile? videoFile,
    int? draftId,
  }) async {
    emit(OpgiAnomaliLoading());
    try {
      await _repository.submitAnomali(
        data: data,
        imageFile: imageFile,
        videoFile: videoFile,
      );
      if (draftId != null) {
        await LocalDatabase.instance.removeFinishedItemGi(draftId);
      }
      emit(const OpgiAnomaliSuccess('Laporan anomali berhasil dikirim'));
    } catch (e) {
      emit(OpgiAnomaliError(e.toString()));
    }
  }

  Future<void> submitAnomaliKondisi({
    required Map<String, dynamic> data,
    XFile? imageFile,
    XFile? videoFile,
    int? draftId,
  }) async {
    emit(OpgiAnomaliLoading());
    try {
      await _repository.submitAnomaliKondisi(
        data: data,
        imageFile: imageFile,
        videoFile: videoFile,
      );
      if (draftId != null) {
        await LocalDatabase.instance.removeFinishedItemGi(draftId);
      }
      final isSelesai = data['tindakan']?.toString().toUpperCase() == 'SELESAI';
      emit(OpgiAnomaliSuccess(
        'Update kondisi anomali berhasil dikirim',
        extra: {'isSelesai': isSelesai},
      ));
    } catch (e) {
      emit(OpgiAnomaliError(e.toString()));
    }
  }

  Future<void> updateAnomaliKondisi({
    required int kondisiId,
    required Map<String, dynamic> data,
  }) async {
    emit(OpgiAnomaliLoading());
    try {
      await _repository.updateAnomaliKondisi(kondisiId, data);
      final isSelesai = data['tindakan']?.toString().toUpperCase() == 'SELESAI';
      emit(OpgiAnomaliSuccess(
        'Kondisi anomali berhasil diperbarui',
        extra: {'isSelesai': isSelesai},
      ));
    } catch (e) {
      emit(OpgiAnomaliError(e.toString()));
    }
  }

  Future<void> deleteAnomali(int id, int garduIndukId) async {
    emit(OpgiAnomaliLoading());
    try {
      await _repository.deleteAnomali(id);
      final items = await _repository.getAnomaliHistory(garduIndukId);
      List<Map<String, dynamic>> drafts = [];
      try {
        drafts =
            await LocalDatabase.instance.getUnfinishItemGi(type: 'anomali');
      } catch (_) {}
      emit(OpgiAnomaliLoaded(items: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiAnomaliError(e.toString()));
    }
  }

  Future<void> deleteAnomaliKondisi(
      int id, int anomaliId, {String? draftKey}) async {
    emit(OpgiAnomaliLoading());
    try {
      await _repository.deleteAnomaliKondisi(id);
      final items = await _repository.getKondisiAnomaliHistory(anomaliId);
      List<Map<String, dynamic>> drafts = [];
      if (draftKey != null && draftKey.isNotEmpty) {
        try {
          drafts = await LocalDatabase.instance.getUnfinishItemGi(
            nama: draftKey,
            type: 'anomali-progress',
          );
        } catch (_) {}
      }
      emit(OpgiAnomaliKondisiLoaded(conditions: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiAnomaliError(e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Draft Management
  // ═══════════════════════════════════════════════════════════════

  Future<void> saveAnomaliDraft({
    required String nama,
    required Map<String, dynamic> data,
  }) async {
    await LocalDatabase.instance.addUnfinishItemGi(
      nama: nama,
      date: DateTime.now().toIso8601String(),
      type: 'anomali',
      periode: 0,
      data: data,
    );
  }

  Future<void> saveKondisiDraft({
    required String nama,
    required Map<String, dynamic> data,
  }) async {
    await LocalDatabase.instance.addUnfinishItemGi(
      nama: nama,
      date: DateTime.now().toIso8601String(),
      type: 'anomali-progress',
      periode: 0,
      data: data,
    );
  }

  Future<Map<String, dynamic>?> getAnomaliDraft(String nama) async {
    final drafts = await LocalDatabase.instance.getUnfinishItemGi(
      nama: nama,
      type: 'anomali',
    );
    return drafts.isNotEmpty ? drafts.first : null;
  }

  Future<Map<String, dynamic>?> getKondisiDraft(String nama) async {
    final drafts = await LocalDatabase.instance.getUnfinishItemGi(
      nama: nama,
      type: 'anomali-progress',
    );
    return drafts.isNotEmpty ? drafts.first : null;
  }

  Future<void> deleteDraft(int draftId) async {
    await LocalDatabase.instance.removeFinishedItemGi(draftId);
  }
}
