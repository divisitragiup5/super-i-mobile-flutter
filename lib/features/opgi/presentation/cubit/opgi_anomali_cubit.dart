import 'dart:convert';
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

class OpgiAnomaliAssetsLoaded extends OpgiAnomaliState {
  final List<Map<String, dynamic>> assets;
  const OpgiAnomaliAssetsLoaded(this.assets);
  @override
  List<Object?> get props => [assets];
}

class OpgiAnomaliSuccess extends OpgiAnomaliState {
  final String message;
  const OpgiAnomaliSuccess(this.message);
  @override
  List<Object?> get props => [message];
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
      final items = await _repository.getAnomaliHistory(garduIndukId, cursor: cursor);
      final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(type: 'anomali');
      emit(OpgiAnomaliLoaded(items: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiAnomaliError(e.toString()));
    }
  }

  Future<void> loadAssets(int garduIndukId, String jenisAsset) async {
    try {
      final assets = await _repository.getAnomaliAssets(garduIndukId, jenisAsset);
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
        await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
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
  }) async {
    emit(OpgiAnomaliLoading());
    try {
      await _repository.submitAnomaliKondisi(
        data: data,
        imageFile: imageFile,
        videoFile: videoFile,
      );
      emit(const OpgiAnomaliSuccess('Update kondisi anomali berhasil dikirim'));
    } catch (e) {
      emit(OpgiAnomaliError(e.toString()));
    }
  }

  Future<void> deleteAnomali(int id, int garduIndukId) async {
    emit(OpgiAnomaliLoading());
    try {
      await _repository.deleteAnomali(id);
      final items = await _repository.getAnomaliHistory(garduIndukId);
      final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(type: 'anomali');
      emit(OpgiAnomaliLoaded(items: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiAnomaliError(e.toString()));
    }
  }

  Future<void> deleteAnomaliKondisi(int id, int garduIndukId) async {
    emit(OpgiAnomaliLoading());
    try {
      await _repository.deleteAnomaliKondisi(id);
      final items = await _repository.getAnomaliHistory(garduIndukId);
      final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(type: 'anomali');
      emit(OpgiAnomaliLoaded(items: items, localDrafts: drafts));
    } catch (e) {
      emit(OpgiAnomaliError(e.toString()));
    }
  }

  Future<void> saveDraft({
    required String nama,
    required String date,
    required Map<String, dynamic> data,
  }) async {
    await LocalDatabase.instance.insertUnfinishedItemGI({
      'nama': nama,
      'date': date,
      'type': 'anomali',
      'periode': 0,
      'data': jsonEncode(data),
    });
  }

  Future<void> deleteDraft(int draftId) async {
    await LocalDatabase.instance.deleteUnfinishedItemGI(draftId);
  }
}
